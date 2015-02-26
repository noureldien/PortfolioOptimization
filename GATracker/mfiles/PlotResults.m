function out = PlotResults(fpos,Companies,StartDate,EndDate)

% Utility function to plot the results of the Index tracker

if nargin < 3
    StartDate = datenum('01/01/2007','dd/mm/yyyy');
end
if nargin < 4
    EndDate = datenum('31/12/2007','dd/mm/yyyy');
end

% Create figure
f = figure('position',fpos,...
    'name','Index Tracker Results',...
    'numbertitle','off');

ax = axes('position',[0.13,0.5,0.7750,0.4250]);
title('Performance of Index and Tracker','Fontsize',24)
xlabel('Date','fontsize',24);

ylim = [0.5,1.2];
dy = diff(ylim);

set(ax,'xlim',[StartDate, EndDate],'ylim',ylim);
datetick('x');

grid;

% Plot Index and tracker lines
Ixdata = StartDate;
Iydata = 1;

Fxdata = StartDate;
Fydata = 1;

I = line(Ixdata,Iydata,'color','k','linewidth',2,'parent',ax); % Index

F = line(Fxdata,Fydata,'color','b','linewidth',2,'parent',ax,...
    'color',[0 0.498 0]); % Fund


H = [];
P = [];
legend('Index','Tracker','location','sw');

% Pass out function handles to the nested functions which up date the plots
out = {@nUpdateIndex, @nUpdateFund, @nIndexChange, @nFundChange,...
    @nFundRebalance};

% create the displays we need for the reporting
wtAx = axes('position',[0.6 0.1, 0.3 0.3],'xlim',[0 0.5],'ytick',[]);
xlabel('Weighting','fontsize',18);
title('Tracker Portfolio Weights','fontsize',18);

dispAx = axes('xtick',[],'ytick',[],'position',[0.1,.1,.4,.3],...
    'box','off','visible','off');
txt = text(0,1,'','fontsize',12,'verticalalignment','top','parent',dispAx,...
    'fontweight','bold');

% -------------------------------------------------------------------------
    function nUpdateIndex(evt)
        % Update the index line
        figure(f);
        Ixdata = [Ixdata(:); evt.Dates(2)];
        Iydata = [Iydata(:); (1+evt.Return)*Iydata(end)];
        set(I,'xdata',Ixdata,'ydata',Iydata);
        drawnow;
    end
% -------------------------------------------------------------------------
    function nUpdateFund(evt)
        % Update the Tracker line
        Fxdata = [Fxdata(:); evt.Dates(end)];
        Fydata = [Fydata(:); (1+evt.Return)*Fydata(end)];
        set(F,'xdata',Fxdata,'ydata',Fydata);
        drawnow
    end
% -------------------------------------------------------------------------
    function nIndexChange(evt)
        % The index has changed, mark this with a flag
        switch evt.Code
            case -1
                % composition change
                col = 'r';
            case 0
                col = 'y';
            case 1
                col = 'm';
            case 2
                col = 'c';
            case 3
                col = 'g';
        end

        x = evt.Date;
        h = line(x*[1 1],ylim,'linestyle',':','color',col,...
            'buttondownfcn',{@nInfo,evt},'parent',ax);
        p = patch([x x+5 x x],ylim(2)-dy/40*[0, 0.5, 1, 0],col,...
            'buttondownfcn',{@nInfo,evt,h},'parent',ax);
        P = [P(:); p];

        drawnow;
        H = [H(:);h];
    end
% -------------------------------------------------------------------------
    function nFundRebalance(evt)
        % Fund weights have changed, mark this with a flag
        offset = 0;
        switch evt.Code
            case -1
                col = 'r';
            case 0
                % Reslection
                col = [0    0  1];
                offset = 0.5;
            case 1
                col = 'm';
              case 2
                % Rebalance
                col = [0   1   0];
            case 3
                col = [0 0.5 0];
        end
        x = evt.Date;
        h = line(x*[1 1]+offset,ylim,'linestyle',':','color',col,...
            'buttondownfcn',{@nInfo,evt},'parent',ax);
        p = patch([x x+5 x x],ylim(2)-dy/40*[1 1.5 2 1],col,...
            'buttondownfcn',{@nInfo,evt,h},'parent',ax);
        P = [P(:); p];
        H = [H(:);h];
        nBarChart(evt.Information);
        
        drawnow;
    end
% -------------------------------------------------------------------------
    function nInfo(src,evt,data,h)
        % Display the information about the relevant change
        set(H,'linewidth',0.5);
        if nargin == 4
            set(h,'linewidth',5);
        else
            set(src,'linewidth',5);
        end
        switch data.EventName
            case 'Rebalance'
                switch data.Code
                    case 0
                        [dstr,sstr] = nSetupStrings(data.Information);
                        set(txt,'string',[...
                            'Tracker Compostion change:', char(10),char(10),...
                            'Dropped: ',dstr,char(10),char(10),...
                            'Included: ',sstr]);
                    otherwise
                        set(txt,'string','Tracker Rebalances');
                end
                nBarChart(data.Information);
            case 'CompositionChange'
                [dstr,sstr] = nSetupStrings(data.Information);
                set(txt,'string',[...
                    'Index Compostion change:', char(10),char(10),...
                    'Dropped: ',dstr,char(10),char(10),...
                    'Included: ',sstr]);
       end
    end
% -------------------------------------------------------------------------
    function nBarChart(Information)
        % Update the bar graph
        axes(wtAx)
        wts = Information.Weights;
        barh(wts(~isnan(wts)));
        NumComp = numel(Information.Companies);
        for ii = 1:NumComp
            idx = strmatch(Information.Companies(ii),Companies(:,1));
            Cstr{ii} = Companies{idx,2};
        end
        set(wtAx,'ylim',[0 NumComp+1],'ytick',1:NumComp,'yticklabel',Cstr,...
            'xlim',[0 .25]);
        title('Tracker Portfolio Weights','fontsize',18);
        xlabel('Weighting','fontsize',18);
    end
% -------------------------------------------------------------------------
    function [dstr,sstr] = nSetupStrings(Information)
        % construct the strings for the display 
        dstr = '';
        count = 1;
        NumPerLine = 2;
        for ii = 1:length(Information.Dropped)
            idx = strmatch(unique(Information.Dropped(ii)),Companies(:,1));
            if count > NumPerLine
                dstr = [dstr,char(10),char(9)];
                count = 1;
            end
            dstr = [dstr,Companies{idx,2},', '];
            count = count+1;
        end
        dstr = dstr(1:end-2);
        sstr = '';
        count = 1;
        for ii = 1:length(Information.Included)
            idx = strmatch(unique(Information.Included(ii)),Companies(:,1));
            if count > NumPerLine
                sstr = [sstr,char(10),char(9)];
                count = 1;
            end
            sstr = [sstr,Companies{idx,2},', '];
            count = count+1;
        end
        sstr = sstr(1:end-2);
    end
end

