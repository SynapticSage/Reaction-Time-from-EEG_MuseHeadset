function structX = applyTimes(structX,ranges)
% This function applies time inclusion ranges to any of the game, eeg,
% behavior structs

% Flags
reporton = true;
global location;
location = {};

% Figure out the timestamp determination mode ... whether there is one
% timestamp set for the entire list of variables in structX (e.g. if
% structX is "game"), or if there is unique timestamp per field in the
% struct (in which case it's the first column of the field, e.g., the
% behavior and eeg structs derived from Muse)
if isfield(structX, 'timestamps')
    timestampMode = 1;
    timestamps = structX.timestamps;
else
    timestampMode = 2;
end

% Now we need to loop through all the field structure and apply this time
% range to each of the terms. We handle that with a recursive strategy
% herein.
structX = recurse(structX,ranges);

%% Helper function: recurse
    function obj = recurse(obj,ranges)
        % Handles the recursion through the struct fields, no matter how
        % deep they go
        
        % Does this object have multiple fields?
        if isstruct(obj) &&numel(fields(obj)) > 0
            
            % RECURSE through the fields
            for f = fields(obj)'
                location{end+1}=[f{1} '.'];
                obj.(f{1}) = recurse(obj.(f{1}),ranges);
                if ~isempty(location)
                    location=location(1:end-1);
                end
            end
            
        else
            % No fields! Make sure it's not a struct, because that would
            % imply it is empty
            if isstruct(obj)
                error('Empty struct encountered! Fix me.');
            elseif isnumeric(obj) && ~isscalar(obj)
                % Paydirt, a matrix/vector
                obj = apply(obj,ranges);
            else
                warning off; % Comment this line out, if you'd like to see what data it's skipping
                warning('Unsupported type .. not processing %s',...
                    class(obj));
                warning on;
            end
        end
    end

%% Helper function
    function out = apply(obj,ranges)
        % Handles the actual application of the time ranges
        
        if reporton
            fprintf('Applying to .. %s\n', strcat(location{:}));
        end
        
        % Get a binary vector of the times that match the ranges
        masterslice = zeros(size(obj,1),1);
        for r = size(ranges,1)
            
            if timestampMode == 2
                timestamps = obj(:,1);
            end
            
            slice = timestamps > ranges(r,1) & timestamps < ranges(r,2);
            masterslice = slice | masterslice;
            
        end
        
        % Cut only the values in the inclusion ranges
        out = obj(masterslice,:);
        
    end

end