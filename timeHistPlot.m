classdef timeHistPlot < daughterPlot
    
    properties
    end
    
    methods
        
        function TP = timeHistPlot(HS)       
            
            TP = TP@daughterPlot(HS);           
            TP.windowPosition = [633   338   390   304];
            set(TP.windowHandle,'Position',TP.windowPosition);
            
            TP.doPlot();  
            figure(TP.handSorter.mainFig.handle);
            
        end
        
        function doPlot(TP)
            
            histBins = [0:.002:.100];
            binsVec = [histBins ; histBins];
            binsVec(1) = []; binsVec(end) = [];
            
            figure(TP.windowHandle);
            cla;
            clusterList = unique(TP.handSorter.data.spikeClusters);
            for clustNn = length(clusterList):-1:1
                clustN = clusterList(clustNn);
                ix = find(TP.handSorter.data.spikeClusters == clustN);
                samples = TP.handSorter.data.spikeSamples(ix);
                sortedSamples = sort(samples,'ascend');
                ISI = diff(sortedSamples)./TP.handSorter.data.sampleRate;
                N = hist(ISI, histBins);
                nVec = [N;N]; nVec(end-1:end) = [];
                plot(binsVec(:),nVec(:),'Color', TP.handSorter.colorList(clustN,:)); hold on;
            end
            xlim([0 histBins(end)]);
                        
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