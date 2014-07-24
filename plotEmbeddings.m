function plotEmbeddings(data)

        nClusters = length(unique(data.spikeClusters));

        for clustN=1:nClusters
            ix = find(data.spikeClusters == clustN);
            scatter(data.spikeEmbedding(ix,1),data.spikeEmbedding(ix,2),9,pretty(clustN),'+'); hold on;
        end
        set(gca,'XTick',[],'YTick',[]); box on;