classdef TrackerData < event.EventData
    properties
        Code;
        Date;
        Information;
    end
    methods
        function data = TrackerData(code,Date,info)
            if nargin < 3, info = [];  end
            data.Code = code;
            data.Date = Date;
            data.Information = info;
        end
    end
end