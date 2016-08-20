
% Handles analysis of the subject data from the Muse headset. It only uses
% subset of the capabilities I installed into the tools used in this code. 
% 
% The getTime functions for instance are capable of handling inclusion time
% ranges instead of specific trigger points, which is necessary when you
% need to condition the data on mutiple paramters.

ploton = true;
saveall=true;

% WHICH DATA TO LOAD
    subjects = {...
        's0.masterstruct.mat',...
        's1.masterstruct.mat',...
        's2.masterstruct.mat',...
        's3.masterstruct.mat'...
        's4.masterstruct.mat'
        };

% Controls which combo of properties to run the analysis with
% ---------
remove_practice = {'false','true'};
downsample = {'10','20','30','1'};
samplesize = {'10','50','100'};
% --------
counter=1;
for r = remove_practice
for d = downsample
for s = samplesize
    
    if counter < 4
        counter=counter+1;
        continue;
    end
    
    fprintf('Iteration %d\n',counter);pause(1);

    sVal = str2double(s{1});
    rVal = str2num(r{1});
    dVal = str2num(d{1});
    if sVal>10; subjploton=false; else; subjploton=true; end;
    
    foldername = sprintf('~/Data/Sekuler/RemovePract=%s_Downsamp=%s_SampSize=%s',...
        r{1},d{1},s{1});
    fprintf('Starting %s\n',foldername);pause(1);
    warning off; mkdir(foldername); warning on;

    outStruct=cell(1,numel(subjects));

    % ITERATE OVER SINGLE-SUBJECT SCRIPT
    cSubject = 1;
    for subject = subjects
        
        fprintf('Subject %d\n',cSubject);

        load(subject{1})
        
        outStruct{cSubject} = singleAnalysis(m, 'remove_practice', rVal,...
            'downsample', dVal, 'samplesize', sVal,...
            'folder',fullfile(foldername,['subject' num2str(cSubject)]),...
            'ploton',subjploton);
        
        cSubject = cSubject + 1;

    end
    
    clear m;
    close all;
    save(fullfile(foldername,'Complete'),'outStruct');
    
    %% Combine data sets
    % Have to ensure each of the rows contains the same number of data of each
    % type

    [dataR,idR,mappingR,RT] = combineSegments(outStruct,'RT');
    [dataC,idC,mappingC,CI] = combineSegments(outStruct,'CI');

    S = str2num(s{1});
    for s = 1:S
        %% GLM on half the data

        % Randomly sample half
        randsetC    = randperm( size(CI,1) );
        training    = randsetC(1:ceil(end/2));
        predicting  = randsetC(ceil(end/2)+1:end);

        % Run GLM
        [betaCI{s}, bCIStruct{s} ] = runGLM(CI(training,1),dataC(training,:),...
            idC(training,:),mappingC,'predictorName','Correct/Incorrect');

        % Run GLM
        [betaRT{s}, bRTStruct{s}] = runGLM(RT(training,1),dataR(training,:),...
            idR(training,:),mappingR,'predictorName','Reaction Time');

        %% Predict on the other half

        fprintf('\tSample %d - CORRECT INCORRECT\n',s);
        [YC(s).ypred,YC(s).a,YC(s).t,YC(s).p]...
            =analyzeGLM(dataC,CI(:,1),betaCI{s},...
                'runstats',{training,predicting},...
                'ploton',ploton);
        fprintf('\tSample %d - REACTION TIME\n',    s);
        [YR(s).ypred,YR(s).a,YR(s).t,YR(s).p]...
            =analyzeGLM(dataR,RT(:,1),betaRT{s},...
                'runstats',{training,predicting},...
                'ploton',ploton);

    end
    
    %% Combine stats

    combineStats(YC, @mean, 'mean','Correct/Incorrect');
    combineStats(YR, @mean, 'mean','ReactionTime');
    
    %% Save
    cd(foldername);
    save MultiSubjectAnalysis
    
    %% Save all figures

    warning off; mkdir(foldername); warning on;
    currdir=pwd; cd(foldername);


    h = get(0,'children');
    if saveall
        for i=1:length(h)
          fprintf('\nSaving %d', i);
          saveas(h(i), ['figure' num2str(i)], 'fig');
          saveas(h(i), ['figure' num2str(i)], 'png');
        end
    else
        for i=length(h)-1:length(h)
          fprintf('\nSaving %d', i);
          saveas(h(i), ['figure' num2str(i)], 'fig');
          saveas(h(i), ['figure' num2str(i)], 'png');
        end
    end

    counter=counter+1;
    
end
end
end