classdef AccountManager
   methods (Static)
      function assignStatus(BA)
         if BA.AccountBalance < 0
            if BA.AccountBalance < -200
               BA.AccountStatus = 'closed';
            else
               BA.AccountStatus = 'overdrawn';
            end
         end
      end 
      function addAccount(BA)
% Call the handle addlistener method 
% Object BA is a handle class
         addlistener(BA, 'InsufficientFunds', ...
            @(src, evnt)AccountManager.assignStatus(src));
      end
   end
end