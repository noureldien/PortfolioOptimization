classdef Index < Portfolio
    events
        % Events this object can boradcast
        CompositionChange; % Index composition has changed
        Update; % New data has arrived
    end
    methods
        function obj = Index(varargin)
            if nargin == 0
                obj.Name = '';
                obj.Dates = today;
                obj.Companies = {};
                obj.Weights = [];
                obj.DataBase = [];
            elseif nargin == 1 && isa(varargin{1},'Index')
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
                    error('Portfolio:Index:Constructor','Inputs must be in parameter-value pairs');
                end
            end        
        end
        function ChangeWeights(obj,NewDate,C,W,flag)
            % IF we drop or pick up a new company then send the
            % CompositionChange event
            % If flag is true then calculate the value of the Index and
            % send an update event, unless we send a compositionchange
            % event
            if nargin < 4, W = [C{:,2}]; C = C(:,1);    end
            if nargin < 5, flag = false;                end
            OldDate = GetCurrentDate(obj);
            CurrentCompanies = obj.Companies(~isnan(obj.Weights(end,:)));
            [Different,Idx,Jdx] = setxor(CurrentCompanies,C);
            % Call superclass method to change the weights
            ChangeWeights@Portfolio(obj,NewDate,C,W);
            if ~isempty(Different)
                info.Dropped = CurrentCompanies(Idx);
                info.Included = C(Jdx);
                evt = TrackerData(-1,GetCurrentDate(obj),info);
                notify(obj,'CompositionChange',evt);
                Dates = [OldDate NewDate]
                [V,R] = Value(obj,Dates);
                evt = IndexData(V,R,Dates);
                notify(obj,'Update',evt);
            elseif flag
                % If flag is true we broadcast an update event along the
                % value and return
                Dates = [OldDate NewDate];
                [V,R] = Value(obj,Dates);
                evt = IndexData(V,R,Dates);
                notify(obj,'Update',evt);
            end
        end
    end
end