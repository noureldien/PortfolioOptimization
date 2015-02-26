%% Batch Run Results

load BatchRunData
D = IndexFund.Dates;
figure('position',fpos,'numbertitle','off','name','Results of Batch Run');

plot(D,ValInd,'color','k','linewidth',2);
strs{1} = 'Index';

for ii = 1:numel(Val)
    if A(ii) == .001
        col = 'b';
    elseif A(ii) == .0050
        col = 'g';
    else
        col = 'r';
    end
    line(D,Val{ii}(:),'color',col);
    strs{ii+1} = ['N = ',sprintf('%2.2g',NN(ii)),...
        ', \alpha = ',sprintf('%2.2g',A(ii)),...
        ', \beta = ',sprintf('%2.2g',B(ii))];
end
title('Results of Batch run varying Number of stocks used (N) "Soft Target" (\alpha) and "Hard Target" (\beta)',...
    'fontsize',18);

datetick('x');

legend(strs,'location','sw');