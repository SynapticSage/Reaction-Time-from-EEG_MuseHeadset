function [data,id,mapping,CI,RT,extra] = singleAnalysis(m)

%% Flags
ploton=false;

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

%% Remove all entries in the game data that represent eventIds not = 1
% This is because there are multiple eventTypes per rewarded and
% recation-timed event.

only1stEvent    = getTime(m.game.eventType, '$val(:,2) == 1');
m.game          = applyTimes(m.game, only1stEvent);

%% Acquire key times for correct/incorrect and highRT/lowRT

window = [2 0]; % 2 seconds before .. 0 seconds after

% Acquire incorrect and correct timestamp ranges
correct     = getTime(m.game.correct,'$val(:,2) == 1',...
    'eachseparate',true,'window',window);
incorrect   = getTime(m.game.correct,'$val(:,2)==-1', ...
    'eachseparate',true,'window',window);

% Compute upper and lower quantile of reaction times
rtMedian = median(m.game.RT(:,2));
highRT = getTime(m.game.RT, ['$val(:,2) > ' num2str(rtMedian)],...
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
controls ={...
    {'eeg','abs','theta'},...
    {'eeg','abs','delta'},...
    {'eeg','abs','gamma'},...
    {'eeg','abs','beta'},...
    {'eeg','abs','alpha'}
    };
[dataC,idC,mappingC] = ...
    cutSegments(mCI,CI(:,2:3),controls,'equalize',true);
% -- Reaction-time Slow / Reaction-time Fast
[dataR,idR,mappingR] = ...
    cutSegments(mRT,RT(:,2:3),controls,'equalize',true);


%% GLM on half the data

%
[betaCI, bCIStruct ]= runGLM(CI(1:ceil(end/2),1),dataC( 1:ceil(end/2),:),...
    idC(1:ceil(end/2),:),mappingC);
%
[betaRT, bRTStruct] = runGLM(RT(1:ceil(end/2),1),dataR( 1:ceil(end/2),:),...
    idR(1:ceil(end/2),:),mappingR);

%% Predict on the other half

plotGLM(dataC,CI(:,1),betaCI);
plotGLM(dataR,RT(:,1),betaRT);


%% Package additional outputs
extra.predictCI = yCIpredict;
extra.predictRT = yRTpredict;

extra.bCI = betaCI;
extra.bRT = betaRT;

extra.struct_bRT = bRTStruct;
extra.struct_bCI = bCIStruct;

end