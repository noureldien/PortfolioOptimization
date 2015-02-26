function [WTS1,X1] = gaStockSelect(cv,wts,NumStocks,NumPop,flag)

if nargin < 5
    flag = false;
end
NumAssets = size(cv,2);

ipop = zeros(NumPop,NumAssets);

Basic = [ones(1,NumStocks), zeros(1,NumAssets-NumStocks)];
for ii = 1:NumPop
    ipop(ii,:) = Basic(randperm(NumAssets));
end

%% GA step
fitnessFunction = @(W) TargetFcn(W,cv,wts);

% Linear inequality constraints
Aineq = [];
Bineq = [];

% Linear equality constraints
Aeq = [];
Beq = [];

% Bounds
LB = [];
UB = [];
% Nonlinear constraints
nonlconFunction = [];

% Start with default options
options = gaoptimset;

% Modify some parameters
options = gaoptimset(options,'PopulationSize' , NumPop );
options = gaoptimset(options,'CrossoverFraction' ,0.5 );
options = gaoptimset(options,'InitialPopulation' , ipop);
options = gaoptimset(options,'Display' ,'off');
options = gaoptimset(options,'UseParallel' ,'always');
if flag
    options = gaoptimset(options,'PlotFcns' ,{  @gaplotbestf @gaplotbestindiv });
end

% Using custom crosover and mutation functions that preserve constraints
options = gaoptimset(options,'CrossoverFcn' ,@iCrossoverCustom);
options = gaoptimset(options,'MutationFcn' ,@iMutationCustom);

[X1] = ga(fitnessFunction,NumAssets,Aineq,Bineq,Aeq,Beq,LB,UB,nonlconFunction,options);

%% Lets see how well this did
[junk,wts1] = TargetFcn(X1,cv,wts);

WTS1 = zeros(NumAssets,1);
WTS1(X1 == 1) = wts1;

end
% -------------------------------------------------------------------------
function xoverKids  = iCrossoverCustom(parents,options,GenomeLength,FitnessFcn,unused,thisPopulation)
% Oren Rosen
% The MathWorks
% 8/29/2007
%
% This custom crossover function is written to work on a population of
% vectors of zeros and ones with the same amount of ones in each vector.
% The children that are produced from 2 parents will have the same genes
% for every element they agree on, and random choices of zerps and ones for
% the elements they don't agree on. The number of each is set so that all
% children have the same number of ones as their parents. All children
% automatically satisfy this constraint so there is no need to impose these
% constraints.

% How many children to produce?
nKids = length(parents)/2;

% Allocate space for the kids
xoverKids = zeros(nKids,GenomeLength);

% To move through the parents twice as fast as thekids are
% being produced, a separate index for the parents is needed
index = 1;

% *** Initialize ***
% Assumes all members of thisPopulation have the same number of ones.
num1s = sum(thisPopulation(1,:));
indexVec = 1:GenomeLength;
    
% for each kid...
for i=1:nKids
    
    % *** Get parents ***
    r1 = parents(index);
    index = index + 1;
    r2 = parents(index);
    index = index + 1;
    
    p1 = thisPopulation(r1,:);
    p2 = thisPopulation(r2,:);
    
    % *** Find Matching 1's and 0's ***
    % Ex: If           p1 == [ 1 0 1 0 0 1 1 0 0 0 ]
    %                  p2 == [ 1 0 0 1 0 0 1 0 1 0 ]
    %     Then matching1s == [ 1 0 0 0 0 0 1 0 0 0 ]
    %     Then matching0s == [ 0 1 0 0 1 0 0 1 0 1 ]
    matching1s = ~xor(p1,p2) & (p1 == 1);
    matching0s = ~xor(p1,p2) & (p1 == 0);
    
    % *** Find Matching Indices ***
    %     If       matching1s == [ 1 0 0 0 0 0 1 0 0 0 ]
    %              matching0s == [ 0 1 0 0 1 0 0 1 0 1 ]
    %     Then matching1sIndx == [ 1 7 ]
    %          matching0sIndx == [ 2 5 8 10 ]
    %         nonmatchingIndx == [ 3 4 6 9 ]
    matching1sIndx = indexVec(matching1s);
    matching0sIndx = indexVec(matching0s);
    nonmatchingIndx = setdiff(indexVec,[matching0sIndx,matching1sIndx]);

    % *** Create Child ***
    % Ex: If   num1s == 4
    %          matching1sIndx == [ 1 7 ]
    %          nonmatchingIndx == [ 3 4 6 9 ]
    %     Then numMatching1s == 2
    %     num1sToFill == 2
    %     Indx1sToFill == 2 random choices from [ 3 4 6 9 ]
    numMatching1s = numel(matching1sIndx);
    num1sToFill = num1s - numMatching1s;
    Indx1sToFill = randsample(nonmatchingIndx,num1sToFill);

    % *** Fill in 1s ***
    % Ex: If               p1 == [ 1 0 1 0 0 1 1 0 0 0 ]
    %                      p2 == [ 1 0 0 1 0 0 1 0 1 0 ]
    %     Then xoverKids(i,:) == [ 1 0 ? ? 0 ? 1 0 ? 0 ]
    %     With exactly 2 of the '?' equal to 1, the rest 0.
    xoverKids(i,matching1sIndx) = 1;
    xoverKids(i,Indx1sToFill) = 1;
end

end
% -------------------------------------------------------------------------
function mutationChildren = iMutationCustom(parents,options,GenomeLength,FitnessFcn,state,thisScore,thisPopulation)
% Oren Rosen
% The MathWorks
% 8/29/2007
%
% This custom mutation function is written to work on a population of
% vectors of zeros and ones with the same amount of ones in each vector.
% The mutated child is formed by randomly permuting the elements of the
% parent.
% Note: Performance-wise this hasn't worked out to be that efficient. A
% better implementation may swap only two of the elements.

 
mutationChildren = zeros(length(parents),GenomeLength);
numVars = length(thisPopulation(1,:));

for i=1:length(parents)
    child = thisPopulation(parents(i),:);
    mutationChildren(i,:) = child( randperm(numVars) );
end

end
