function data = makeSpikeAvg(data)

    spikeBarrier = .5;       % Spike Widths

    % Remove old averages
    data.spikeAvg = {};
    
    % For each cluster make an average
    clusterList = unique(data.spikeClusters);
    spikeHalfWidth = round(data.spikeWidth/2*data.sampleRate);
    for clustNn = 1:length(clusterList)
        clustN = clusterList(clustNn);
        % Get a spike triggered average for each cluster
        ix = find(data.spikeClusters == clustN);
        sampIxs = data.spikeSamples(ix);
        allSpikes = [];
        for sampIxN = 1:length(sampIxs)
            sampIx = sampIxs(sampIxN);
            % Only average well separated spikes
            spikeDiffs = sampIx - data.spikeSamples(:);
            ix = find(spikeDiffs == 0);
            spikeDiffs(ix) = [];
            if (min(abs(spikeDiffs)) > 2*spikeBarrier*spikeHalfWidth)
                stSamp = sampIx - spikeHalfWidth;
                enSamp = sampIx + spikeHalfWidth;
                if ((stSamp > 0) && (enSamp < length(data.dVdT)))
                    allSpikes(:,end+1) = data.dVdT(stSamp:enSamp);
                end
            end
        end
        % But if you don't find any, use them all
        if (size(allSpikes,2) == 0)
            for sampIxN = 1:length(sampIxs)
                sampIx = sampIxs(sampIxN);
                stSamp = sampIx - spikeHalfWidth;
                enSamp = sampIx + spikeHalfWidth;
                if ((stSamp > 0) && (enSamp < length(data.dVdT)))
                    allSpikes(:,end+1) = data.dVdT(stSamp:enSamp);
                end
            end
        end
        
        % Make a zero-waveform for empty clusters
        if size(allSpikes, 2) == 0
            data.spikeAvg{clustN} = zeros(2*spikeHalfWidth+1,1);
        else
            data.spikeAvg{clustN} = mean(allSpikes,2);
        end
             
    end
