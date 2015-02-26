clc;

% load data
%load('data\q_3c_1.mat');

figure(2); clf;
hold on;
grid on;
box on;
plot(Tracker, 'LineWidth', 1, 'Color', 'r');
plot(Indx,'LineWidth', 1, 'Color', 'b');
title('Index Tracking (Testset)','FontSize',18);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
fig_legend = legend('Our Portfolio', 'Market Index', 'Location', 'southwest');
set(fig_legend,'FontSize',14);