%% Demo Evolution of Genetic Algorithm using Rastrigin's function
% Oren Rosen
% 4/12/07
% The MathWorks

%% Step 1: Show surface plot
% Explain objective (find absolute minimum). Explain difficulties
% traditional Optimization routines have with getting caught in local
% minimums.

rastriginsfcnSurf();
figure(gcf);

%% Step 2: Show contour plot
% Switch view to contour plot, looking at surface from above. Prepare for
% Genetic Algorithm animation.
rastriginsfcnCont();
figure(gcf);

%% Step 3: Find minimum using GA
% For illustration purposes, force GA to start in top right corner of
% contour plot by hard coding intitial condition of (5,5) for all points.
X0 = [5,5];
X0 = repmat(X0,100,1);

% Add custom plot function, population size and population starting point
% to options structure
options = gaoptimset('PlotFcns',@plotfun,'PopulationSize',100,...
                     'InitialPopulation',X0);

% Solve using Genetic Algorithm                 
[x fval flag] = ga(@rastriginsfcn, 2, [],[],[],[],[],[],[],options);
hold on;

%% Step 4: Plot final point in red
plot(x(1),x(2),'MarkerSize',25,'Marker','*','Color',[1 0 0],'linewidth',2);
hold off;
figure(gcf);