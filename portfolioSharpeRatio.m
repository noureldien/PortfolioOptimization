% calcuate the Sharpe ratio for all the returns of the assets
% in the given portfolio
function [ sharpeRatio ] = portfolioSharpeRatio( portfolio )

% given portfolio of n*m
% n: opeservations
% m: assets
% required to calcuate the return per observation
% then calcuate the sharpe ratio for these returns

n = size(portfolio, 1);
returns = zeros(1, n);
for i=1:n
    returns(i) = mean(portfolio(i,:));
end

% now, we want to calcuate the Sharpe Ratio for the returns
% with risk free = 5%
riskFree = 5/100;
sharpeRatio = (mean(returns) - riskFree)/std(returns);

end

