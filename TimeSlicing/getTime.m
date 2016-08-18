function [out,logicalSlices] ...
    = getTime(structX,controls,varargin)
% function [out,logicalSlices] = getTime(structX,controls,inclusionPeriodFlag)
% This function handles the finding of inclusion periods.
% 
% Inputs:            Any of the structs containing information about the
%                    experiment. Plus, one object called the controls. The
%                    controls determines how headband data will be used to
%                    slice out qualtiy data in all the major structures.
%                    Another mode is possibly by setting the inclusion flag
%                    to a [time_before time_after] window, which sets the
%                    function into windowing mode. It will output inclusion
%                    times, where each inclusion period is a window.
%
% Outputs: out  ..  timestamps at which the control statement is true OR
%                   inclusion ranges at which the statement is true! The
%                   latter is IMPORTANT. Because the game,eeg,and behavior
%                   have different timestamps at which their information is
%                   deposited in the data. This implies you have to work
%                   with inclusion periods, that is, for example, the jaw
%                   is clenched starting at time X and ending at time Y.
%                   This contrasts with the output when inclusionPeriodFlag
%                   is set to false, that outputs the list of timestamps
%                   for that data type in which the control statement is
%                   true!
% 
%   logicalSlices.. binary vector indicating the times in the timestamp
%                   vector where the control statement is true.

% Check controls for flaws
if ~(isrow(controls) || iscolumn(controls)) && ~(iscell(controls) || ischar(controls))
    error('Improper control!');
end


% Parse optional inputs
p = inputParser;
p.addParameter('useinclusion',true,@islogical);     
p.addParameter('eachseparate',false,@islogical);
p.addParameter('window',[0 0],@(x) isnumeric(x) && numel(x)==2 && ~sum(x<0));
p.parse(varargin{:});
% Set variables controlled by optionals
inclusionPeriodFlag = p.Results.useinclusion;
eachSeparateFlag = p.Results.eachseparate; window = p.Results.window; 


%% Get structural element requested, First N-1 = struct address
% Theese are strings that indicate what item to look at in the structure,
% addressed by element 1 through n-1

obj = structX;
if iscell(controls) && numel(controls) > 1
    for i = 1:numel(controls)-1
        obj = obj.(controls{i});
    end
end

%% Last element in the control sequence
% This is given by "$val > something", "$val == something" or any
% expression you can do with val, where val will essentially be replaced by
% the any set of column vectors present in the struct field addressed by
% the first N-1 cell elements

% First, we apply the evaluate the statement to obtain a logical vetor of
% good times that fit our criteria
if ~isempty(obj)
    if ischar(controls)
        controls = {controls};
    end
    logicalSlices = implementControlStatement(obj, controls{end});
else
    error('Location is empty!');
end


% The vector needs to be translated into times

if isfield(structX,'timestamps') % if a field in the mother struct
    timestamps = structX.timestamps;
else % otherwise, it is the first column of the field of choice
    try
    if size(obj,2) == 1, error('No timestamps in this object.'); end;
    timestamps = obj(:,1);
    catch
        error('Problem extracting timestamps');
    end
end

% Then, we translate this into either inclusion ranges, based on the
% timestamps, or as a list of timepoints our statement is valid.
if inclusionPeriodFlag
    if eachSeparateFlag
        out = [timestamps( logicalSlices ) - window(1)...
            timestamps( logicalSlices ) + window(2)]; 
    else
        out = getInclusionRange(timestamps,logicalSlices);
    end
else 
    out = timestamps( logicalSlices ); 
end

%% Helper Function: implementControlStatement()
    function logicalSlices = implementControlStatement(obj,statement)
        assert(~isempty(obj),'Cannot run control statement on empty obj.');
        % Substitute obj into the statement
        statement = strrep(statement,'$val','obj'); 
        % Evaluate statement
        try
            logicalSlices = eval(statement);
        catch
            error('Invalid control statement! Please check.');
        end
    end
%% Helper Function: getInclusionRange()
    function includePeriods = getInclusionRange(time,included)
       % includePeriods = getInlcudePeriods(time, included)
        % Calculates the start and end times for all exclusion periods, given a
        % time vector and an include vector of 1s and 0s of the same length.
        
        assert(isrow(included)||iscolumn(included),'Your control statement outputs more than a single row or column.');
        
        % Ensure time is a column
        if isrow(time), time=time(:); end

        % Check for equal length of included binary vector and time
        if (length(time) ~= length(included))
            error('The TIME and INCLUDED vectors must me the same length');
        end

        % Discover start and stop times
        starttimes = find((diff(included) == 1))+1;
        starttimes = starttimes(:);
        endtimes = find((diff(included) == -1));
        endtimes = endtimes(:);
        if (included(1) == 1)
            starttimes = [1; starttimes];
        end
        if (included(end) == 1)
            endtimes = [endtimes; length(included)];
        end
        
        if numel(starttimes) > numel(endtimes)
            if starttimes(1) < endtimes(1)
                starttimes(1) = [];
            else
                starttimes(end) = [];
            end
        elseif numel(endtimes) > numel(starttimes)
            if endtimes(1) < starttimes(1)
                endtimes(1) = [];
            else
                endtimes(end) = [];
            end
        end
    
        % Create inclusion vector
        includePeriods = [time(starttimes) time(endtimes)];
        
        assert( sum(starttimes-endtimes) <= 0 );
    end
end