classdef Portfolio < handle
    properties 
        Name
        Dates     % List of dates
        Companies  % Companies in this portfolio
        Weights   % Weights of the companies
        DataBase  % Connection to the database which stores data we use
    end
    properties (SetAccess = 'private')
        Tolerance = 10*eps; % Tolerance for check weights calculation
    end
    % ---------------------------------------------------------------------
    methods
        function obj = Portfolio(varargin)
            % PORTFOLIO - Constructor method
            if nargin == 0
                obj.Name = '';
                obj.Dates = today;
                obj.Companies = {};
                obj.Weights = [];
                obj.DataBase = [];
            elseif nargin == 1 && isa(varargin{1},'Portfolio')
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
            %{ 
            % TODO - Remove 
            if ~isempty(W)
                Initialise(obj,Date,C,W);                
            elseif ~isempty(C)
                Initialise(obj,Date,C);
            end
            %}
        end
        % -----------------------------------------------------------------
        function Initialise(obj,Date,C,W)
            % Initialise the portfolio to the values described in the cell
            % array C
            if nargin < 4, W = [C{:,2}]; end
            if ~Portfolio.CheckWeights(W)
                error('Portfolio:Portfolio:Initialise:InvalidWeights',...
                    'Weights must sum to 1');
            end
            obj.Companies = C(:,1);
            obj.Weights = W;
            obj.Dates = Date;
        end
        % -----------------------------------------------------------------
        function ChangeWeights(obj,NewDate,C,W)
            % Adjust the weights in the portfolio on the date NewDate to
            % reflect the rankings given in the cell array C.
            %
            % C could be an N by 2 cell array, the first column should
            % give the company code from our universe, the second should
            % give the weight. The weights should add up to one.
            %
            % Alternatively C is a N by 1 list of companies, W is a N by 1
            % list of the weights.
            if nargin < 4, W = [C{:,2}]; C = C(:,1); end                
            % Make sure the companies are a colum vector
            if size(C,2) ~= 1, C = C'; end
            if ~Portfolio.CheckWeights(W)
                error('Portfolio:Portfolio:ChangeWeights:InvalidWeights',...
                    'Weights must sum to 1');
            end
            % Find out if we have invested in anything new
            NewCompanies = setdiff(C(:,1),obj.Companies)';
            S = size(obj.Weights);
            obj.Dates(S(1)+1) = NewDate;
            if ~isempty(NewCompanies)
                obj.Companies = {obj.Companies{:}, NewCompanies{:}};
                % Expand out the weights to accommodate the new data
                obj.Weights(S(1)+1,1:S(2)+numel(NewCompanies)) = NaN*ones(1,S(2)+numel(NewCompanies));
                obj.Weights(1:S(1),S(2)+1:S(2)+numel(NewCompanies)) = NaN;
            else
                obj.Weights(S(1)+1,:) = nan*ones(1,S(2));
            end
            [junk,Idx,Jdx] = intersect(C(:,1),obj.Companies);
            obj.Weights(end,Jdx) = W(Idx);
        end
        % -----------------------------------------------------------------
        function [Val,Ret] = Value(obj,D)
            % Find values and returns on dates given.
            
            % Here value is the return, i.e. Portfolio has value 1 at start
            if nargin == 1, D = obj.Dates; end
            if D(1) < obj.Dates(1)
                error('Portfolio:Value:DatePreceedsPortfolioStart',...
                    'Portfolio\Value: Date requested predates the start of the portfolio');
            end
            % First get the data we want from the data base
            StartDate = D(1);            
            % Could have that the date requested is beyond the last date
            % which we have record of
            if max(D) > obj.Dates(end)
                EndDate = max(D);
            else
                EndDate = GetCurrentDate(obj);
            end
            Comp = obj.Companies;
            % Fetch price data from the database
            Data = fetch(obj.DataBase,'Stocks',StartDate:EndDate,Comp);
            % Separate off the date field
            Date = Data(:,1);
            % Separate off the price data
            data = Data(:,2:end);
            % Find the dates we are interested in.
            [junk,Idx] = intersect(Date,D);
            % Now to calculate the returns for our portfolio
            NumRet = numel(Date)-1; % Number of returns to calculate
            Ret = zeros(NumRet,1);
            for ii = 1:NumRet
                % Find weights in portfolio on date in question
                % Dates of portfolio weight changes before current date
                Jdx = find(obj.Dates <= Date(ii));
                % Weights in portfolio
                Kdx = find(~isnan(obj.Weights(Jdx(end),:)));
                % Get corresponding stocks
                S = data([ii,ii+1],Kdx); 
                [row,col] = find(isnan(S));
                if ~isempty(row)
                    for jj = 1:numel(row)
                        % Problematic point - assume zero return for this stock
                        % Dubious but will allow us to continue
                        r = row(jj); c = col(jj);
                        if isnan(S(3-r,c))
                            S(:,c) = 1;
                        else
                            S(r,c) = S(3-r,c);
                        end
                    end 
                end
                Ret(ii) = (S(2,:)./S(1,:))*(obj.Weights(Jdx(end),Kdx))'-1;
            end
            Val = ret2tick(Ret);
            % Extract the values asked for
            Val = Val(Idx);
            % Convert the values series to a time series.
            Ret = tick2ret(Val);
        end
        % -----------------------------------------------------------------
        function out = GetCurrentWeights(obj)
            N = size(obj.Weights,1);
            out = obj.Weights(N,:);
        end
        % -----------------------------------------------------------------
        function out = GetCurrentCompanies(obj)
            N = size(obj.Weights,1);
            if N == 0
                out = [];
            else
                Idx = ~isnan(obj.Weights(N,:));
                out = obj.Companies(Idx);
            end
        end
        % -----------------------------------------------------------------
        function out = GetCurrentDate(obj)
            N = numel(obj.Dates);
            out = obj.Dates(N);
        end
        % -----------------------------------------------------------------
        function [turnover,D] = Turnover(obj)
            % Calculate the turnover of the portfolio. 
            W = obj.Weights;
            N = size(W,1);
            turnover = zeros(N-1,1);
            for ii = 2:N
                current = W(ii,:);
                previous = W(ii-1,:);
                dropped = isnan(current) & ~isnan(previous);
                selected = ~isnan(current) & isnan(previous);
                kept = ~isnan(current) & ~isnan(previous);
                turnover(ii-1) =  (sum(previous(dropped))+sum(current(selected))+...
                    sum(abs(current(kept)-previous(kept))))/2;
            end
            D =obj.Dates(2:end);
        end
    end
    % ---------------------------------------------------------------------
    methods(Static)
        function out = CheckWeights(W,tol)
            % Check the wieghts in the vector W to see if they sum to 1
            if nargin == 1
                tol = 10*eps;
            end
            out = abs(sum(W(:))-1) <  tol;
        end
    end
end
