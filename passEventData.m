classdef passEventData < event.EventData
   properties
      data
   end

   methods
      function PED = passEventData(userData)
         PED.data = userData;
      end
   end
end