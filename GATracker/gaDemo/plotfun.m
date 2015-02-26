function state = plotfun(options,state,flag)

% Plot each individual using a small black star
plot(state.Population(:,1),state.Population(:,2),'k*');
hold on;
% Plot underlying contour plot of surface
rastriginsfcnCont()
axis([-5,5,-5,5]);
hold off
pause(0.2)