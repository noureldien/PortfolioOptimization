clc;
close all;

N_total = 113;
N_train = int16(N_total/2);
N_test = N_total - N_train;

% load the data
load('data\q_2.mat');

% collect all the prices of the stocks in one big matrix
stocks = [IHG, HSBC, ABF];

% for each stock, get only the close price
% this will be considered as the return for this stock
% we will depend on only the close price, which is the 4th column
returns = [stocks(:,4 + 0*6), stocks(:,4 + 1*6), stocks(:,4 + 2*6)];

% split the returns to train and test
returns_train = returns(1:N_train,:);
returns_test = returns(N_train+1:N_total,:);

% get mean and covariance for these returns
rMean = mean(returns_train);
rCovar = cov(returns_train);

% simluated returns, help for testing
returns_ = mvnrnd(rMean, rCovar, N_total);

% calcuate efficient forntier
[effRisk, effReturn, effWeights] = frontcon(rMean, rCovar, N_total);

% now use the weights from the efficient frontier
% to 

% visualize the pair-wise correlation
% for the pair-wise returns of 2 stocks
figure(1);clf;
box on;
grid on;
hold on;
daspect([1 1 1]);
plot(returns(:,1), returns(:,2), '.r');
plot(returns(:,2), returns(:,3), '.b');
plot(returns(:,1), returns(:,3), '.k');

% visualize the pair-wise correlation but
% on the simulated return
figure(2);clf;
box on;
grid on;
hold on;
daspect([1 1 1]);
plot(returns_(:,1), returns_(:,2), '.r');
plot(returns_(:,2), returns_(:,3), '.b');
plot(returns_(:,1), returns_(:,3), '.k');

% plot the E-V graph
figure(3); clf;
box on;
grid on;
hold on;
plot(effRisk, effReturn, 'k', 'LineWidth', 3);
xlabel('Risk (V)', 'FontSize', 18);
ylabel('Expected Return (E)', 'FontSize', 18);
title('Efficient Portfolio Frontier', 'FontSize', 18);











