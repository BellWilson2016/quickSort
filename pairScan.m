% Removes spikes in the same cluster less that ISIlimit apart
function [data, nRemoved] = pairScan(data)

    ISIlimit = .003; % sec

    clusterList = unique(data.spikeClusters);
    for clustNn = 1:length(clusterList)
        clustN = clusterList(clustNn);
        
        nRemoved(clustN) = 0;
        nFound = 1;
        while (nFound > 0)
            ix = find(data.spikeClusters == clustN);
            sortedSamples = sort(data.spikeSamples(ix),'ascend');
            ISIs = diff(sortedSamples);
            ISIix = find(ISIs < ISIlimit*data.sampleRate);
            nFound = length(ISIix);
            if (nFound > 0)
                sampToRemove = sortedSamples(ISIix(1));
                origIX = dsearchn(data.spikeSamples(ix)',sampToRemove);

                data.spikeSamples(ix(origIX)) = [];
                data.spikeClusters(ix(origIX)) = [];
                data.spikeEmbedding(ix(origIX),:) = [];
                nRemoved(clustN) = nRemoved(clustN) + 1;
            end
        end
            
    end