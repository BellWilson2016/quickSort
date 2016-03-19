% Recomputes the embedding using residual subtraction from current spike
% identifications.
function data = embedFromResidual(data)

    data = makeSpikeAvg(data);
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
%         % Align the classification window to the new peak.
%         [C, ix] = min(reclassWindow);
%         newPeak = samplePeak - spikeHalfWidth + ix - 1;     
%         % Don't let the new peak walk off the end of the trace...
%         if ((newPeak <= spikeHalfWidth) || (newPeak >= length(residual) - spikeHalfWidth))
%             newPeak = samplePeak;
%         end
%        reclassSnip = reclassFL((newPeak - spikeHalfWidth):(newPeak + spikeHalfWidth));
        reclassSnip = reclassWindow;
        
%                 plot(.002 + data.dVdT((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)),'r');hold on;
%                 plot(residual((samplePeak - spikeHalfWidth):(samplePeak + spikeHalfWidth)),'c');
%                 plot(avgSpikeToAdd,'g');
%                 plot(reclassWindow,'b'); 
%                 plot(reclassSnip,'m'); hold off;
%                 if (abs(newPeak - samplePeak) > 0)
%                     pause();
%                 end
        
        saveSnip = reclassSnip;
        dataMatrix(end+1,:) = saveSnip';
    end
    
    % Reduce dimensionality
    PCAdim = 50;
    perplexity = getPerplexity(size(dataMatrix,1));
    theta = .3;
%     save('dataMatrix.mat','dataMatrix','data');
    mappedX = fast_tsne(dataMatrix, PCAdim, perplexity, theta);


%      [COEFF,SCORE] = princomp(dataMatrix);
%      mappedX = SCORE(:,1:2);
    
    data.spikeEmbedding = mappedX;
    
    