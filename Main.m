
% Handles analysis of the subject data from the Muse headset. It only uses
% subset of the capabilities I installed into the tools used in this code. 
% 
% The getTime functions for instance are capable of handling inclusion time
% ranges instead of specific trigger points, which is necessary when you
% need to condition the data on mutiple paramters.

% Flags
ploton = true;

% WHICH DATA TO LOAD
subjects = {...
    's0.masterstruct.mat',...
    's1.masterstruct.mat',...
    's2.masterstruct.mat',...
    's3.masterstruct.mat'...
    ...'s4.masterstruct.mat',...
    };

% ITERATE OVER SINGLE-SUBJECT SCRIPT
cSubject = 1;
for subject = subjects'
    
    load(subject)
    OneSubject;
    cSubject = cSubject + 1;
    
end

% Script outputs -- 
% (Normally I don't use scripts like this ... functions are better and less
% opaque)
% 


%% Combine data sets
% Have to ensure each of the rows contains the same number of data of each
% type

%% Prediction on half

%% Predict on the other half
