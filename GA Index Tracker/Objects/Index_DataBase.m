classdef Index_DataBase
    % Mimics a data base containing the relevant data for the demo
    properties
        Dates;
        Companies;
        Wts;
        Stocks;
    end
    methods
        function obj = Index_DataBase(Companies,Dates,Wts,Stocks)
            % Constructor
            obj.Companies = Companies;
            obj.Dates = Dates;
            obj.Wts = Wts;
            obj.Stocks = Stocks;
        end
        function out = fetch(obj,Table,Dates,Companies)
            % Return data
            if nargin > 2
                [junk,rIdx] = intersect(obj.Dates,Dates);
                C = obj.Companies(:,1);
                [junk,cIdx,cIdx2] = intersect(C,Companies);
                [junk,cIdx3] = sort(cIdx2);
            end
            switch lower(Table)
                case 'companies'
                    out = obj.Companies;
                case 'weights'
                    out = obj.Weights(rIdx,cIdx);
                case 'stocks'
                    data = obj.Stocks(rIdx,cIdx);
                    out = [obj.Dates(rIdx), data(:,cIdx3)];
            end
        end
    end
end
            
    