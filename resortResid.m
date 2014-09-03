% resortResid() sort reclassifies existing detected spikes by subtracting
% off other classified spikes and classifying the residual.
function data = resortResid(data)

    residual = makeResidual(data);
    spikeHalfWidth = round(data.spikeWidth/2*data.sampleRate);
    nClusters = length(unique(data.spikeClusters));
    
    % Assemble trace snippets into a matrix for dimensionality reduction
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
        % Don't let the new peak walk off the end of the trace...
        if ((newPeak <= spikeHalfWidth) || (newPeak >= length(residual) - spikeHalfWidth))
            newPeak = samplePeak;
        end
        reclassSnip = reclassFL((newPeak - spikeHalfWidth):(newPeak + spikeHalfWidth));
        
%                 plot(.002 + data.dVdT((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)),'r');hold on;
%                 plot(residual((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)),'c');
%                 plot(avgSpikeToAdd,'g');
%                 plot(reclassWindow,'b'); 
%                 plot(reclassSnip,'m'); hold off;
%                 if (abs(newPeak - samplePeak) > 0)
%                     pause();
%                 end
        
        saveSnip = reclassSnip;
        
        peakList(end+1) = newPeak;
        dataMatrix(end+1,:) = saveSnip';
    end
    
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
    
%     for n = 1:length(data.spikeClusters) 
%         if (data.spikeClusters(n) ~= IDX(n))
%             disp([num2str(n),': ',num2str(data.spikeClusters(n)),'->',num2str(IDX(n))]);
%             plot(dataMatrix(n,:));
%             pause();
%         end
%     end

    
    % Save cluster info to the data structure
    data.spikeSamples = peakList;
    data.spikeClusters = IDX;
    data.spikeEmbedding = mappedX;
    
    % Make well-separated spike avg. waveforms.
    data = makeSpikeAvg(data);
    