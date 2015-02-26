function [out,val] = TargetFcn(W,cv,wts,Idx,Jdx)

% out = TargetFcn(W,cv,wts)
% 
% Target function for GA stocks selection problem. 
% Inputs: 
%       W: vector of the stocks we wish to invest in
%       cv: the covariance  matrix for the stocks in the full portfolio
%       wts: rtelative weights of the stocks in the portfolio.
%       Idx: Indices of weights we care about
%       Jdx: Indices of other stocks

if nargin < 4
    idx = W ~= 0;
    Idx = find(idx);
    Jdx = find(~idx);
else
    idx = ~isnan(W);
end

A = cv(Idx,Idx);

B = cv(Idx,Jdx);

V = [A,B]*wts([Idx(:); Jdx(:)])';

Aeq = ones(1,numel(W(idx)));
Beq = 1;
LB = zeros(numel(W(idx)),1);
UB = ones(numel(W(idx)),1);

% We use qplcprog - this requires R2008a
[val,out] = qplcprog(A,-V,[],[],Aeq,Beq,LB,UB);

end


