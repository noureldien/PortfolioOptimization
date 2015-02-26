classdef GATracker < Portfolio
    % GATracker aims to track an index  using a Genetic Algorithm to select
    % the stocks to use
    properties
        TargetIndex   % Index to track
        NumStocks     % Number of stocks to use
        NumPop        % Size of population for GA
        SoftTarget  = 0.005; % Percentage drift we tolerate for a certain
        % number of days
        HardTarget = 0.1; % If we drift further than this then rebalance
        % immediately
        ExcessionPeriod = 3; % Number of days we are allowed to be outside
        % our soft target before triggering a
        % rebalance
        HoldPeriod = 252;  % Number of days to hold stocks before re-selection
        DisplayFlag = true; % Do we show a display of the genetic algorithm?
    end
    % ---------------------------------------------------------------------
    properties (SetAccess = 'private')
        ExcessionCount = 5; % Number of days we have been outside the soft target
        SelectionCount = 0; % Days since last sepection
        Listeners =  [];    % Listeners for external events
    end
    % ---------------------------------------------------------------------
    events
        Rebalance;          % We have rebalanced as a limit has been exceeded
        ReSelect;           % The portfolio has re-selected shares
        UpdateFund;
    end
    % ---------------------------------------------------------------------
    methods
        % -----------------------------------------------------------------
        function obj = GATracker(varargin)
            % Constructor for the GATracker
            if nargin == 0
                obj.Name = '';
                obj.Dates = today;
                obj.Companies = {};
                obj.Weights = [];
                obj.DataBase = [];
                obj.TargetIndex = [];
                obj.NumStocks = [];
                obj.NumPop = [];
            elseif nargin == 1 && isa(varargin{1},'GATracker')
                obj = varargin{1};
            else
                % Assume we have parameter-value pairs
                if (rem(nargin,2)==0)
                    for ii=1:2:nargin
                        param = varargin{ii};
                        value = varargin{ii+1};
                        obj.(param) = value;
                    end
                else
                    error('Portfolio:Constructor','Inputs must be in parameter-value pairs');
                end
            end
        end
        % -----------------------------------------------------------------
        function set.TargetIndex(obj,Target)
            % If the target is set to an Index then we need to listen for
            % the Composition change event.
            if ~isempty(Target)
                if ~isa(Target,'Index')
                    error('GATracker:SetTargetMethod:TargetNeedsToBeAnIndex',...
                        'GATracker: Target needs to be an Index');
                else
                    L(1) = addlistener(Target,'CompositionChange',...
                        @(src,evt) CompositionChange(obj,src,evt));
                    L(2) = addlistener(Target,'Update',...
                        @(src,evt) Update(obj,src,evt));
                    obj.Listeners = [obj.Listeners; L];
                end
            end
            obj.TargetIndex = Target;
        end
        % -----------------------------------------------------------------
        function Initialise(obj)
            % Trigger the initial stock selection
            StockSelection(obj,true);
        end
        % -----------------------------------------------------------------
        function StockSelection(obj,flag)
            % carry out a Stocks selection process
            % First we need to get the data that we want to use, then we
            % call the gaStockSelect algorithm
            C1 = GetCurrentCompanies(obj);
            [cv,wts,Companies,Date] = GetOptimisationData(obj);
            [W,Jdx] = gaStockSelect(cv,wts,obj.NumStocks,obj.NumPop,obj.DisplayFlag);
            % Need to find the companies that correspond to these weights
            Jdx = find(Jdx ~= 0);
            Companies = Companies(Jdx)';
            ChangeWeights(obj,Date,Companies,W(Jdx));
            obj.SelectionCount = 0;
            % Finally send the Reselect event
            C3 = GetCurrentCompanies(obj);
            [junk,Idx,Jdx] = setxor(C1,C3);
            info.Dropped = C1(Idx);
            info.Included = C3(Jdx);
            info.Companies = C3;
            info.Weights = GetCurrentWeights(obj);
            evt = TrackerData(0,GetCurrentDate(obj),info);
            notify(obj,'Rebalance',evt);
        end
        % -----------------------------------------------------------------
        function CompositionChange(obj,src,evt)
            % The composition of the index we are tracking has changed,
            % we will need perform a reselection if any of the shares we are
            % using have dropped out of it.

            % Get the trackers companies
            C1 = GetCurrentCompanies(obj); % Super class method
            C2 = GetCurrentCompanies(obj.TargetIndex);
            % If any of C1 are not in C2 we need to re-select
            different = setdiff(C1,C2);
            if ~isempty(different)
                StockSelection(obj,true);
            end
            % Reset Excession Count
            obj.ExcessionCount = 0;
        end
        % -----------------------------------------------------------------
        function Update(obj,src,evt)

            if obj.SelectionCount > obj.HoldPeriod
                StockSelection(obj);
                return
            else
                obj.SelectionCount = obj.SelectionCount+1;
            end

            [Val,Ret] = Value(obj,evt.Dates);
            % Now get the values we are trying to match.
            iRet = evt.Return;
            delta = iRet-Ret;
            if delta > obj.HardTarget
                ReCalculate(obj,1);
            elseif abs(delta) > obj.SoftTarget
                obj.ExcessionCount = obj.ExcessionCount+1;
                if obj.ExcessionCount > obj.ExcessionPeriod
                    ReCalculate(obj,2);
                end
            else
                obj.ExcessionCount = max(obj.ExcessionCount-1,0);
            end
            evt = IndexData(Val,Ret,evt.Dates(end));
            notify(obj,'UpdateFund',evt);
        end
        % -----------------------------------------------------------------
        function ReCalculate(obj,code)
            % We need to choose new weights. this should be a simple call
            % to the quadratic programming code.
            [cv,wts,D,C,Idx,Jdx] = GetOptimisationData(obj);
            W = GetCurrentWeights(obj);
            % Call target function to perfom the optimisation
            [junk,Wts] = TargetFcn(W,cv,wts,Idx,Jdx);
            C = GetCurrentCompanies(obj);
            NewDate = GetCurrentDate(obj.TargetIndex);
            ChangeWeights(obj,NewDate,C,Wts);
            info.Companies = C;
            info.Weights = GetCurrentWeights(obj);
            evt = TrackerData(code,NewDate,info);
            notify(obj,'Rebalance',evt);
            % Reset the excession count
            obj.ExcessionCount = 0;

        end
        % -----------------------------------------------------------------
        function [cv,wts,Companies,Date,Idx,Jdx] = GetOptimisationData(obj)

            % Return the covariance matrix and wts for the stocks in the
            % Index.
            % We use a years worth of data prior to the stated date
            Companies = obj.TargetIndex.Companies;
            Date = GetCurrentDate(obj.TargetIndex);
            wts = GetCurrentWeights(obj.TargetIndex);
            Idx = find(~isnan(wts)); % Strip out the NaN values
            wts = wts(Idx);
            Companies = Companies(Idx);
            % Get a years worth of data for these companies
            data = fetch(obj.DataBase,'Stocks',[Date-365:Date],Companies);
            dates = data(:,1); data = data(:,2:end);
            % We are only going to look at companies for which we have the
            % full years worth of data so that we can avoid issues of messy
            % data. This is a fudge, but using ecmnmle and the like could
            % get us round this.
            [r,c] = find(isnan(data));
            data(:,c) = [];
            wts(c) = [];
            Companies = Companies(setdiff(1:numel(Companies),c));
            cv = cov(tick2ret(data)); % covariance of the returns
            % Now find where our stocks are in this set of stocks
            C = GetCurrentCompanies(obj);
            [junk,Idx] = intersect(Companies,C);
            Jdx = 1:size(cv,1);
            Jdx = setdiff(Jdx,Idx);
        end
    end
end