% select n assets from the given returns and tune their weights 
% to form an n-asset portfolio that best mimics the index
function [ weights, assetIdx ] = sparseIndexTracking( returns, index, maxAssets )

% given
% 1. assets of n*m
% n: opeservations
% m: assets
% 2. index is n*1
% n: opservations
% 3. maxAssets
% how many assets to select
% return
% 1. weights is k*1, weights of the selected assets
% k: is the number of the selected assets
% 2. assetIdx is k*1, the indeces of the selected assets

[n, m] = size(returns);

% taw for the penalty of the regularization
taw = 0.42;

% it is a minimization problem, so use cvx to do it
cvx_begin
   variable x(m,1)
   minimize(norm(index - (returns*x), 2) + norm((taw*x), 1))
   subject to
   x >= zeros(m,1)
cvx_end

% sort the weights
[weights, assetIdx] = sort(x, 'descend');

% select the top k weights
weights = weights(1:maxAssets);
assetIdx = assetIdx(1:maxAssets);

end

