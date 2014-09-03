classdef avgWavePlot < daughterPlot
    
    properties
    end
    
    methods
        
        function TP = avgWavePlot(HS)       
            
            TP = TP@daughterPlot(HS);           
            TP.windowPosition = [239   338   390   304];
            set(TP.windowHandle,'Position',TP.windowPosition);
            
            TP.doPlot();  
            figure(TP.handSorter.mainFig.handle);
            
        end
        
        function doPlot(TP)
            
            TP.handSorter.data = makeSpikeAvg(TP.handSorter.data);
            figure(TP.windowHandle);
            cla;
            for clustN = 1:length(TP.handSorter.data.spikeAvg)
                waveform = TP.handSorter.data.spikeAvg{clustN};
                plot(waveform,'Color',TP.handSorter.colorList(clustN,:)); hold on;
            end
            axis tight;
            set(gca,'XTick',[],'YTick',[]);
            
        end
        
    
        function convertSpike(TP, caller, event)
            refreshData(TP, caller, event);
        end
        
        function addSpike(TP, caller, event)
            refreshData(TP, caller, event);
        end
        
        
        function removeSpike(TP, caller, event)
            refreshData(TP, caller, event);
        end
        
        function refreshData(TP, caller, event)
            TP.doPlot();  
            figure(TP.handSorter.mainFig.handle);
        end
        

        
        
    end
end