classdef daughterPlot < handle
    
    properties
        handSorter
        windowPosition
        windowHandle
    end
    
    methods
                
        function DP = daughterPlot(HS)
            
            DP.handSorter = HS;
            DP.windowPosition = [241 671 782 560];
            DP.windowHandle = figure('Position',DP.windowPosition,...
                                'MenuBar','none',...
                                'Interruptible','off',...
                                'BusyAction','queue');
            set(DP.windowHandle,'KeyPressFcn',@HS.keyPress);
            
        end
        
        function removeSpike(DP, caller, event)
        end
        function addSpike(DP, caller, event)
        end
        function convertSpike(DP, caller, event)
        end
        function refreshData(DP, caller, event)
        end
        function setPointLock(DP, caller, event)
        end
        function quit(DP, caller, event)
            try
                if ishandle(DP.windowHandle)
                    close(DP.windowHandle);
                end
            catch
            end
        end
                
    end
end
    
    
    