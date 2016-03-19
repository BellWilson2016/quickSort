function data = fullSort(data, nClusters, sensitivities)


%sensitivities = [1.4, 6, 4]; % ab1 was 1.2
%sensitivities = [  3, 6, 10]; % ab2
%sensitivities = [  1.8, 6, 4]; % small ab2
%sensitivities = [ 2.2, 6, 4]; % ab4


    % First, quick-sort
    % data2 = adaptQuickSort(data, nClusters);
    data2 = quickSort(data, nClusters, sensitivities(1));
    if length(unique(data2.spikeClusters)) == nClusters
        % Then try to reclassify each spike after accounting for surrounding
        % spikes.
        data3 = resortResid(data2);
        % Now redetect any spikes in the residual.
        data4 = redetectResid(data3, sensitivities(2));
        % Now reclassify those newly found spikes.
        data5 = resortResid(data4);
        % Now remove any spikes too close to each other
        [data6, nRemoved] = pairScan(data5);
        % Now reclassify again.
        data7 = resortResid(data6);
        % Now try to deal with difficult doublets
        data8 = doubleScan(data7, sensitivities(3), false, true);
        % Recompute the embedding for display;
        data9 = embedFromResidual(data8);
        
        disp(' ');
        disp(['quickSorted: ',num2str(length(data2.spikeClusters))]);
        disp('Resorted: ');
        compareSort(data2,data3);
        disp('Re-detected: ');
        compareSort(data3,data4);
        disp('Resorted: ');
        compareSort(data4,data5);
        disp(['Removed multiplets: ',num2str(nRemoved)]);
        disp('Resorted: ');
        compareSort(data6,data7);
        disp('Pair Sorted.');
        disp('Resorted: ');
        compareSort(data8,data9);
        
        disp(' ');
        
        data = data9;
    else
        data = data2;
    end
    
%     figure;
%     subplot(1,2,1);
%     plotEmbeddings(data8);
%     subplot(1,2,2);
%     plotEmbeddings(data9);
%     pause();
%     

    

    

