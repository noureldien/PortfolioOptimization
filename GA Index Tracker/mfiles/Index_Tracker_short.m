%% Tracker Demo - Short
% Show a quick run through the GA tracker. Demo will show: 
%
% * Selection using the GA
%
% * Events triggering reselection
% 
% * Events triggering a rebalance

%% Initialisation
% First ready the MATLAB session and get a size for the figures we want to
% show.
%% Create an Index to track

fpos = InitialiseSession;

load DemoData; load Potential
rand('twister',s);

StartDate = datenum('01/01/2007','dd/mm/yyyy');
StartIdx = find(Dates > StartDate); StartIdx = StartIdx(1);
InitDate = datenum('01/01/2006','dd/mm/yyyy');
InitIdx = find(Dates > InitDate); InitIdx = InitIdx(1);
EndIdx = numel(Dates);

NumStocks = size(Companies,1); % Number of stocks in our universe

NumDays = numel(Dates(InitIdx:EndIdx));
Wts = CreateIndex(NumDays,100,NumStocks);

conn = Index_DataBase(Companies,Dates,Wts,Stocks);
StartIdx = find(Dates > StartDate); StartIdx = StartIdx(1);
F = PlotResults(fpos,Companies,StartDate); % Function handles to allow us to display results

%% Initialise the Index and tracker
% We load up a years worth of prior data

Name = 'DemoIndex';
Idx = find(Wts(StartIdx,:) ~= 0);
IndexFund = Index('Name',Name,'Dates',Dates(StartIdx),...
    'Companies',Companies(Idx,1),'Weights',Wts(StartIdx,Idx),...
    'DataBase',conn);

% Add a listener to see when the composition of the Index changes

L(1) = addlistener(IndexFund,'Update',@(src,evt) F{1}(evt));
L(2) = addlistener(IndexFund,'CompositionChange',@(src,evt) F{3}(evt));

%% Initialise the Tracker
% Add listeneres for tracker events

TrackerFund = GATracker('Name','DemoIndex Track','TargetIndex',IndexFund,...
    'NumStocks',10,'NumPop',70,'DataBase',conn);
L(3) = addlistener(TrackerFund,'UpdateFund',@(src,evt) F{2}(evt));
L(4) = addlistener(TrackerFund,'ReSelect',@(src,evt) F{4}(evt));
L(5) = addlistener(TrackerFund,'Rebalance',@(src,evt) F{5}(evt));
Initialise(TrackerFund);


%% Now run through 2007

for ii = StartIdx+1:numel(Dates)
    Idx = find(Wts(ii,:) ~= 0);
    ChangeWeights(IndexFund,Dates(ii),Companies(Idx,1)',Wts(ii,Idx)',true);
end

