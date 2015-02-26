%% Index tracking using genetic algorithms
% This script will use the genetic algorithm to select stocks to track a
% fictitous index. The function |CreateIndex| will create the weights for
% an index using random selections. This index will drop stocks at dates
% throughout the year we are interested in.
fpos = InitialiseSession;

clc;

%% Create an Index to track

% instead of loading the DemoData
% load my data
% n*m, where n: opbservation, m: companies

% load the data
load('q_2.mat');

% returns need to be changed to percentages
% for each return, covert it from
%[100 120 150 100] to [0% 20% 50% 0%]
% for i=1:size(returns,2)
%     value = returns(1,i);
%     returns(:,i) = (returns(:,i) - value)/value;
% end

% now remove the first opservation (it is only zeros
% as it was used to convert returns to percentages)
returns = returns(2:end,:);

load potential
rand('twister',s);

Stocks = returns;
nAssets = size(returns,2);
nTotal = size(returns,1);
nTrain = int16(nTotal/2);
nTest = nTotal - nTrain;

StartIdx = nTest + 1;
InitIdx = 1;
EndIdx = nTotal;
NumStocks = nAssets;
NumDays = nTotal;
Wts = CreateIndex(NumDays,6,NumStocks,4,4);

% load DemoData;
% StartDate = datenum('01/01/2007','dd/mm/yyyy');
% StartIdx = find(Dates > StartDate); StartIdx = StartIdx(1);
% InitDate = datenum('01/01/2006','dd/mm/yyyy');
% InitIdx = find(Dates > InitDate); InitIdx = InitIdx(1);
% EndIdx = numel(Dates);
% NumStocks = size(Companies,1); % Number of stocks in our universe
% NumDays = numel(Dates(InitIdx:EndIdx));
% Wts = CreateIndex(NumDays,100,NumStocks);

%% Genetic Algorithm step
% Extract the data we need for the genetic algorithm step and then run the
% simulation

[cv,wts,NumStocks,Idx] = GetGAData(Wts,Stocks);
[W,X] = gaStockSelect(cv,wts,10,70,true);

%% How have we done?
% Reconstruct our portfolio
PF = zeros(NumStocks,1); PF(Idx) = W;
[Indx,Tracker] = ReconstructPF(PF,Wts,Stocks,StartIdx);

figure(1); clf;
plot([Indx,Tracker],'linewidth',2);
title('Comparison of Index and Tracker','fontsize',18);
legend('Index','Tracker','location','sw','fontsize',16);
xlabel('Date','fontsize',18);
ylabel('Price','fontsize',18);
grid on;
box on;

%% Results
% Depending on the choices made by the random number generator the
% resulting index and tracker normally start quite closely but as time 
% they will diverge as the weights in the index shift but the weights in
% the tracker remain constant. As a result the tracker should respond to
% this deviation.