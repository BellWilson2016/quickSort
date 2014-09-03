% redetectResid applies the quickSort algorithm to the residual to find new
% spikes.
function data = redetectResid(data, peakLimit)

    % peakLimit = 4;      % SD (abs. value), 4
    negPeaks = true;
    posPeaks = false;
    
    residual = makeResidual(data);
    spikeHalfWidth = round(data.spikeWidth/2*data.sampleRate);
    nClusters = length(unique(data.spikeClusters));
    
    % Assemble trace snippets of existing spikes into a matrix for dimensionality reduction
    dataMatrix = [];
    peakList   = [];
    for peakN = 1:length(data.spikeSamples)
        samplePeak    = data.spikeSamples(peakN);
        clustN        = data.spikeClusters(peakN);
        avgSpikeToAdd = data.spikeAvg{clustN};
        % Make a full length spike waveform to subtract
        fullLengthSpike = zeros(length(residual),1);
        fullLengthSpike((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)) = avgSpikeToAdd;
        % Look for the biggest peak in the area of the old spike
        reclassFL = residual + fullLengthSpike;
        reclassWindow = reclassFL((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth));
        % Align the classification window to the new peak.
        [C, ix] = min(reclassWindow);
        newPeak = samplePeak - spikeHalfWidth + ix - 1;       
        reclassSnip = reclassFL((newPeak - spikeHalfWidth):(newPeak + spikeHalfWidth));
        saveSnip = reclassSnip;
        
        
%                 plot(.002 + data.dVdT((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)),'r');hold on;
%                 plot(residual((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)),'c');
%                 plot(avgSpikeToAdd,'g');
%                 plot(reclassWindow,'b'); 
%                 plot(reclassSnip,'m'); hold off;
%                 if (abs(newPeak - samplePeak) > 0)
%                     pause();
%                 end
        
        peakList(end+1) = newPeak;
        dataMatrix(end+1,:) = saveSnip';
    end
    
%     length(residual)
%     length(data.dVdT)
%     [N,xout] = hist(residual,100);
%     [N2,xout2] = hist(data.dVdT,100);
%     plot(xout,N./sum(N),'b'); hold on;
%     plot(xout2,N2./sum(N2),'r');
%     return;   
    
    % Now find new peaks in the residual
    dataMean = mean(residual);
    dataStd  = std(residual);
    
%     %plot(data.dVdT,'b'); hold on;
%     plot(residual,'m'); hold on;
%     plot(xlim(),[1 1].*dataStd*peakLimit,'k--');
%     plot(xlim(),-[1 1].*dataStd*peakLimit,'k--');

    
    peakListN = []; peakListP = []; peakHeightsN = []; peakHeightsP = [];
    ixN = []; ixP = [];
    if negPeaks
        [peakListN,peakHeightsN] = peakFind(residual,[0,1]);
        ixN = find((peakHeightsN - dataMean)./dataStd < -peakLimit);
    end
    if posPeaks
        [peakListP,peakHeightsP] = peakFind(residual,[1,0]);
        ixP = find((peakHeightsP - dataMean)./dataStd > peakLimit);
    end   
    RpeakList = [peakListN(ixN);peakListP(ixP)];
    
%     size(RpeakList)
%     scatter(RpeakList,residual(RpeakList),'ro');
%     return;
    
    % Remove peaks too close to start or end
    remIX = find((RpeakList <= 2*spikeHalfWidth) | (RpeakList >= (length(data.dVdT) - 2*spikeHalfWidth)));
    RpeakList(remIX) = [];
    
    % Assemble trace snippets into a matrix for dimensionality reduction
    for peakN = 1:length(RpeakList)
        saveSnip = residual((RpeakList(peakN) - spikeHalfWidth):(RpeakList(peakN) + spikeHalfWidth));
        dataMatrix(end+1,:) = saveSnip';
    end
    
    % Add peaks to existing list.
    peakList = [peakList, RpeakList'];
    
    % Reduce dimensionality
    PCAdim = 50;
    perplexity = getPerplexity(size(dataMatrix,1));
    theta = .3;
    mappedX = fast_tsne(dataMatrix, PCAdim, perplexity, theta);
%     [COEFFS, SCORES] = princomp(dataMatrix);
%     mappedX = SCORES(:,1:2);
    
    
    % Cluster
    Z = linkage(mappedX,'ward','euclidean');
    IDX = cluster(Z,'maxclust',nClusters);
%     IDX = kmeans(mappedX,nClusters);

    % Sort clusters by peak values
    for clustN=1:nClusters
        ix = find(IDX == clustN);
        meanWaveform = mean(dataMatrix(ix,:),1);
        maxWave(clustN) = abs(meanWaveform(spikeHalfWidth+1));
    end
    [B,IX] = sort(maxWave,'descend');
    for clustN=1:nClusters
        findClust = IX(clustN);
        ix = find(IDX == findClust);
        newIDX(ix) = clustN;
    end
    IDX = newIDX;

    
    % Save cluster info to the data structure
    data.spikeSamples = peakList;
    data.spikeClusters = IDX;
    data.spikeEmbedding = mappedX;
    
    % Make well-separated spike avg. waveforms.
    data = makeSpikeAvg(data);
    
    
    