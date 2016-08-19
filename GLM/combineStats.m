function [allR,allP,trainR,trainP,predictR,predictP] = combineStats(YC,...
    func,funcName,type)

ploton = true;


% Pull out vector of pearson coefficients and p-values for all the
% resampled sets
% --- All trials
allR = {YC.a}; allR = cat(2,allR{:});
allR = {allR.r}; allR = cat(2,allR{:});
allP = {YC.a}; allP = cat(2,allP{:});
allP = {allP.p}; allP = cat(2,allP{:});
% --- Training trials
trainR = {YC.t}; trainR = cat(2,trainR{:});
trainR = {trainR.r}; trainR = cat(2,trainR{:});
trainP = {YC.t}; trainP = cat(2,trainP{:});
trainP = {trainP.p}; trainP = cat(2,trainP{:});
% --- Predictor trials
predictR = {YC.p}; predictR = cat(2,predictR{:});
predictR = {predictR.r}; predictR = cat(2,predictR{:});
predictP = {YC.p}; predictP = cat(2,predictP{:});
predictP = {predictP.p}; predictP = cat(2,predictP{:});

if exist('func','var')
    
    fprintf([...
            '\n ---------' ...
            '\n META %s',    ...
            '\n ---------' ...
            ],funcName);
    
    list = {'allR','allP','trainR','trainP','predictR','predictP'};

    for term = list
        
        fprintf('\n %s: %s = %d', funcName, term{1}, func(eval(term{1})));
        
    end

    if ploton
        binlim = [0.1,0.2];
        
        figure;clf;
        subplot(2,2,1);
        histogram( sort(allR) ); hold on;
        h=histogram( sort(trainR) );
        h.BinWidth=0.05;
        histogram( sort(predictR));
        title([type ': Pearson''s R Values - Different Subsamples']);
        legend('All','Train','Predict');
        axis([0 1 -inf inf]);
        subplot(2,2,2);
        histogram( sort(allP) ); hold on;
        h=histogram( sort(trainP) );
        h.BinWidth=0.05;
        histogram( sort(predictP));
        axis([0 1 -inf inf]);
        legend('All','Train','Predict');
        title([type ': Pearson''s P Values - Different Subsamples']);
        
        subplot(2,2,3);
        scatter( 1:numel(allR), sort(allR) ); hold on;
        scatter( 1:numel(allR), sort(trainR) );
        scatter( 1:numel(allR), sort(predictR));
        title([type ': Pearson''s R Values - Different Subsamples']);
        legend('All','Train','Predict');
        subplot(2,2,4);
        scatter( 1:numel(allR), sort(allP) ); hold on;
        scatter( 1:numel(allR), sort(trainP) );
        scatter( 1:numel(allR), sort(predictP));
        legend('All','Train','Predict');
        title([type ': Pearson''s P Values - Different Subsamples']);
        
    end
    
end

end