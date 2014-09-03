function plotWaveforms(data)


    % colorList = ['r','g','b','m','c','y','k','w'];
    if ~isfield(data,'spikeAvg');
        data = makeSpikeAvg(data);
    end
    
        for clustN = 1:length(data.spikeAvg)
            waveform = data.spikeAvg{clustN};
            plot(waveform,'Color',pretty(clustN)); hold on;
        end
        axis tight;
        set(gca,'XTick',[],'YTick',[]);
