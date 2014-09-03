classdef embeddingPlot < daughterPlot
    
    properties
        overlayHandle
    end
    
    methods
        
        function EP = embeddingPlot(HS)       
            
            EP = EP@daughterPlot(HS);
            
            EP.doPlot();  
            figure(EP.handSorter.mainFig.handle);
            
        end
        
        function doPlot(EP)
            
        	figure(EP.windowHandle);
            clf;
            
            clusterList = unique(EP.handSorter.data.spikeClusters);

            for clustNn=1:length(clusterList)
                clustN = clusterList(clustNn);
                ix = find(EP.handSorter.data.spikeClusters == clustN);
                points = scatter(EP.handSorter.data.spikeEmbedding(ix,1),...
                                 EP.handSorter.data.spikeEmbedding(ix,2),...
                                 16,EP.handSorter.colorList(clustN,:),'o',...
                                 'MarkerFaceColor','none'); hold on;
                set(points,'ButtonDownFcn',@EP.plotClick);
            end
            set(gca,'XTick',[],'YTick',[]); box on;
            set(gca,'ButtonDownFcn',@EP.plotClick);  
            
        end
        
        function plotOverlay(EP, spikeIX)
            
            try
                delete(EP.overlayHandle);
            catch
            end
            
            x = EP.handSorter.data.spikeEmbedding(spikeIX,:);
            figure(EP.windowHandle);
            EP.overlayHandle = scatter(x(1),x(2),16,'k','o','LineWidth',2,...
                'MarkerFaceColor','k','MarkerEdgeColor','none');
            figure(EP.handSorter.mainFig.handle);
        end
        
        function setPointLock(EP, caller, event)
            spikeIX = event.data;
            if ~isempty(spikeIX)
                EP.plotOverlay(spikeIX);
            else
                try
                    delete(EP.overlayHandle);
                catch
                end
            end
                
        end
        
        function convertSpike(EP, caller, event)
            refreshData(EP, caller, event);
            spikeIX = event.data;
            EP.plotOverlay(spikeIX);
        end
        
        
        function removeSpike(EP, caller, event)
            refreshData(EP, caller, event);
        end
        
        function refreshData(EP, caller, event)
            EP.doPlot();  
            figure(EP.handSorter.mainFig.handle);
        end
        

        
        function plotClick(EP, obj, event)
            
            if strcmp(get(obj,'Type'),'axes')
                ax = obj;
            else
            	ax = get(obj, 'Parent');
            end
            pt = get(ax, 'CurrentPoint');
            clickVec = pt(1,1:2);

            score1s = EP.handSorter.data.spikeEmbedding(:,1);
            score2s = EP.handSorter.data.spikeEmbedding(:,2);
            distances = (score1s - clickVec(1)).^2 + (score2s - clickVec(2)).^2;
            
            [B,spikeIX] = min(distances);           
            clustN = EP.handSorter.data.spikeClusters(spikeIX);
            disp(['Cluster ',EP.handSorter.spikeCategories(clustN),' spike #',num2str(spikeIX)]);
            
            EP.plotOverlay(spikeIX);

            % Lock onto spike
            newPos = EP.handSorter.time(EP.handSorter.data.spikeSamples(spikeIX)); 
            EP.handSorter.selectedPointIX = spikeIX;
            EP.handSorter.setFocusLocation(newPos);
            EP.handSorter.setMode(1, spikeIX);
                       
       
        end
        
        
    end
end