clc;

% mean and covariance for all the assets the portfolio
mean = [0.1; 0.2; 0.15];
covariance = 100 * [0.005, -0.010, 0.004; -0.010 0.040 -0.002; 0.004, -0.002, 0.023];
N = 500;

% generate N random returns (normally distributed)
% for the 3-asset system (portfolio)
returns = mvnrnd(mean, covariance, N);

% get the frontier for the 3-asset portfolio, the return values
% are the risk, return and weights of the portfolio
[effRisk, effReturn, effWeights] = naiveMV(mean, covariance, N);

% another method to calcuate efficient forntier
%[pRisk, pReturn, pWeights] = frontcon(mean, covariance, N);

% another way to calcuate the frontier
portfolio = Portfolio('AssetMean', mean, 'AssetCovar', covariance);
portfolio = setDefaultConstraints(portfolio);
effWeights_ = estimateFrontier(portfolio);
[effRisk_, effReturn_] = estimatePortMoments(portfolio, effWeights_);

% generate N random portfolio, where a portfolio
% is just a combination of the 3 assets, the total of these
% ratios must be = 1. Example: portfolio P1 = (0.5*A1 + 0.2*A2 + 0.3*A3)
pWeights = zeros(N,3);
pWeights_ = zeros(N,3);
rand1 = 0;
rand2 = 0;
for i=1:N
    rand1 = rand;
    rand2 = rand;
    pWeights(i, :) = [min(rand1, rand2), abs(rand1 - rand2), 1 - max(rand1, rand2)];
end

% now, we want to calcuate the E (return),V (risk) of these portofolios
% simply, the previously created random weights will be applied
% on N assets' returns and calcuate the E,V for each portfolio
pRisk = zeros(N,1);
pReturn = zeros(N,1);
pRisk_ = zeros(N,1);
pReturn_ = zeros(N,1);
for i=1:N
    
    % wrong way to calcuate the return and risk
    % only required to get data cool to draw (well scattered)
    %pReturn(i) = sum(returns(i, :))/3;
    %pRisk(i) = norm(returns(i, :) - mean')^2;
    
    % the correct way to get risk and return
    pReturn(i) = pWeights(i, :) * returns(i, :)';
    pRisk(i) = norm(returns(i, :)*covariance*returns(i, :)');
    
    % another way (using Toolbox) to get risk and return
    [pRisk_(i), pReturn_(i)] = estimatePortMoments(portfolio, pWeights(i, :)');
end

% plot the E-V graph
figure(1); clf;
grid on;
hold on;
%daspect([20 1 1]);
%axis([-0.2,2.3,0.12,0.21]);
%scatter(pRisk, pReturn, 'filled', 'LineWidth', 0.2);
%plot(pRisk, pReturn, 'r', 'LineWidth', 1);
%plot(pRisk, pReturn, 'o', 'MarkerFaceColor','b', 'Color', 'w', 'MarkerSize', 5);
%plot(effRisk, effReturn, 'r', 'LineWidth', 2);
%plot(pRisk, pReturn, '.', 'MarkerSize', 10, 'Color', 'r');
plot(effRisk_, effReturn_, 'r', 'LineWidth', 3);
plot(pRisk_, pReturn_, '.', 'MarkerSize', 8, 'Color', 'b');
xlabel('Risk (V)', 'FontSize', 18);
ylabel('Expected Return (E)', 'FontSize', 18);
title('Efficient Portfolio Frontier', 'FontSize', 18);
fig_legend = legend('Frontier', 'Portfolio', 'Location', 'southeast');
set(fig_legend,'FontSize',16);




