function data = makeSpikeAvg(data)

    spikeBarrier = .1;       % Spike Widths

    % Remove old averages
    data.spikeAvg = {};
    
    % For each cluster make an average
    clusterList = unique(data.spikeClusters);
    spikeWidthSamp = round(data.spikeWidth*data.sampleRate);
    for clustN = 1:length(clusterList)

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
            if (min(abs(spikeDiffs)) > 2*spikeBarrier*spikeWidthSamp)
                stSamp = sampIx - spikeWidthSamp;
                enSamp = sampIx + spikeWidthSamp;
                if ((stSamp > 0) && (enSamp < length(data.dVdT)))
                    allSpikes(:,end+1) = data.dVdT(stSamp:enSamp);
                end
            end
        end
        % But if you don't find any, use them all
        if (size(allSpikes,2) == 0)
            for sampIx = sampIxs
                stSamp = sampIx - spikeWidthSamp;
                enSamp = sampIx + spikeWidthSamp;
                if ((stSamp > 0) && (enSamp < length(data.dVdT)))
                    allSpikes(:,end+1) = data.dVdT(stSamp:enSamp);
                end
            end
        end
        
        data.spikeAvg{clustN} = mean(allSpikes,2);
             
    end