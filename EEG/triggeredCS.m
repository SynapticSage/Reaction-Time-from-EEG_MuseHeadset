function [C,S] = coh_spec_andTriggerCut(eegStruct,varargin)
% This function accepts an eegstruct, and optionally, (1) a set of triggers
% and a window and/or (2) Frequencys to summarize. From there, it computes
% coherograms and spectrograms for all electrode combinations. It then cuts
% windows of these measures aligned to the triggers (if triggers given),
% returning cells who index {electrode1}{electrode2} 3D matrices indexed by
% (time, frequency, trigger). Otherwise, it returns whole cohero- and
% spectrograms indexed by simply (time,frequency).

%% Pre-processing

% Parse optional inputs -- these outputs will be empty if the user didn't
% pass any optional inputs. If they are not empty, they change the behavior
% of the function.
[trigInfo] = parseOptionalInput(varargin);

% Alias terms we'll use
raw = eegStruct.raw

%% Compute Main Spectrograms and Coherograms
% Figure out how many electrodes we're dealing with from the column
% strucutre, and generate all pairs
nElectrodes = size(raw,2);
ePairs = combnk( 1:nElectrodes , 2 );

% Inititalize
C = {};
S = {};
phi = {};

% Now, per pair, compute! master C and S components
for e = ePair'
    
    e1 = e(1); e2 = e(2);
    
    [C12,phi12,S12,S1,S2,t,f,confC,phistd,Cerr] = ...
        cohgramc(raw(:,e1),raw(:,e2),movingwin,params);
    
    try % If nested cell already initialized, this works
        C{e1}{e2} = C12;
        phi{e1}{e2} = phi12;
    catch % If it's not initialized, then initialize first
        C{e1} = {}; phi{e1}{e2} = {};
        C{e1}{e2} = C12;
        phi{e1}{e2} = phi12;
    end
    
    S{e1} = S1; S{e2} = S2;
    
end

%% (Optionally) Slice out triggered segments

if ~isempty(trigInfo)
    
    % Alias the fields
    win=trigInfo.win;
    trigs = trigInfo.trigs;
    
    % Now, we start to do the slicing
    for e = ePair'
        e1 = e(1); e2 = e(2);
        
        % Process cohereogram
        C{e1}{e2} = sliceOutTriggers(t, C{e1}{e2}, trigs, win);
        % Process spetrograms
        S{e1} = sliceOutTriggers(t, S{e1} , trigs, win);
        S{e2} = sliceOutTriggers(t, S{e2} , trigs, win);
        
    end
    
end

%% HelperFunction: parseOptionalInput
    function trigInfo = parseOptionalInput(var)
        trigInfo = [];
        for v = 1:2:numel(var)
            switch var{v}
                case 'triggers',    trigInfo.trigs = var{v+1};
                case 'window',      trigInfo.win = var{v+1};
                otherwise
                    warning('Unrecognized input %s', var{v});
            end
        end
    end

%% HelperFunction: sliceOutTriggers
% Inputs: spectrogram or spectrogram-like object, triggers and a window.

    function Sout = sliceOutTriggers(t,S,trigs,win)
        
        cellOutput = false;
        
        % Slice everything into a cell -- sizes will not always be equal
        % because sampling rate has variability
        Scell = {};
        for tr = trig
            times = (t >= tr - win(1)) & (t <= tr - win(2));
            Scell{tr} = S(times,:);
        end
        
        % Different storylines now depending on whether user wants this
        % function to issue a 3D matrix or a cell of 2D matrices.
        if cellOutput
            Sout = Scell;
        else
            % Now, we make sizes equal! First, need to figure out the shape
            % of each matrix
            sizeCell = cellfun( @size, Scell );
            % if it's a row, make it a column cell
            if isrow(sizeCell)
                sizeCell = sizeCell';
            end
            % Now, concatonate all cellular terms into a matrix, along the
            % row
            sizeCell = cat(sizeCell,1);
            % Finally, we can take the minima of all dimensions, in order
            % to atttain the size we should cut to
            sizeCell = min(sizeCell,1);
            r = sizeCell(1); c = sizeCell(2);

            % We can now constrain the matrices
            Scell = cellfun( @(X) X(1:r,1:c) , Scell);

            % Last, we simply concatonate all of them along the row, and
            % resize
            Smat = cat(Scell,1);
            Smat = resize(Scell,r,c,[]);
            % Assert that the 3rd dimension matches the triggers
            assert( size(Smat,3) == numel(trig) );
            % Assign the output
            Sout = Smat;
        end
        
    end

end