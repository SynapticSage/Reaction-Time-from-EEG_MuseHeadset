function [Ypred,...
    all,first,last] = analyzeGLM(X,Y,beta,varargin)

figure;clf;
subplot(2,1,1);
plot(beta);
title('Betas For Concatonated Data');
subplot(2,1,2);
plot(Y);
hold on;
Ypred = X*beta;
plot(Ypred);
title('Value vs Predicted on Training Set');
legend('Real','Prediction');

ind = [1 ceil(numel(Ypred)/2); ceil(numel(Ypred)/2)+1 numel(Ypred)];

if exist('varargin','var') && ~isempty(varargin) && isequal(varargin{1},'runstats')
    
    training = varargin{2}{1};
    predicting = varargin{2}{2};
    
    [a,all_p] = corrcoef(Y,Ypred); a=a(1,2);all_p=all_p(1,2);
    
    [firsthalf,f_p] = corrcoef(Y(training),Ypred(training));
    firsthalf=firsthalf(1,2);f_p=f_p(1,2);
    
    [lasthalf,l_p] = corrcoef(Y(predicting),Ypred(predicting)); 
    lasthalf=lasthalf(1,2);l_p=l_p(1,2);
    
    fprintf('\t------------------\n');
    fprintf('\tCorr coeff all %2.4f with p = %f\n',a,all_p);
    fprintf('\tCorr coeff firsthalf %2.4f with p = %f\n',firsthalf,f_p);
    fprintf('\tCorr coeff lasthalf %2.4f with p = %f\n',lasthalf,l_p);
    fprintf('\t------------------\n');
    
    first.p = f_p;
    first.r = firsthalf;
    last.p = l_p;
    last.r = lasthalf;
    all.p = all_p;
    all.r = a;
    
end

end