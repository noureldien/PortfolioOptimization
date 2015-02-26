clc;

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
rMean = mean(returnsTrain);
rCovar = cov(returnsTrain);

% simluated returns, help for testing
%returnsTrainSim = mvnrnd(rMean, rCovar, nTotal);

% calcuate efficient forntier
[fRisk, fReturn, fWeights] = frontcon(rMean, rCovar);
nPortfolios = size(fWeights,1);

% also calcuate the efficient frontier for test data
% just for the sake of comparison
%[fRiskSim, fReturnSim, fWeightsSim] = frontcon(mean(returnsTest), cov(returnsTest));

% get the weights for one portfolio using naiive method (i.e 1/n)
% i.e. portfolio consists of assets with the same weights
naiveWeights = ones(1, nAssets) *(1/nAssets);

% calcuate the returns for the test data using the 2 different
% weights: the efficient-frontier weights, and the naiive weights
returnsEfficient = zeros(nTest, nPortfolios);
for i=1:nPortfolios
    returnsEfficient(:,i) = returnsTest * fWeights(i,:)';
end
returnsNaive = returnsTest*naiveWeights';

% get the average of all efficient returns
% notice, we only want to get the average on non
returnsEfficientAverage = zeros(nTest, 1);
for i=1:nTest
    returnsEfficientAverage(i) = mean(returnsEfficient(i,:));
end

% now, we want to calcuate the Sharpe Ratio for the returns
% with risk free = 5%
riskFree = 20/100;
sharpeEfficient = zeros(1, nPortfolios);
for i=1:nPortfolios
    sharpeEfficient(i) = (mean(returnsEfficient(:,i)) - riskFree)/std(returnsEfficient(:,i));
end
sharpeNaive = (mean(returnsNaive) - riskFree)/std(returnsNaive);
sharpeEfficientAverage = mean(sharpeEfficient);

% % visualize the pair-wise correlation
% % for the pair-wise returns of 2 stocks
% figure(1);clf;
% box on;
% grid on;
% hold on;
% daspect([1 1 1]);
% plot(returnsTrain(:,1), returnsTrain(:,2), '.r');
% plot(returnsTrain(:,2), returnsTrain(:,3), '.b');
% plot(returnsTrain(:,1), returnsTrain(:,3), '.k');
% plot(returnsTest(:,1), returnsTest(:,2), '.g');
% plot(returnsTest(:,2), returnsTest(:,3), '.g');
% plot(returnsTest(:,1), returnsTest(:,3), '.g');
% 
% % visualize the pair-wise correlation but
% % on the simulated return
% figure(2);clf;
% box on;
% grid on;
% hold on;
% daspect([1 1 1]);
% plot(returnsTrainSim(:,1), returnsTrainSim(:,2), '.r');
% plot(returnsTrainSim(:,2), returnsTrainSim(:,3), '.b');
% plot(returnsTrainSim(:,1), returnsTrainSim(:,3), '.k');

% plot the E-V graph (efficient frontier we get from the train data)
figure(3); clf;
box on;
grid on;
hold on;
%plot(fRiskSim, fReturnSim, 'r', 'LineWidth', 3);
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
figure(4); clf;
box on;
grid on;
hold on;
plot(returnsNaive, 'b', 'LineWidth', 3);
plot(returnsEfficientAverage, 'LineWidth', 3, 'Color', [0 0.7 0.2]);
returnsEfficient = fliplr(returnsEfficient);
for i=1:nPortfolios
    plot(returnsEfficient(:,i), 'LineWidth', 1, 'Color', colormap(i,:));
end
returnsEfficient = fliplr(returnsEfficient);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
title('Portfolio Return Over Time', 'FontSize', 18);
fig_legend = legend('Naive Portfolio', 'Efficient Portfolio Avg.', 'Efficient Portfolios', 'Location', 'northwest');
set(fig_legend,'FontSize',16);

% plot the sharpe values
colormap = autumn(nPortfolios);
figure(5); clf;
box on;
grid on;
hold on;
plot([1 nPortfolios], [sharpeNaive sharpeNaive], 'LineWidth', 2, 'Color', 'b');
plot([1 nPortfolios], [sharpeEfficientAverage sharpeEfficientAverage], 'LineWidth', 2, 'Color', [0 0.7 0.2]);
sharpeEfficient = fliplr(sharpeEfficient);
for i=1:nPortfolios
    plot(i, sharpeEfficient(i), '.r', 'MarkerSize', 30, 'Color', colormap(i,:));
    plot(i, sharpeEfficient(i), '.k', 'MarkerSize', 10);
end
sharpeEfficient = fliplr(sharpeEfficient);
xlabel('Portfolio', 'FontSize', 18);
ylabel('Ratio', 'FontSize', 18);
title(strcat('Sharpe Ratio - Risk Free:', int2str(riskFree*100) ,'%' ), 'FontSize', 18);
fig_legend = legend('Naive Portfolio', 'Efficient Portfolio Avg.', 'Efficient Portfolios', 'Location', 'southwest');
set(fig_legend,'FontSize',14);





















