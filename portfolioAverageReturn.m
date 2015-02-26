% calcuate average of all the returns of the assets
% in the given portfolio
function [ averageReturn, returns ] = portfolioAverageReturn( portfolio )

% given portfolio of n*m
% n: opeservations
% m: assets
% required to calcuate the return per observation
% then calculate the average return

n = size(portfolio, 1);
returns = zeros(1, n);
for i=1:n
    returns(i) = mean(portfolio(i,:));
end

averageReturn = mean(returns);

end

