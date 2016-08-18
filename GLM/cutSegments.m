% function cutSegments()
% Purpose: Takes a list of inclusion ranges, where each range is one event
% and, and format data for the glm, per range/"trial". 
%
% INPUTS: controls -- 
%           List of cells that can work like the cellular portion of the
%           getTime controls. Each cell is a list of strings that together
%           index into a nested struct. This is how you can specify
%           multiples of variables to be put into the GLM.
%
%         ranges --
%           List of time inclusion ranges that are used to cut each trial
%           segment
%
% OUTPUTS: If the time ranges are different, it attempts to cut all vector
% sets from different data types to a common size.
% If 
function [data,id,mapping,counts] = cutSegments(structX,ranges,controls,varargin)

% Parse optional inputs
p = inputParser;
p.addParameter('equalize',false,@logical);
p.parse(varargin{:});
equalize=p.Results.equalize;

% For each control, collect the data, and deposit it into a cell. Also
% deposit a vector of equal size with a data identifier.
% ---- Instantiate variables before loop ---
cDataId = 1; % data counter

data    = cell(1,numel(controls));
id      = cell(1,numel(controls));
mapping = cell(1,numel(controls));
counts = cell(1,numel(controls));
% ----
for control = controls
    
    [data{cDataId}, id{cDataId}, counts{cDataId}] = ...
        grabControl(structX,ranges,control{1},cDataId);
    
    mapping{cDataId} = control{end};
    
    cDataId=cDataId + 1;
    
end

[data,id] = combineSamples(data,id);

% Now that we have all of this data splayed out into a nice format
% -- Mode 1: it's been equalized ..
% This means that we can simply create a matrix to return
if equalize
    
    data = cat(data,1);
    id = cat(id,1);
    
    return;
else
    % -- Mode 2: it's not been equalized ..
    % For execution safety, dump each trials worth of data into a cell
    return;
end

%% Helper function: grabControl
    function [data,identifiers,counts] = grabControl(structX,ranges,...
            control,cDataId)
        % Grabs sequences for a single variable and if option is on to
        % equalize lengths, then that is done. It returns three data types
        % - cell array of vectors of data,  cell array of identifies, a
        % cell symbolizing the mapping from identifier to data name
        
        % If it's the type of struct that has a timestamps field then
        % extract that ... otherwise! it ain't. timestamps are found
        % instead in the first column of whatever variable is examined
        if isfield(structX,'timestamps')
            % timestamps=structX.timestamps; % only if you add control
            % statement cuts
        end
        
        % Zero in on the object in the control
        obj=structX;
        for c = control
            obj=obj.(c{1});
        end
        
        % Instatitiate storage objects
        % ----
        data = cell(1,size(ranges,1));
        identifiers = cell(1,size(ranges,1));
        cRanges=1;
        % ----
        for r = ranges'
            slice = obj >= r(1) & obj <= r(2);
            data{cRanges} = reshape(obj(slice,2:end),[],1);
            identifiers{cRanges} = cDataId*ones(size(data{cRanges}));
            cRanges = cRanges + 1;
        end
        
        % if equalize flag on, then ensure
        if equalize
            data         = equalizeSizes(data);
            [identifiers,counts] = equalizeSizes(identifiers);
        else
            counts = NaN;
        end
        
    end

%% HelperFunction: equalizeSizes
% Prupose: equalizes size of first dimension of all cell elements (time
% dimension in our use)
% Inputs: cells of eeg, spectrogram or spectrogram-like objects
    function [dat,smallestSize] = equalizeSizes(dat)
        
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

%% Helper function: combineSamples
% Purpose .. takes the cells of separate data types, who each contain cells
% of the trial data, and combines them into a unified cell of trial data,
% and likewise for the identities
    function  [dataOut,identitiesOut] = combineSamples(data,identities)
        
        % Instantiate cells used to hold our results
        % --
        dataOut         = cell(1,numel(data{1}));
        identitiesOut   = cell(1,numel(data{1}));
        % --
        for d = 1:numel(data)
            
            dataOut{d} = singularCombine();
            identities{d} = singularCombine();
            
        end
        
        function out = singularCombine(data,d)
            out = [];
            for elem = data
                out = data{elem}{d};
            end
            if iscolumn(out), out=out'; end
        end
    end

end