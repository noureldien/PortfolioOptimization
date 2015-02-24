clc;
close all;

returns = [];

% get the data
for i=1:20

%load raw csv data, format it and save it for later use
fileName = strcat('data\stock (', int2str(i) ,').csv');
prices = csvread(fileName,1,4);
prices = prices(:,1:1);

%flip data to be in chronological order
prices = flipud(prices);

% add to the list of returns
returns = [returns, prices];

end

% plot data
figure(1);clf;
hold on;
plot(returns);















