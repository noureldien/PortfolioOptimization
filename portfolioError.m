% calcuate the root-mean-square error between the given
% portfolio and the target
function [ rmse ] = portfolioError( portfolio, target )

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

rmse = sqrt(mean((returns' - target).^2));

end

