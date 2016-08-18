% Purpose: Function takes all of the different data an interleaves them.
% This is critical for a final post-processing before GLMing all subject
% data.
function combineSegments(structX,id_cell,counts_cell)

%% Estimate any scrubbing need to do
% Get ready to obtain a matrix of samples taken per data type per subject
if isrow(counts_cell), counts_cell=counts_cell';end;
for i = 1:numel(counts_cell)
    counts_cell{i} = counts_cell{i}';
end

% TEST
counts_cell = cat(counts_cell,1);
minima = min(counts_cell,1);

%% Scrub all subjects for equal sizes

[structX,id_cell] = constrain(structX,id_cell,minima);

%% Concatonate all subjects

%% helper function: constrain
    function [structX,id_cell] = constrain(structX,id_cell,minima)
    end

end