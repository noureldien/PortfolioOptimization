clc;
close all;
figurePosition = [350 160 600 600];

% step 1: get the data
dataFiles = {'FTSE100', 'ABF', 'BP', 'IHG', 'HSBC'};

for i=1:5

%load raw csv data, format it and save it for later use
fileName = strcat('data\', dataFiles{i}, '.csv');
data = load(fileName);

%flip data to be in chronological order
data = flipud(data);
%older data seems to have the sames column values
%so, delete older data, i.e take only data with row(>=671)
data = data(671:length(data),:);

%save data for later use
fileName = strcat('data\', dataFiles{i}, '.mat');
save(fileName, 'data');

% load data
% data meanings: Open,High,Low,Close,Adj_Close, Volume Traded
% 594 rows of data for 855 days
% for simplicity, we'll consider that each data is for a day
load(fileName, 'data');

% plot data
figure(i);clf;
plot(data);
legend('Open', 'High', 'Low', 'Close', 'Adj Close', 'Location','northwest');

end




















