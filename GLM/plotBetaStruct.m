function plotBetaStruct(betaStruct,mapping,varargin)

figure;

p=inputParser;
p.addParameter('predictorName','',@ischar);
p.parse(varargin{:});
predictorName=p.Results.predictorName;

s=[];
for i = 1:numel(mapping)
    s(i) = subplot( numel(mapping), 1, i);
    
    plot(betaStruct.(mapping{i}));
    title([predictorName ': ' strrep(mapping{i},'_','.')]);
    
end

linkaxes(s,'y');

end