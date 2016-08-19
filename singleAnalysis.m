function [outStruct] = singleAnalysis(m,varargin)

close all;

%% Flags
saveall=false;
p = inputParser;
p.addParameter('ploton',false,@islogical);
p.addParameter('remove_practice',false,@islogical);
p.addParameter('downsample',false,@isreal);
p.addParameter('samplesize',1,@isnumeric);
p.addParameter('folder','~/Data/Sekuler/default',@ischar);
p.parse(varargin{:});

ploton=p.Results.ploton;
remove_practice=p.Results.remove_practice;
downsampleSize=p.Results.downsample;
samplesize = p.Results.samplesize;
folder = p.Results.folder;

% PRINT PROPERTIES TO SCREEN -- to let user know what mode is being used
words = {'False','True'};
fprintf('\nMODES');
fprintf('\n------------');
fprintf('\nRemove Practice Sessions \t => %s',words{remove_practice+1});
fprintf('\DownSample \t\t\t => %s',words{(downsampleSize>0) +1});
fprintf('\n------------\n');

%% Constrain data to times to "good data"
% So far, in this section, this only means when the headband is detected as
% connected. It could in principal with the functions I've written be
% improved by excluding times in which one or more electrodes were detected
% as having a poor connection.

% First, let's select a subset of the data where the headband is definitely
% on and connected.
% 
% Here, I set up a control cell. Each 1 through N-1 cell element specifies
% the nested struct fields to dive down into. The last element is a control
% statement to select times you want. These can either be specific times
% it's true, or inclusion ranges. If you plan to constrain all of your data
% which can be in different time bases, then use inclusion periods.
controls = {'$val(:,2) > 0'};
[touching_ranges, ~] = getTime(m.beh.headband.touching_forehead,controls);

% Show that range is capture
if ploton
    figure;
    plot(...
        m.beh.headband.touching_forehead(:,1),...
        m.beh.headband.touching_forehead(:,2)...
        );
    hold on;
    a=gca; a.YLim = [-inf a.YLim(2)+1];
    for row = 1:size(touching_ranges,1)
        vline(touching_ranges(row,1),'g:','start');
        vline(touching_ranges(row,2),'r:','stop');
    end
end

% Now we should figure out times at which the electrodes are giving ogod
% signals
isgood = m.beh.headband.is_good(:,2:end);
% Get best mean
[M,i] = max(mean(isgood,1)); s = std( isgood(:,i),1 );
badelectrodes = find( mean(isgood,1) > (M+2*s) | mean(isgood,1) < (M-2*s) );
clear M i s;

% Now here, we apply the ranges found in which the headset was detected as
% on to all of the struct elements
m = applyTimes(m, touching_ranges);

%% If user requests to remove training levels, strip them from the data

if remove_practice
    nonTrainingEvent    = getTime(m.game.level, '$val(:,2) > 5');
    nonTrainingEvent    = applyTimes(m, nonTrainingEvent);
end

%% Remove all entries in the game data that represent eventIds not = 1
% This is because there are multiple eventTypes per rewarded and
% recation-timed event.

only1stEvent    = getTime(m.game.eventType, '$val(:,2) == 1');
m.game          = applyTimes(m.game, only1stEvent);

%% Acquire key times for correct/incorrect and highRT/lowRT

window = [2.5 0]; % 2 seconds before .. 0 seconds after

% Acquire incorrect and correct timestamp ranges
correct     = getTime(m.game.correct,'$val(:,2) == 1',...
    'eachseparate',true,'window',window);
incorrect   = getTime(m.game.correct,'$val(:,2)==-1', ...
    'eachseparate',true,'window',window);

% Compute upper and lower quantile of reaction times
rtMedian = median(m.game.RT(:,2));
highRT = getTime(m.game.RT, ['$val(:,2) >= ' num2str(rtMedian)],...
    'eachseparate',true,'window',window);
lowRT = getTime(m.game.RT,['$val(:,2) < ' num2str(rtMedian)],...
    'eachseparate',true,'window',window);


%% (Optional) Acqruire Spectra/Coherence/MP at Triggers

% The following doesn't work (yet!) with the currect data. Chronux and MP
% code has to be tweaked, such that, when they take their ffts, to obtain
% energy, we have to force them to instead take log(abs(energy)) ... for MP
% algo called by MP(), this means changing a the lines in the C++ code
% where fft computed, and recompiling. For Chronux, change fft() outputs in
% each of the matlab functions.

% [C_correct,S_correct,fsc_correct,M_correct,fmp_correct] = ...
%     triggeredCS( m.eeg, 'triggers', correct, 'window', window, 'matchingpursuit',true);
% [C_incorrect,S_incorrect,fsc_incorrect,M_incorrect,fmp_incorrect] = ...
%     triggeredCS( m.eeg, 'triggers', incorrect, 'window', window, 'matchingpursuit',true);

%% Subject-specific Correct/Incorrect Matrix and RT-high-low matrix

% (1) Time sorted C-I ranges
C = [ ones(size(correct,1),1) correct ];
I = [ zeros(size(incorrect,1),1) incorrect ];
CI = [C; I]; CI = sortrows(CI,2);

% (2) Time sorted high low RT ranges
H = [ ones(size(highRT,1),1) highRT ];
L = [ zeros(size(lowRT,1),1) lowRT ];
RT = [H; L]; RT = sortrows(RT,2);
RT(:,1) = (m.game.RT(:,2));

% Clean up shop, some
clear correct incorrect lowRT highRT C I H L;

%%  Acquire GLM variables given those windows of time

% Cut times
mCI = applyTimes(m, CI(:,2:3));
mRT = applyTimes(m, RT(:,2:3));

% Slice out first half of time
% half_times = getTime(eeg.raw,'$val(:,1) > median($val(:,1))');
% m_half = applyTimes(m,half_times);

%---------
% Cut segements of data into GLMable matrices, with appropriate meta data
% to help reconstruct the managerie of different data in each trial row of
% the matrix
% -- Correct / Incorrect
% Format of controls input:


controls ={...
    {'eeg','abs','theta'},...
    {'eeg','abs','delta'},...
    {'eeg','abs','gamma'},...
    {'eeg','abs','beta'},...
    {'eeg','abs','alpha'}
    };

[dataC,idC,mappingC] = ...
    cutSegments(mCI,CI(:,2:3),controls,'equalize',true,'downsample',downsampleSize);
% -- Reaction-time Slow / Reaction-time Fast
[dataR,idR,mappingR] = ...
    cutSegments(mRT,RT(:,2:3),controls,'equalize',true,'downsample',downsampleSize);

% INITIALIZE TRACKERS
% ----
YC=struct('ypred','','a','','t','','p','') ;
YR=struct('ypred','','a','','t','','p','') ;
betaCI = {}; bCIStruct = {};
betaRT = {}; bRTStruct = {};
% -----
for s = 1:samplesize
    %% GLM on half the data

    % Randomly sample half
    randsetC    = randperm( size(CI,1) );
    training    = randsetC(1:ceil(end/2));
    predicting  = randsetC(ceil(end/2)+1:end);

    % Run GLM
    [betaCI{s}, bCIStruct{s} ] = runGLM(CI(training,1),dataC(training,:),...
        idC(training,:),mappingC);

    % Run GLM
    [betaRT{s}, bRTStruct{s}] = runGLM(RT(training,1),dataR(training,:),...
        idR(training,:),mappingR);

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
    
%% Package outputs

outStruct.CI=struct();
outStruct.RT=struct();

outStruct.CI.pred = YR;
outStruct.RT.pred = YC;

outStruct.CI.beta = betaCI;
outStruct.RT.beta = betaRT;

outStruct.RT.betaSegments = bRTStruct;
outStruct.CI.betaSegments = bCIStruct;

%% Save all figures

warning off; mkdir(folder); warning on;
currdir=pwd; cd(folder);


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
    
cd(currdir);

end