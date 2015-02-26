classdef IndexData < event.EventData
    % Data associated with events broadcast by the index object
    properties
        Value;
        Return;
        Dates;
    end
    methods
        function data = IndexData(V,R,D)
            data.Value = V;
            data.Return = R;
            data.Dates = D;
        end
    end
end
    