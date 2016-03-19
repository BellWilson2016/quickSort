classdef avgWavePlot < daughterPlot
    
    properties
        currentSpikeTraceHandle
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
        
        function plotOverlay(TP, spikeIX)
        	try
                delete(TP.currentSpikeTraceHandle);
            catch
            end
            
            figure(TP.windowHandle);
            data = TP.handSorter.data;
            spikeHalfWidth = round(data.spikeWidth/2*data.sampleRate);
            if ~isempty(spikeIX)
                centerSample = data.spikeSamples(spikeIX);
                clustN       = data.spikeClusters(spikeIX);
                avgWave = TP.handSorter.data.spikeAvg{clustN};
            else
                centerSample = dsearchn(TP.handSorter.time',TP.handSorter.plotPosition);
                avgWave = zeros(2*spikeHalfWidth + 1,1);
            end

            range = [centerSample - spikeHalfWidth : centerSample + spikeHalfWidth];
            TP.currentSpikeTraceHandle = plot(TP.handSorter.residual(range) + avgWave,'k');
            figure(TP.handSorter.mainFig.handle);
        end
        
        function setPointLock(TP, caller, event)
            if (TP.handSorter.mode > 0)
                spikeIX = event.data;
                TP.plotOverlay(spikeIX);
            end
        end
        
        
    end
end