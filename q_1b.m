clc;
% we have 3-asset portfolio, we'll divide them to 3 2-asset protfolios
% and draw the efficient frontier and guassian dist. for them

% mean and covariance for all the assets the portfolio
mean_3assets = [0.1; 0.2; 0.15];
covariance_3assets = 100 * [0.005, -0.010, 0.004; -0.010 0.040 -0.002; 0.004, -0.002, 0.023];

% these different mean and covariance to see how is the effect
% of changing the mean and covariance on the forntier
% mean_3assets = [0.1; 0.2; 0.185];
%covariance_3assets = 100 * [0.005, -0.010, 0.004; -0.010 0.040 -0.002; 0.004, -0.002, 0.08];

N = 100;

useCVX = false;

effRisks = [];
effReturns = [];
effWeights = [];
m = zeros(1, 3);
c = zeros(1, 3);

for i=1:3
    
    mean_2assets = mean_3assets;
    covariance_2assets = covariance_3assets;
    indexToRemove = 0;
    
    switch(i)
        % asset 1 and 2
        case 1
            indexToRemove = 3;
            % asset 2 and 3
        case 2
            indexToRemove = 1;
            % asset 1 and 3
        case 3
            indexToRemove = 2;
        otherwise
    end
    
    % change 3d mean to 2d mean
    % also change the 3*3 covariance matrix to 2*2 one
    mean_2assets(indexToRemove) = [];
    covariance_2assets(indexToRemove,:) = [];
    covariance_2assets(:,indexToRemove) = [];
    
    % calc mean and standard deviation
    m(1,i) = norm(mean_2assets);
    c(1,i) = norm(covariance_2assets);
    
    % get the frontier for the 2-asset portfolio, the return values
    % are the risk, return and weights of the portfolio
    if (~useCVX)
        [effRisk, effReturn, effWeight] = naiveMV(mean_2assets, covariance_2assets, N);
    else
        [effRisk, effReturn, effWeight] = naiveMV_CVX(mean_2assets, covariance_2assets, N);
    end
        
    % another method to calcuate efficient forntier
    %[effRisk, effReturn, effWeight] = frontcon(mean_2assets, covariance_2assets, N);
    
    effRisks = [effRisks effRisk];
    effReturns = [effReturns effReturn];
    effWeights = [effWeights effWeight];
end

% also, get the frontier for the 3-asset portfolio

if (~useCVX)
    [effRisk_3, effReturn_3, effWeight_3] = naiveMV(mean_3assets, covariance_3assets, N);
else
    [effRisk_3, effReturn_3, effWeight_3] = naiveMV_CVX(mean_3assets, covariance_3assets, N);
end

% generate N random returns (normally distributed)
% for the 3-asset system (portfolio)
N = 600;
returns = mvnrnd(mean_3assets, covariance_3assets, N);

% plot the E-V graph
figure(1); clf;
box on;
grid on;
hold on;
%daspect([15 1 1]);
%axis tight;
%axis([-0.2,2.3,0.09,0.21]);
plot(effRisk_3(:), effReturn_3(:), '-.', 'LineWidth', 4, 'Color', [0.7 0.7 0.7]);
plot(effRisks(:,1), effReturns(:,1), 'r', 'LineWidth', 2);
plot(effRisks(:,2), effReturns(:,2), 'b', 'LineWidth', 2);
plot(effRisks(:,3), effReturns(:,3), 'LineWidth', 2, 'Color', [0 0.7 0.2]);
xlabel('Risk', 'FontSize', 18);
ylabel('Expected Return', 'FontSize', 18);
title('Efficient Portfolio Frontiers', 'FontSize', 18);
fig_legend = legend( 'Asset 1,2,3', 'Asset 1,2', 'Asset 2,3', 'Asset 1,3', 'Location', 'southeast');
set(fig_legend,'FontSize',12);

% plot the returns of the 3 models (each is 2-asset normal distrubution)
figure(2); clf;

subplot(1,3,1);
plot(returns(:,1), returns(:,2), '.r');
box on;
grid on;
daspect([1 1 1]);
axis([-8,8,-8,8]);
xlabel('Asset 1', 'FontSize', 14);
ylabel('Asset 2', 'FontSize', 14);
title('Portfolio 1 Distribution', 'FontSize', 14);

subplot(1,3,2);
plot(returns(:,2), returns(:,3), '.b');
box on;
grid on;
daspect([1 1 1]);
axis([-8,8,-8,8]);
xlabel('Asset 2', 'FontSize', 14);
ylabel('Asset 3', 'FontSize', 14);
title('Portfolio 2 Distribution', 'FontSize', 14);

subplot(1,3,3);
plot(returns(:,1), returns(:,3), '.', 'Color', [0 0.7 0.2]);
box on;
grid on;
daspect([1 1 1]);
axis([-8,8,-8,8]);
xlabel('Asset 1', 'FontSize', 14);
ylabel('Asset 3', 'FontSize', 14);
title('Portfolio 3 Distribution', 'FontSize', 14);











