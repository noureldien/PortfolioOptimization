% given ERet which is the expected return, ECov, which
% is the expected risk
function [PRisk, PRoR, PWts] = naiveMV_CVX(ERet, ECov, NPts)

% makes sure it is a column vector
ERet = ERet(:);

% get number of assets
NAssets = length(ERet);

% vector of lower bounds on weights
V0 = zeros(NAssets, 1);

% row vector of ones
V1 = ones(1, NAssets);

% set medium scale option
options = optimset('LargeScale', 'off');

% Find the maximum expected return
% we'll use CVX to do the linear programming
% instead of using the linprog function
% MaxReturnWeights = linprog(-ERet, [], [], V1, 1, V0, []);
cvx_begin
   variable x(NAssets,1)
   minimize( -ERet'*x )
   subject to
        V1*x == 1;
        x >= V0;
cvx_end
MaxReturnWeights = x;
MaxReturn = MaxReturnWeights' * ERet;

% Find the minimum variance return
% we'll use CVX to do the quadratic programming
% instead of using the linprog function
%MinVarWeights_ = quadprog(ECov,V0,[],[],V1,1,V0,[],[],options);
cvx_begin
   variable x(NAssets,1)
   minimize( 0.5*x'*ECov*x + V0'*x)
   subject to
        V1 * x == 1;
        x >= V0;
cvx_end
MinVarWeights = x;

MinVarReturn = MinVarWeights' * ERet;
MinVarStd = sqrt(MinVarWeights' * ECov * MinVarWeights);

% check if there is only one efficient portfolio
if MaxReturn > MinVarReturn
    RTarget = linspace(MinVarReturn, MaxReturn, NPts);
    NumFrontPoints = NPts;
else
    RTarget = MaxReturn;
    NumFrontPoints = 1;
end

% Store first portfolio
PRoR = zeros(NumFrontPoints, 1);
PRisk = zeros(NumFrontPoints, 1);
PWts = zeros(NumFrontPoints, NAssets);
PRoR(1) = MinVarReturn;
PRisk(1) = MinVarStd;
PWts(1,:) = MinVarWeights(:)';

% trace frontier by changing target return
VConstr = ERet';
A = [V1 ; VConstr ];
B = [1 ; 0];
for point = 2:NumFrontPoints
    B(2) = RTarget(point);
    
    % we'll use CVX to do the linear programming
    % instead of using the linprog function
    % Weights_ = quadprog(ECov,V0,[],[],A,B,V0,[],[],options);
    cvx_begin
       variable x(NAssets,1)
       minimize( 0.5*x'*ECov*x + V0'*x)
       subject to
            A * x == B;
            x >= V0;
    cvx_end
    Weights = x;
    PRoR(point) = dot(Weights, ERet);
    PRisk(point) = sqrt(Weights'*ECov*Weights);
    PWts(point, :) = Weights(:)';
end