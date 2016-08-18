function plotBetaStruct(betaStruct,mapping)

figure(300);

s=[];
for i = 1:numel(mapping)
    s(i) = subplot( numel(mapping), 1, i);
    
    plot(betaStruct.(mapping{i}));
    title(strrep(mapping{i},'_','.'));
    
end

linkaxes(s,'y');

end