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
ftse = (ftse - ftse(1))/ftse(1);
ftse = ftse(2:end,:);

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

% get the weights and assets by doing lasso regression
[weights, selectedAssets] = sparseIndexTracking(returnsTrain, ftseTrain, maxSelectedAssets);

% returns of our final portfolio
avgReturnTrain = returnsTrain(:, selectedAssets)*weights;
avgReturnTest = returnsTest(:, selectedAssets)*weights;

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
plot3 = plot(ftseTrain, 'b', 'LineWidth', 4);
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
plot3 = plot(ftseTest, 'b', 'LineWidth', 4);
plot4 = plot(avgReturnTest, 'r', 'LineWidth', 2);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
title('Index Tracking (Testing)', 'FontSize', 18);
fig_legend = legend([plot4, plot3, plot1, plot2], {'Our Portfolio', 'Market Index', 'Selected Assets', 'Unselected Assets'}, 'Location', 'northwest');
set(fig_legend,'FontSize',14);










