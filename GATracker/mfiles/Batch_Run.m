%% Batch Run

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

%%

%matlabpool open 2

N = 5:5:15
alpha = [.001 0.005 0.01];
beta = [0.05 .1 .2];

[NN,A,B] = ndgrid(N,alpha,beta);
NN = NN(:);
A = A(:);
B = B(:);

PStart = now;
parfor ii = 1:numel(NN)
    tic
    Name = 'DemoIndex';
    Idx = find(Wts(StartIdx,:) ~= 0);
    IndexFund = Index('Name',Name,'Dates',Dates(StartIdx),...
        'Companies',Companies(Idx,1),'Weights',Wts(StartIdx,Idx),...
        'DataBase',conn);
    Val{ii} = TestPerformance(IndexFund,NN(ii),A(ii),B(ii),conn,StartIdx,Companies,Wts,Dates);
    t(ii) = toc;
end
Pstop = now;
T = (PStop-PStart)*86400;
%%
Name = 'DemoIndex'; 
Idx = find(Wts(StartIdx,:) ~= 0);
IndexFund = Index('Name',Name,'Dates',Dates(StartIdx),...
    'Companies',Companies(Idx,1),'Weights',Wts(StartIdx,Idx),...
    'DataBase',conn);

[junk,ValInd] = TestPerformance(IndexFund,2,1,1,conn,StartIdx,Companies,Wts,Dates);

V = [ValInd(:)];
 
D = IndexFund.Dates;


for ii = 1:numel(Val)
    V = [V Val{ii}(:)];
end
%%

load BatchRunData
D = IndexFund.Dates;
figure('position',fpos,'numbertitle','off','name','Results of Batch Run');

plot(D,ValInd,'color',rand(1,3),'linewidth',1);
strs{1} = 'Index';

for ii = 1:numel(Val)
    line(D,Val{ii}(:),'color',rand(1,3));
    strs{ii+1} = ['N = ',sprintf('%2.2g',NN(ii)),', \alpha = ',sprintf('%2.2g',A(ii)),', \beta = ',sprintf('%2.2g',B(ii))];
end
%title('Results of Batch run varying Number of stocks used (N) "Soft Target" (\alpha) and "Hard Target" (\beta)',...
%    'fontsize',18);

datetick('x');


