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
function cutSegments(ranges,controls)

% For each control, collect the data, and deposit it into a cell. Also
% deposit a vector of equal size with a data identifier.
cDataId = 0;
for control = controls
    
    grabControl()
    
end

%% Helper function: grabControl

end