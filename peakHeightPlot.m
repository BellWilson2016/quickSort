classdef peakHeightPlot < daughterPlot
    
    properties
    end
    
    methods
        
        function TP = peakHeightPlot(HS)       
            
            TP = TP@daughterPlot(HS);           
            TP.windowPosition = [633     5   390   304];
            set(TP.windowHandle,'Position',TP.windowPosition);
            
            TP.doPlot();  
            figure(TP.handSorter.mainFig.handle);
            
        end
        
        function doPlot(TP)
            
            figure(TP.windowHandle);
            cla;
            clusterList = unique(TP.handSorter.data.spikeClusters);
            for clustNn = 1:length(clusterList)
                clustN = clusterList(clustNn);
                ix = find(TP.handSorter.data.spikeClusters == clustN);
                peakSamples = TP.handSorter.data.spikeSamples(ix);
                peakHeights = TP.handSorter.data.dVdT(peakSamples);
                [N,xout] = hist(peakHeights,20);
                binsVec = [xout ; xout];
                binsVec(1) = []; binsVec(end) = [];
                nVec = [N;N]; nVec(end-1:end) = [];
                plot(-binsVec, nVec,'Color',TP.handSorter.colorList(clustN,:)); hold on;
            end
            axis tight;
            
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