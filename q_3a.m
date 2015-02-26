clc;

% load the data
load('data\q_2.mat');

load('data\ftse.csv');
ftse = flipud(ftse);

% returns need to be changed to percentages
% for each return, covert it from
%[100 120 150 100] to [0% 20% 50% 0%]
for i=1:size(returns,2)
    value = returns(1,i);
    returns(:,i) = (returns(:,i) - value)/value;
end

% now remove the first opservation (it is only zeros
% as it was used to convert returns to percentages)
returns = returns(2:end,:);

% do the same for ftse
%ftse = (ftse - ftse(1))/ftse(1);
%ftse = ftse(2:end,:);

% for testing purpose, if we want the
% index to be the avarage of 20 assets we have
% not the real market index
[~, ftse] = portfolioAverageReturn(returns);
ftse = ftse';

nAssets = size(returns,2);
nTotal = size(returns,1);
nTrain = int16(nTotal/2);
nTest = nTotal - nTrain;

% split the returns to train and test
returnsTrain = returns(1:nTrain,:);
returnsTest = returns(nTrain+1:nTotal,:);
ftseTrain = ftse(1:nTrain);
ftseTest = ftse(nTrain+1:nTotal);

% now, with the Greedy-Forward Feature Selection (GFFS) algorithm
% how many assets we want our portfolio to contain
maxSelectedAssets = 6;

% array to contain the indeces of selected assets
selectedAssets = zeros(1, maxSelectedAssets);
unSelectedAssets = 1:nAssets;

% max-1 iterations to select the next max-1 assets
for i=1:maxSelectedAssets
    avgReturns = zeros(1,length(unSelectedAssets));
    sharpeRatios = zeros(1,length(unSelectedAssets));
    rmse = zeros(1,length(unSelectedAssets));
    for j=1:length(unSelectedAssets)
        % collect the assets inside the portfolio
        idx = [nonzeros(selectedAssets)' unSelectedAssets(j)];
        portfolioReturns = returnsTrain(:,idx);
        avgReturns(j) = portfolioAverageReturn(portfolioReturns);
        sharpeRatios(j) = portfolioSharpeRatio(portfolioReturns);
        rmse(j) = portfolioError(portfolioReturns, ftseTest);
    end
    % we have 3 ways to measure the performance
    % 1. Average Return
    % 2. Sharpe Ratio
    % 3. Compare to market index
    % pick up the asset with the highest average return/
    % highest Sharpe ratio/min error
    %[~, idx] = max(avgReturns);
    %[~, idx] = max(sharpeRatios);
    [~, idx] = min(rmse);
    selectedAssets(i) = unSelectedAssets(idx);
    unSelectedAssets(unSelectedAssets==selectedAssets(i)) = [];
end

% returns of our final portfolio
[~, avgReturnTrain] = portfolioAverageReturn(returnsTrain(:, selectedAssets));
[~, avgReturnTest] = portfolioAverageReturn(returnsTest(:, selectedAssets));

% plot results
figure(1); clf;

subplot(1,2,1);
hold on;
grid on;
box on;
for i=1:20
    if (ismember(i, selectedAssets))
        w = 1;
        c = [0 0.7 0.2];
        plot1 = plot(returnsTrain(:,i), 'LineWidth', w, 'Color', c);
    else
        w = 0.1;
        c = [0.7 0.7 0.7];
        plot2 = plot(returnsTrain(:,i), 'LineWidth', w, 'Color', c);
    end    
end
plot3 = plot(ftseTrain, 'b', 'LineWidth', 2);
plot4 = plot(avgReturnTrain, 'r', 'LineWidth', 2);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
title('Index Tracking (Training)', 'FontSize', 18);
fig_legend = legend([plot4, plot3, plot1, plot2], {'Our Portfolio', 'Market Index', 'Selected Assets', 'Unselected Assets'}, 'Location', 'northwest');
set(fig_legend,'FontSize',14);

subplot(1,2,2);
hold on;
grid on;
box on;
for i=1:20
    if (ismember(i, selectedAssets))
        w = 1;
        c = [0 0.7 0.2];
        plot1 = plot(returnsTest(:,i), 'LineWidth', w, 'Color', c);
    else
        w = 0.1;
        c = [0.7 0.7 0.7];
        plot2 = plot(returnsTest(:,i), 'LineWidth', w, 'Color', c);
    end
    
end
plot3 = plot(ftseTest, 'b', 'LineWidth', 2);
plot4 = plot(avgReturnTest, 'r', 'LineWidth', 2);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
title('Index Tracking (Testing)', 'FontSize', 18);
fig_legend = legend([plot4, plot3, plot1, plot2], {'Our Portfolio', 'Market Index', 'Selected Assets', 'Unselected Assets'}, 'Location', 'northwest');
set(fig_legend,'FontSize',14);











