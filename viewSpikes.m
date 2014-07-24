function viewSpikes(data)

    t = [1:length(data.fV)]./data.sampleRate;
    plot(t,data.dVdT); hold on;
    
    nClusters = length(unique(data.spikeClusters));
    for clustN = 1:nClusters
        ix = find(data.spikeClusters == clustN);
        scatter(data.spikeTimes(ix),data.dVdT(data.spikeSamples(ix)),'MarkerEdgeColor',pretty(clustN));
    end