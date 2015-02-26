function Wts = CreateIndex(NumDays,NumStocks,TotalNumStocks,L,K,s,t)

% Create a fake index for our tracker to track - use a stochastic process
% drawn from Black Scholes to create a series of fake weightings for an
% Index
%
%   NumDays - number of days to simulate
%   NumStocks - Number of stocks to use in the Index
%   TotalNumStocks - Total number of stocks (including one to drop and pick
%                   up) for our universe
%   L - parameter for poisson process that governs how many days we select
%       stocks
%   K - parameter for poisson process that governs how many stocks we
%       drop/select
%   s - "volatility" for MC simulation
%   t - timestep for our MC simulation
%

if nargin < 4
    L = 7; % parameter for poisson distribution which dictates how many 
            % days we reselect stocks on
end
if nargin < 5
    K = 4; % parameter for poisson distribution which dictates how many 
            % stocks we drop and pick up
end
if nargin < 6, s = 0.1; end
if nargin < 7, t = 0.01; end

Selected = [ones(1,NumStocks),zeros(1,TotalNumStocks-NumStocks)];
Selected = find(Selected(randperm(numel(Selected))));
unSelected = setdiff(1:TotalNumStocks,Selected);

Wts = zeros(NumDays,TotalNumStocks);

% Pick some days for reselection. We don't perform a reselection two days
% on the trot
NumResel = poissrnd(L,1);
Pool = 3:NumDays;
ReselDays = zeros(NumResel,1);
for ii = 1:NumResel
    x = 1+round((numel(Pool)-1)*rand);
    ReselDays(ii) = Pool(x);
    Pool = setdiff(Pool,ReselDays(ii)-2:ReselDays(ii)+2);
end
ReselDays = sort(ReselDays);

R = rand(1,NumStocks);

Wts(1,Selected) = R/sum(R);

for ii = 2:size(Wts,1)
    Wts(ii,Selected) = Wts(ii-1,Selected).*exp((-s^2/2)*t+s*randn(1,NumStocks)*sqrt(t));
    Wts(ii,Selected) = Wts(ii,Selected)./sum(Wts(ii,Selected));
    if ismember(ii,ReselDays)
        % Reselection
        M = poissrnd(K); % Number of stock to drop/select
        S = iRandomSubset(Selected,M);
        T = iRandomSubset(unSelected,M);
        Selected = [setdiff(Selected,S) T'];
        unSelected = [setdiff(unSelected,T) S'];
        Wts(ii,T) = Wts(ii,S);
        Wts(ii,S) = 0;
    end
end
    
end
% -------------------------------------------------------------------------
function S = iRandomSubset(X,N)

% Select N elements of X randomly

Pool = X;
S = zeros(N,1);

for ii = 1:N
    x = 1+round((numel(Pool)-1)*rand);    
    S(ii) = Pool(x);    
    Pool = setdiff(Pool,S);
end

end