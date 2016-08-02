function [out,logicalSlices] ...
    = getTime(structX,controls,inclusionPeriodFlag)
% This function handles the finding of inclusion periods.
% 
% Inputs: Any of the structs containing information about the
% experiment. Plus, one object called the controls. The controls
% determines how headband data will be used to slice out qualtiy data in
% all the major structures.
%
% Inputs:              
%           Stipulations ... controls can only be up to 2 fields deep
% Outputs: All of the experiment structures with bad timestamp elements
% removed

if ~(isrow(controls) || iscolumn(controls)) || ~iscell(controls)
    error('Improper control!');
end
if exist('inclusionPeriodFlag','var')
    inclusionPeriodFlag=false;
end

%% Get structural element requested, First N-1 = struct address
% Theese are strings that indicate what item to look at in the structure,
% addressed by element 1 through n-1

obj = structX;
for i = 1:numel(controls)-1
    obj = obj.(controls{i});
end

%% Last element in the control sequence
% This is given by "$val > something", "$val == something" or any
% expression you can do with val, where val will essentially be replaced by
% the any set of column vectors present in the struct field addressed by
% the first N-1 cell elements

% First, we apply the evaluate the statement to obtain a logical vetor of
% good times that fit our criteria
logicalSlices = implementControlStatement(obj, control{end});


% The vector needs to be translated into times

if isfield(structX,'timestamps') % if a field in the mother struct
    timestamps = structX.timestamps;
else % otherwise, it is the first column of the field of choice
    try
    timestamps = obj(:,1);
    catch
        error('Problem extracting timestamps');
    end
end

% Then, we translate this into either inclusion ranges, based on the
% timestamps, or as a list of timepoints our statement is valid.
if inclusionPeriodFlag,  out = getInclusionRange(timestamps,logicalSlices);
else,                    out = timstamps( logicalSlices ); 
end

%% Helper Function: implementControlStatement()
    function logicalSlices = implementControlStatement(obj,statement)
        % Substitute obj into the statement
        statement = strrep(statement,'$val','obj'); 
        % Evaluate statement
        logicalSlices = eval(statement);
    end
%% Helper Function: getInclusionRange()
    function incPeriods = getInclusionRange(timestamps,logicalSlices)
        % Carry out a diff of the logical arrays to identify ons
        ons = diff(logicalSlices,1,1) == 1;
        % Diff to identify offs
        offs = diff(logicalSlices,1,1) == -1;
        offs = circshift(offs,1,1); offs(1) = false;
        ons = find(ons); offs=find(offs);
    end
end