% Requires bh_tSNE
function data = quickSort(data, nClusters, varargin)

    negPeaks = true;      % Negative going spikes
    posPeaks = false;
    peakLimit = 1;        % SD (abs. value)
    spikeWidth = .005;    % Seconds
    LPF =  1000;          % Hz
    HPF =  100;           % Hz
    
    if nargin > 2
        plotOn = varargin{1};
    else
        plotOn = false;
    end


        % Filter data, store 
        data.LPF.freq = LPF;
        data.LPF.h = fdesign.lowpass('N,F3dB',4,data.LPF.freq/(data.sampleRate/2));
        data.LPF.d = design(data.LPF.h,'butter');
        data.HPF.freq = HPF;
        data.HPF.h = fdesign.highpass('N,F3dB',4,data.HPF.freq/(data.sampleRate/2));
        data.HPF.d = design(data.HPF.h,'butter');

        lpV = filtfilt(data.LPF.d.sosMatrix,data.LPF.d.ScaleValues,data.V);
        data.fV = filtfilt(data.HPF.d.sosMatrix,data.HPF.d.ScaleValues,lpV);
        data.dVdT = [diff(data.fV);0];
        data.spikeWidth = spikeWidth;

    
    % Find peaks, only take biggest ones.
    spikeHalfWidth = round(spikeWidth/2*data.sampleRate);
    dataMean = mean(data.dVdT);
    dataStd  = std(data.dVdT);
    peakListN = []; peakListP = []; peakHeightsN = []; peakHeightsP = [];
    ixN = []; ixP = [];
    if negPeaks
        [peakListN,peakHeightsN] = peakFind(data.dVdT,[0,1]);
        ixN = find((peakHeightsN - dataMean)./dataStd < -peakLimit);
    end
    if posPeaks
        [peakListP,peakHeightsP] = peakFind(data.dVdT,[1,0]);
        ixP = find((peakHeightsP - dataMean)./dataStd > peakLimit);
    end   
    peakList = [peakListN(ixN);peakListP(ixP)];
    peakHeights = [peakHeightsN(ixN);peakHeightsP(ixP)];
    
    % Remove peaks too close to start or end
    remIX = find((peakList <= spikeHalfWidth) | (peakList >= (length(data.dVdT) - spikeHalfWidth)));
    peakList(remIX) = [];
    peakHeights(remIX) = [];
    
    % Assemble trace snippets into a matrix for dimensionality reduction
    dataMatrix = [];
    for peakN = 1:length(peakList)
        saveSnip = data.dVdT((peakList(peakN) - spikeHalfWidth):(peakList(peakN) + spikeHalfWidth));
        dataMatrix(end+1,:) = saveSnip';
    end
    
    % Reduce dimensionality
    PCAdim = 50;
    perplexity = 30;
    theta = .3;
    mappedX = fast_tsne(dataMatrix, PCAdim, perplexity, theta);
    
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
    data.spikeTimes   = peakList./data.sampleRate;
    data.spikeClusters = IDX;
    data.spikeEmbedding = mappedX;
    
    % Make well-separated spike avg. waveforms.
    data = makeSpikeAvg(data);
    
    % Plot if required
    if plotOn
        figure;
        subplot(2,2,1);
        plotEmbeddings(data);

        
        for clustN=1:nClusters

            ix = find(IDX == clustN);
            meanWaveform = mean(dataMatrix(ix,:),1);
            subplot(2,2,2);
            plot(dataMatrix(ix,:)','Color',pretty(clustN)); hold on;
            subplot(2,2,3);
            plot(meanWaveform,'Color',pretty(clustN)); hold on;

        end
    end
        
    
    
    