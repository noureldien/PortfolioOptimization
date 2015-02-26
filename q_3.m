clc;

% load data
load('data\q_3.mat');

indeces = [index1 index2 index3];
trackers = [tracker1 tracker2 tracker3];
rmse = [];
errors = [];

% comparing the results;
for i=1:3
    e = sqrt((indeces(:,i) - trackers(:,i)).^2);
    errors = [errors e];
    rmse = [rmse sqrt(mean(e))];
end

% % plot the errors
% figure(1); clf;
% hold on;
% grid on;
% box on;
% boxplot(errors);
% title('Performance of Index Trackers','FontSize',18);
% xlabel('Greedy-first  Sparse    GA       ', 'FontSize', 18);
% ylabel('Absolute Errors', 'FontSize', 18);

tracker3_ = tracker3 - 1;
index3_ = index3 - 1;

figure(2); clf;
hold on;
grid on;
box on;
plot(index3_, 'LineWidth', 2, 'Color', 'k');
plot(tracker1, 'r', 'LineWidth', 2);
plot(tracker2, 'b', 'LineWidth', 2);
plot(tracker3_, 'LineWidth', 3, 'Color', [0 0.7 0.2]);
xlabel('Time (Days)', 'FontSize', 18);
ylabel('Return (%)', 'FontSize', 18);
title('Index Tracking (Testing)', 'FontSize', 18);
fig_legend = legend('Index', 'Greedy-first', 'Sparse' ,'GA', 'Location', 'nw');
set(fig_legend,'FontSize',12);








