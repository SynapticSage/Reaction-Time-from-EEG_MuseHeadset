function [C,S,fcs,M,fmp] = triggeredCS(eegStruct,varargin)
% This function accepts an eegstruct, and optionally, (1) a set of triggers
% and a window and/or (2) Frequencys to summarize. From there, it computes
% coherograms and spectrograms for all electrode combinations. It then cuts
% windows of these measures aligned to the triggers (if triggers given),
% returning cells who index {electrode1}{electrode2} 3D matrices indexed by
% (time, frequency, trigger). Otherwise, it returns whole cohero- and
% spectrograms indexed by simply (time,frequency).

% Parse optional inputs -- these outputs will be empty if the user didn't
% pass any optional inputs. If they are not empty, they change the behavior
% of the function.
p = inputParser;
p.addParameter('triggers',[],@isnumeric);      % Trigger input
p.addParameter('window',[-3 2],@isnumeric);    % Window around trigger
p.addParameter('matchingpursuit',false,@islogical);% Whether to calculate matching-pursuit
p.parse(varargin{:});

win = p.Results.window; trig = p.Results.triggers;
doMatchingPursuit = p.Results.matchingpursuit;

%% Define Default Chronux params
% -------------------------------------------  
params.Fs = double(eegStruct.configuration.eeg_output_frequency_hz);
params.fpass = [0 50];
params.tapers = [2 3]; %[5 2/5 0]; % [time_bandwidth_prod, taper_count] .. or [bandwidth, time, taper-reduction]
params.err = [2 0.05];
params.pad = 0;
% params.logabs = true;
if exist('structstruct.m','file')
	% Print parameters to screen if pretty struct print is in path
    structstruct(params);
end

%% Define a moving window 

	movingwin = getMovingwin( range(params.fpass), params);

	function movingwin = getMovingwin(fpassrange,params)
		% Just like the commented out routine below, the time*freq product
		% is kept constant and produces the same results as the above taken
		% from other code in our database; this is more flexible because it
		% works for any inputted frequency.
        
        if numel(params.tapers) == 2
            lengthmovwin = 200/fpassrange;
            stepsize = lengthmovwin/10;
            movingwin = [lengthmovwin stepsize];
        end
        if numel(params.tapers) == 3
            movingwin = [tapers(2) tapers(2)/10];
		end
        
    end

% Alias terms we'll use
timestamps=eegStruct.raw(:,1);
raw = eegStruct.raw(:,2:end);

%% Compute Main Spectrograms and Coherograms
% Figure out how many electrodes we're dealing with from the column
% strucutre, and generate all pairs
nElectrodes = size(raw,2);
ePairs = combnk( 1:nElectrodes , 2 );

% Inititalize
C   = {};
S   = {};
phi = {};

% Now, per pair, compute! master C and S components
for e = ePairs'
    
    e1 = e(1); e2 = e(2);
    
    [C12,phi12,S12,S1,S2,t,fcs,confC,phistd,Cerr] = ...
        cohgramc(raw(:,e1),raw(:,e2),movingwin,params);

    try % If nested cell already initialized, this works
        C{e1}{e2} = C12;
        phi{e1}{e2} = phi12;
    catch % If it's not initialized, then initialize first
        C{e1} = {}; C{e1}{e2} = {};
        C{e1}{e2} = C12;
    end
end

%% (Optionally) Slice out triggered segments

if ~isempty(trig)
    
    % Now, we start to do the slicing
    for e = ePairs'
        e1 = e(1); e2 = e(2);
        
        % Process cohereogram
        C{e1}{e2} = sliceOutTriggers(t, C{e1}{e2}, trig, win);
        % Process spetrograms
        S{e1} = sliceOutTriggers(t, S{e1} , trigs, win);
        S{e2} = sliceOutTriggers(t, S{e2} , trigs, win);
        
        %% (Optionally) Handle Matching-pursuit calculations
        if doMatchingPursuit
            e1Wins = sliceOutTriggers(t,e1,trigs,win);
            e2Wins = sliceOutTriggers(t,e1,trigs,win);
            
            e1Wins = equalizeSizes(e1);
            e2Wins = equalizeSizes(e1);
            
            e1Wins = cat(e1Wins,3);
            e2Wins = cat(e1Wins,3);
            
            e1Wins = permute(e1Wins,[1 3 2]);
            e2Wins = permute(e2Wins,[1 3 2]);
            
            [M,fmp,signal,time,gaborInfo] = mp(S,varargin)
        end
    end    
end


%% HelperFunction: sliceOutTriggers
% Inputs: spectrogram or spectrogram-like object, triggers and a window.

    function Sout = sliceOutTriggers(t,S,trig,win,varargin)
        
        optIn=inputParser;
        optIn.addParameter('celloutput',false,@islogical);
        optIn.parse(varargin{:});
        cellOutput = optIn.Results.celloutput;
        
        % Slice everything into a cell -- sizes will not always be equal
        % because sampling rate has variability
        Scell = {};
        for tr = 1:numel(trig)
            times = (t >= trig(tr) - win(1)) & (t <= trig(tr) - win(2));
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

%% HelperFunction: equalizeSizes
% Prupose: equalizes size of first dimension of all cell elements (time
% dimension in our use)
% Inputs: cells of eeg, spectrogram or spectrogram-like objects
    function dat = equalizeSizes(dat)
        
        if iscolumn(dat), dat=dat';end
        smallestSize = inf;
        
        for d = dat  
            this_size = size(d{1},1);
            
            if this_size < smallestSize
                smallestSize=this_size;
            end
        end
        
        dat = applySmallest(dat,smallestSize);
        
        %% HelperFunction: applySmallest
        % Purpose: applies smallest size of all cells
        function dat = applySmallest(dat,new_size)
            
            for i = 1:numel(dat)
                dat{i} = dat{i}(1:new_size,:);
            end
            
        end
        
    end
end