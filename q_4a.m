clf;

% load the data
load('data\q_2.mat');

% if we want to experience a smaller portfolio
%returns = returns(:,12:20);

% returns need to be changed to percentages
% for each return, covert it from
% [100 120 150 100]
% to
% [0% 20% 50% 0%]
for i=1:size(returns,2)
    value = returns(1,i);
    returns(:,i) = (returns(:,i) - value)/value;
end
% now remove the first opservation (it is only zeros
% as it was used to convert returns to percentages)
returns = returns(2:end,:);

nAssets = size(returns,2);
nTotal = size(returns,1);
nTrain = int16(nTotal/2);
nTest = nTotal - nTrain;

% split the returns to train and test
returnsTrain = returns(1:nTrain,:);
returnsTest = returns(nTrain+1:nTotal,:);

% get mean and covariance for these returns
m = mean(returnsTrain);
c = cov(returnsTrain);

alpha = ones(1, nAssets)* 1/100;
s = ones(1, nAssets)* 0.005;

% get the weights
weights = ones(1, nAssets) *(1/nAssets);

% we'll use CVX to do the covex programming
cvx_begin
   variable x(NAssets,1)
   minimize( 0.5*x'*ECov*x + V0'*x)
   subject to
        V1 * x == 1;
        x >= V0;
cvx_end

% calcuate the returns for the test data
expcetedReturns = returnsTest * weights';

% plot the E-V graph
figure(1); clf;
box on;
grid on;
hold on;
plot(fRisk, fReturn, 'k', 'LineWidth', 2);
plot(fRisk, fReturn, '.r', 'MarkerSize', 20);
xlabel('Risk (V)', 'FontSize', 18);
ylabel('Expected Return (E)', 'FontSize', 18);
title('Efficient Portfolio Frontier', 'FontSize', 18);
fig_legend = legend('Efficient Frontier', 'Efficient Portfolio', 'Location', 'southeast');
set(fig_legend,'FontSize',16);

% plot the returns for the efficient protfolios
% vs. return from the naive portfolio
colormap = autumn(nPortfolios+2);
colormap = colormap(1:end-2,:);
figure(2); clf;
box on;
grid on;
hold on;
plot(returnsNaive, 'b', 'LineWidth', 3);
plot(returnsEfficientAverage, 'LineWidth', 3, 'Color', [0 0.7 0.2]);
expcetedReturns = fliplr(expcetedReturns);
for i=1:nPortfolios
    plot(expcetedReturns(:,i), 'LineWidth', 1, 'Color', colormap(i,:));
end
expcetedReturns = fliplr(expcetedReturns);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
title('Portfolio Return Over Time', 'FontSize', 18);
fig_legend = legend('Naive Portfolio', 'Efficient Portfolio Avg.', 'Efficient Portfolios', 'Location', 'northwest');
set(fig_legend,'FontSize',16);













