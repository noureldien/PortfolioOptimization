function [Indx,Tracker] = ReconstructPF(PF,Wts,Stocks,StartIdx,EndIdx)

if nargin < 4
    StartIdx = 1;
end
if nargin < 5
    EndIdx = size(Stocks,1);
end

NumDays = numel(StartIdx:EndIdx);

Indx = zeros(NumDays,1);
Indx(1) = 1;
Tracker = Indx;

for ii = StartIdx+1:EndIdx
    jj = ii-(StartIdx-1);
    S = Stocks(ii,:)./Stocks(ii-1,:); % Stock returns
    S(isnan(S)) = 0;
    Indx(jj) = S*Wts(ii,:)';
    Tracker(jj) = S*PF(:);
end

Indx = cumprod(Indx);
Tracker = cumprod(Tracker);

end
    
