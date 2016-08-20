% Purpose: Function takes all of the different data an interleaves them.
% This is critical for a final post-processing before GLMing all subject
% data.
function [data,id,mapping,Y] = combineSegments(cellOfSubjects,subfield)


% Following section is unwritten section that was supposed to handle data
% that had not been downsampled. If it's downsampled to a commmon number,
% it doesn't have to be contrained or adjusted; all of the data from
% different subjects are the same size. If it HASN'T been downsampled,
% time-permitting, I was planning to flesh this section out to ensure it
% could handle different subjects' full data.
% 
% %% Estimate any scrubbing need to do
% % Get ready to obtain a matrix of samples taken per data type per subject
% if isrow(counts_cell), counts_cell=counts_cell';end;
% for i = 1:numel(counts_cell)
%     counts_cell{i} = counts_cell{i}';
% end
% 
% % TEST
% counts_cell = cat(counts_cell,1);
% minima = min(counts_cell,1);
% 
% %% Scrub all subjects for equal sizes
% 
% [structX,id_cell] = constrain(structX,id_cell,minima);
% 
% %% Concatonate all subjects
% 
% %% helper function: constrain
%     function [structX,id_cell] = constrain(structX,id_cell,minima)
%     end


% ---- INITIALIZE PLACE TO HOLD DATA COMBO
data = [];
id = [];
Y= [];
% ----
for c = 1:numel(cellOfSubjects)
    
    data = [data; cellOfSubjects{c}.(subfield).data];
    id = [id; cellOfSubjects{c}.(subfield).id];
    Y = [Y; cellOfSubjects{c}.(subfield).Y];
    
end

mapping = cellOfSubjects{1}.(subfield).mapping;

end