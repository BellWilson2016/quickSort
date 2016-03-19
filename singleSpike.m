% Uses a template matching to try to resolve complex spike 
% waveforms. Will match to single spike if that's best-fit.
function data = singleSpike(data, timePoint)

    spikeCategories = ['A','B','C','D','E','F','G'];

    % Assemble a list of possible pairs
    nClusters = length(data.spikeAvg);
    clusterList = 1:nClusters;
    pairList = [0,0];
    for baseSpike = 1:nClusters
        pairList(end+1,:) = [baseSpike,0];
% Only do single spikes!        
%         for addSpike = (baseSpike + 1):nClusters
%             pairList(end+1,:) = [baseSpike,addSpike];
%         end
    end
    
    % Find the snippet to work on.
    centerSample = round(data.sampleRate*timePoint);
    spikeWidth = length(data.spikeAvg{1});
    stSamp = centerSample - round(1.5*spikeWidth);
    enSamp = centerSample + round(1.5*spikeWidth);
    snippet = data.dVdT(stSamp:enSamp);
     
    template = [];
    spikeCodes = [];
    for pairN = 1:size(pairList,1)
        ix1 = pairList(pairN,1);
        ix2 = pairList(pairN,2);
        if (ix1 > 0)
            spike1 = data.spikeAvg{ix1};
        else
            spike1 = zeros(length(data.spikeAvg{1}),1);
        end
        if (ix2 > 0)
            spike2 = data.spikeAvg{ix2};
        else
            spike2 = zeros(length(data.spikeAvg{1}),1);
        end
     
        spikeHalfWidth = floor(spikeWidth/2);
        halfNlags = spikeHalfWidth; 
        Nlags = 2*halfNlags + 1;
        templateLength = Nlags + spikeWidth + 1;
        centerTemplate = floor(templateLength/2) + 1;
        
        if (ix2 > 0)
            aSamples = zeros(Nlags,1) + centerTemplate;
            bSamples = [-halfNlags:halfNlags]' + centerTemplate;

            aRaster = zeros(templateLength, Nlags);
            bRaster = zeros(templateLength, Nlags);
            for n=1:length(aSamples)
                aRaster(aSamples(n),n) = 1;
                bRaster(bSamples(n),n) = 1;
            end

            % Keep track of what spikes are when
            someCodes = [ones(Nlags,1)*ix1,ones(Nlags,1)*ix2, aSamples, bSamples];
            spikeCodes = cat(1,spikeCodes,someCodes);
        else
            aSamples = centerTemplate;
            bSamples = centerTemplate;
            aRaster = zeros(templateLength, 1);
            bRaster = zeros(templateLength, 1);
            aRaster(aSamples,1) = 1;
            bRaster(aSamples,1) = 1;
            
            someCodes = [ones(1,1)*ix1,ones(1,1)*ix2, aSamples, bSamples];
            spikeCodes = cat(1,spikeCodes,someCodes);
        end

         C1 = convn(aRaster, spike1, 'same');
         C2 = convn(bRaster, spike2, 'same');
         template = cat(2,template,C1 + C2);
    end

%     figure;
%     subplot(2,1,1);
%     image(aRaster' + bRaster','CDataMapping','scaled');
%     subplot(2,1,2);
%     image(template','CDataMapping','scaled')


    for startSample = 1:(length(snippet) - size(template,1))
        subSnip = snippet(startSample:(startSample+size(template,1)-1));
        
        snipMatrix = subSnip*ones(1,size(template,2));
        diffMatrix = snipMatrix - template;
        matchFactor(startSample,:) = std(diffMatrix,1)./std(snipMatrix,1);
    end

    [col, row] = find(matchFactor == min(matchFactor(:)));
    col = col(1); row = row(1); % Only take the first match.

%     close all;
% figure;
% subplot(2,1,1);
% image(-matchFactor','CDataMapping','scaled'); hold on;
% scatter(col,row,'bo');
% subplot(2,1,2);
% plot(stSamp:enSamp,data.dVdT(stSamp:enSamp)); hold on;
% plot(stSamp + col - 1 + (1:templateLength),template(:,row),'m'); 
% scatter(spikeCodes(row,3) + col + stSamp,data.dVdT(spikeCodes(row,3) + col + stSamp),'ro');
% scatter(spikeCodes(row,4) + col + stSamp,data.dVdT(spikeCodes(row,4) + col + stSamp),'go');hold off;
% axis tight;
% pause;

% Put the new spikes back in the structure
if spikeCodes(row,1) > 0
    data.spikeClusters(end+1) = spikeCodes(row,1);
    data.spikeSamples(end+1)  = spikeCodes(row,3) + col + stSamp - 2;
    data.spikeEmbedding(end+1,:) = [NaN,NaN];
    if spikeCodes(row,2) > 0
        data.spikeClusters(end+1) = spikeCodes(row,2);
        data.spikeSamples(end+1)  = spikeCodes(row,4) + col + stSamp - 2;
        data.spikeEmbedding(end+1,:) = [NaN,NaN];
        disp(['pair-matched ',spikeCategories(spikeCodes(row,1)),' / ',spikeCategories(spikeCodes(row,2))]);
    else
        disp(['pair-matched ',spikeCategories(spikeCodes(row,1)),' / null']);
    end
else
    disp(['pair-matched null / null']);
end



% addSpikes(1).clustN = spikeCodes(row,1);
% addSpikes(2).clustN = spikeCodes(row,2);
% addSpikes(1).sample = spikeCodes(row,3) + col + centerSample;
% addSpikes(2).sample = spikeCodes(row,4) + col + centerSample;

 

 
 
 





