clc;

% load the data
load('data\q_2.mat');
assets = returns;

% if we want to experience a smaller portfolio
%returns = returns(:,12:20);

% returns need to be changed to percentages
% for each return, covert it from
% [100 120 150 100]
% to
% [0% 20% 50% 0%]
for i=1:size(assets,2)
    value = assets(1,i);
    assets(:,i) = (assets(:,i) - value)/value;
end
% now remove the first opservation (it is only zeros
% as it was used to convert returns to percentages)
assets = assets(2:end,:);

nAssets = size(assets,2);
nTotal = size(assets,1);

% get mean and covariance for these returns
% AssetMean = mean(assetsTrain);
% AssetCovar = cov(assetsTest);
AssetMean = mean(assets);
AssetCovar = cov(assets);
CashMean = 5/100;
weights = ones(nAssets, 1)/nAssets;

p = Portfolio('AssetMean', AssetMean, 'AssetCovar', AssetCovar, 'InitPort', weights);
p = setDefaultConstraints(p);
pwgt = estimateFrontier(p, 20);
[fRisk1, fReturn1] = estimatePortMoments(p, pwgt);

costs = linspace(0.05,0.3,5);
nCosts = length(costs);
fRisk2 = [];
fReturn2 = [];
for i=1:nCosts
    cost = costs(i);
    q = setCosts(p, cost, cost);
    qwgt = estimateFrontier(q, 20);
    [rk, rt] = estimatePortMoments(q, qwgt);
    fRisk2 = [fRisk2 rk];
    fReturn2 = [fReturn2 rt];
end

% calcuate the returns for the test data
%returns = assets * pwgt;

% plot the E-V graph
colormap = autumn(nCosts+2);
colormap = colormap(1:end-2,:);
figure(1); clf;
box on;
grid on;
hold on;
plot(fRisk1, fReturn1, 'b', 'LineWidth', 2);
for i=1:nCosts
    plot(fRisk2(:, i), fReturn2(:, i), 'LineWidth', 1.5, 'Color', colormap(i,:));
end
xlabel('Risk (V)', 'FontSize', 18);
ylabel('Expected Return (E)', 'FontSize', 18);
title('Efficient Portfolio Frontier', 'FontSize', 18);
fig_legend = legend('Efficient frontier', 'Efficient frontier with cost', 'Location', 'southeast');
set(fig_legend,'FontSize',16);










