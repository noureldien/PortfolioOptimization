function [out,VI] = TestPerformance(IndexFund,NumStocks,Alpha,Beta,conn,StartIdx,Companies,Wts,Dates)

% Initialise the Tracker
% Add listeneres for tracker events

TrackerFund = GATracker('Name','DemoIndex Track','TargetIndex',IndexFund,...
    'NumStocks',NumStocks,'NumPop',70,'DataBase',conn,'DisplayFlag',false,...
    'SoftTarget',Alpha,'HardTarget',Beta);

Initialise(TrackerFund);


% Now run through 2007

for ii = StartIdx+1:numel(Dates)
    Idx = find(Wts(ii,:) ~= 0);
    ChangeWeights(IndexFund,Dates(ii),Companies(Idx,1)',Wts(ii,Idx)',true);
end

D = IndexFund.Dates;

out = Value(TrackerFund,D(:));

if nargout > 1
    VI = Value(IndexFund,IndexFund.Dates);
end