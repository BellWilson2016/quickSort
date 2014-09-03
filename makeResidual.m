function residual = makeResidual(data)
   
    % For each cluster, convolve spikes with raster
    nClusters = length(data.spikeAvg);
    clusterList = 1:nClusters;
    for clustNn = 1:length(clusterList)
       clustN = clusterList(clustNn); 
       % Make a raster 
       raster = zeros(length(data.dVdT),1);
       ix = find(data.spikeClusters == clustN);
       sampIxs = data.spikeSamples(ix);
       % sampIxs
       raster(sampIxs) = 1;
       % Convolve spike shape with raster
       if clustN > length(data.spikeAvg)
           disp('Recalculating spike avg.');
           data = makeSpikeAvg(data);
       end
       spikeAvg = data.spikeAvg{clustN};
       if size(spikeAvg,1) == 0
           spikeAvg = zeros(101,1);
       end
       modelComp(:,clustN) = conv(raster,spikeAvg,'same');      
       
    end
    if length(clusterList) < 1
        modelComp = zeros(length(data.dVdT),1);
    end    
    
    modelV = sum(modelComp,2);
    residual = data.dVdT - modelV;