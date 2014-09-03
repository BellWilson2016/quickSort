function data = doubleScan(data, peakLimit, clearAllFirst, clearNeighborhood)

    negPeaks = true;
    posPeaks = false;
        
    if clearAllFirst
        data.spikeSamples = [];
        data.spikeClusters = [];
        data.spikeEmbedding = [];
    end
    
    residual = makeResidual(data);
    spikeHalfWidth = round(data.spikeWidth/2*data.sampleRate);
    % Don't pick up peaks close to the residual ends...
    residual(1:3*spikeHalfWidth) = 0;
    residual((end-3*spikeHalfWidth):end) = 0;
    nClusters = length(data.spikeAvg);
    
    prevPeaks = [];
    [peakSample, peakHeight] = refreshResidPeaks(residual, posPeaks, negPeaks, prevPeaks, spikeHalfWidth); 
    while (peakHeight > peakLimit*std(residual))
   
        if clearNeighborhood
            sampIX = find(abs(data.spikeSamples - peakSample) < spikeHalfWidth);
            fprintf(['Clearing: ',num2str(length(sampIX)),' @ ',num2str(peakSample),'  ']);
            data.spikeSamples(sampIX) = [];
            data.spikeClusters(sampIX) = [];
            data.spikeEmbedding(sampIX,:) = [];
        end
        
        data = doubleSpike(data, peakSample./data.sampleRate);
        residual = makeResidual(data);
                
        prevPeaks(end+1) = peakSample;
        [peakSample, peakHeight] = refreshResidPeaks(residual, posPeaks, negPeaks, prevPeaks, spikeHalfWidth); 
    end
        
    % Find the largest residual peak that's not previously sorted.
    function [peakSample, peakHeight] = refreshResidPeaks(residual, posPeaks, negPeaks, prevPeaks, spikeHalfWidth)  
        
        % Find peaks in the residual
        [peakList, peakHeights] = peakFind(residual, [posPeaks, negPeaks]);
        
        % Remove peaks near the start or the end
        ix = find((peakList <= 4*spikeHalfWidth) | (peakList >= (length(residual) - 4*spikeHalfWidth)) );
        peakList(ix) = []; peakHeights(ix) = [];
        
        % Remove v. small peaks
        ix = find(abs(peakHeights) < 3*std(residual));
        peakList(ix) = []; peakHeights(ix) = [];
        
        % Remove peaks very close to previous to prevent loops
        if length(prevPeaks > 0)
            origIX = dsearchn(prevPeaks(:), peakList);
            prevList = prevPeaks(origIX);
            distances = abs(peakList - prevList(:));
            ix = find(distances < spikeHalfWidth);
            peakList(ix) = []; peakHeights(ix) = [];
        end
        
        % Sort peaks by height
        [peakHeight, ix] = max(abs(peakHeights));
        peakSample = peakList(ix);
    
            
        
        
    