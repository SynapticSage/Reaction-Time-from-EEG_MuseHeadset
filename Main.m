
% Handles analysis of the subject data from the Muse headset. It only uses
% subset of the capabilities I installed into the tools used in this code. 
% 
% The getTime functions for instance are capable of handling inclusion time
% ranges instead of specific trigger points, which is necessary when you
% need to condition the data on mutiple paramters.

ploton = true;

% Controls which combo of properties to run the analysis with
% ---------
remove_practice = {'true','false'};
downsample = {'false','10','20'};
samplesize = {'10','50','100'};
% --------
for r = remove_practice
for d = downsample
for s = samplesize
    
    sVal = str2double(s{1});
    rVal = str2double(r{1});
    dVal = str2num(d{1});

    % WHICH DATA TO LOAD
    subjects = {...
        's0.masterstruct.mat',...
        's1.masterstruct.mat',...
        's2.masterstruct.mat',...
        's3.masterstruct.mat'...
        ...'s4.masterstruct.mat',...
        };
    outStruct=cell(1,numel(subjects));

    % ITERATE OVER SINGLE-SUBJECT SCRIPT
    cSubject = 1;
    for subject = subjects'

        load(subject)
        
        outStruct{cSubject} = singleAnalysis(m, ...
            'remove_practive', rVal, 'downsample', dVal, 'samplesize', sVal);
        
        cSubject = cSubject + 1;

    end

    % Script outputs -- 
    % (Normally I don't use scripts like this ... functions are better and less
    % opaque)
    % 


    %% Combine data sets
    % Have to ensure each of the rows contains the same number of data of each
    % type

    comboRT = combineSegments(outStruct,'RT');
    comboCI = combineSegments(outStruct,'CI');

    %% GLM on half the data
    
    [betaCI, bCIStruct ]= runGLM(,,),...
        identities,mapping);
    %
    [betaRT, bRTStruct] = runGLM(,,),...
        identities,mapping);

    %% Predict on the other half
    
    
    
end
end
end