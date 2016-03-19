function prelimSortFiles(wholeNames, nClusters, sensitivities)

    incrementalPlotOn = true;

    for nameN = 1:length(wholeNames)
        
        wholeName = wholeNames{nameN};
        disp(wholeName);
        
        load(wholeName);
        % data = quickSort(data, nClusters, incrementalPlotOn);
        data = fullSort(data, nClusters, sensitivities);
        if incrementalPlotOn
            subplot(1,2,1);
            plotEmbeddings(data);
            subplot(1,2,2);
            plotWaveforms(data);
            pause(2);
            close gcf;
        end

        save([wholeName],'data');
    end