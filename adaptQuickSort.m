function data = adaptQuickSort(data, nClusters)

    peakLimit = 2;
    peakIncrementFactor = 1.1;
    
    limitOK = false;
    while ~limitOK
        
        qdata = quickSort(data, nClusters, peakLimit);
        clusterList = unique(qdata.spikeClusters);
        nSpikes = [];
        for clustNn = 1:length(clusterList)
            clustN = clusterList(clustNn);
            nSpikes(clustN) = length(find(qdata.spikeClusters == clustN));
        end
        
        meanSpikes = mean(nSpikes(1:(end-1)));
        smallestSpikes = nSpikes(end);
        smallRatio = smallestSpikes/meanSpikes;
        
        if smallRatio < .5
            peakLimit = peakLimit/peakIncrementFactor;
            disp(['peakLimit -> ',num2str(peakLimit)]);
        elseif smallRatio > 1.5
            peakLimit = peakLimit*peakIncrementFactor;
            disp(['peakLimit -> ',num2str(peakLimit)]);
        else
            limitOK = true;
        end
    end
    
    data = qdata;