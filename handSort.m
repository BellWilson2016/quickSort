classdef handSort < handle
    
    events
        RemoveSpike
        AddSpike
        ConvertSpike
        RefreshData
        Quit
        SetPointLock
    end
    
    properties
        LPF =    1000;         % Hz
        HPF =     100;         % Hz
        zoomFactor = 1.25;
        translateFactor = .25;
        plotWin = .5;
        plotPosition = .25;
        peakThreshFactor = 6;       % Filters out small peaks in residual for seeking
        mainFig
        currentFilename
        data
        originalData
        colorList = [pretty(1);pretty(4);pretty(5);pretty(2);[1,0,1];pretty(7);pretty(8)];
        spikeCategories = ['A','B','C','D','E','F','G'];
        centerLineHandle = [];
        spikeFix = false;
        peakFix  = false;
        time
        residual
        peaks
        mode = 0;
        selectedPointIX = [];
        daughterFigs
        caller
    end
    
    methods
        
        function HS = handSort(fileName, varargin)
            
            if nargin > 1
                HS.caller = varargin{1};
            else
                HS.caller = [];
            end
            
            HS.loadData(fileName);
            
            HS.peaks.peakSamples = [];
            HS.peaks.peakHeights = [];
            
            % Calculate a timebase, and find all the peaks in the residual.
            HS.time = (1:length(HS.data.dVdT))./HS.data.sampleRate;
            HS.residual = []; 
            HS.getResidualPeaks();
            
            % Create the main figure
            HS.mainFig.handle = figure('MenuBar','none',...
                                'Interruptible','off',...
                                'BusyAction','queue');
            set(HS.mainFig.handle,'KeyPressFcn',@HS.keyPress);
            HS.mainFig.windowPos = [ 1027         588        1916         643];
            HS.mainFig.axisPos   = [.05 .05 .9 .9];
            plot(0);
            set(HS.mainFig.handle,'Position',HS.mainFig.windowPos);
            set(gca,'Position',HS.mainFig.axisPos);
 
            % Add listening objects            
            HS.addListener(embeddingPlot(HS));
            HS.addListener(timeHistPlot(HS));
            HS.addListener(avgWavePlot(HS));
            HS.addListener(peakHeightPlot(HS));
            
            HS.rePlotMain();
        end
        
        function addListener(HS, listeningObject)
           HS.daughterFigs{end+1} = listeningObject;
           addlistener(HS, 'RemoveSpike', @listeningObject.removeSpike); 
           addlistener(HS, 'AddSpike', @listeningObject.addSpike);
           addlistener(HS, 'ConvertSpike', @listeningObject.convertSpike);
           addlistener(HS, 'RefreshData', @listeningObject.refreshData);
           addlistener(HS, 'Quit', @listeningObject.quit);
           addlistener(HS, 'SetPointLock', @listeningObject.setPointLock);
        end
        
        function loadData(HS, fileName)
            % Load the data
            HS.currentFilename = fileName;
            loadedData = load(HS.currentFilename);
            HS.data = loadedData.data;
            HS.originalData = HS.data;
          
            % Condition the data in case a bad sorter generated it
            HS.conditionData();
            
            disp('Data loaded, conditioned.');  
        end
            
        
        function conditionData(HS)
            
            % Add fields if necessary
            if ~isfield(HS.data,'spikeSamples');
                HS.data.spikeSamples = [];
            end
            if ~isfield(HS.data,'spikeClusters');
                HS.data.spikeClusters = [];
            end
            if ~isfield(HS.data,'rejectTrace')
                HS.data.rejectTrace = false;
            end
            HS.data.spikeClusters = HS.data.spikeClusters(:);
            
            if isfield(HS.data.stimulus,'stimNumber')
                disp(['Stim #',num2str(HS.data.stimulus.stimNumber)]);
            end
            
            % Filter data, store
            HS.data.LPF.freq = HS.LPF;
            HS.data.LPF.h = fdesign.lowpass('N,F3dB',4,HS.data.LPF.freq/(HS.data.sampleRate/2));
            HS.data.LPF.d = design(HS.data.LPF.h,'butter');
            HS.data.HPF.freq = HS.HPF;
            HS.data.HPF.h = fdesign.highpass('N,F3dB',4,HS.data.HPF.freq/(HS.data.sampleRate/2));
            HS.data.HPF.d = design(HS.data.HPF.h,'butter');
            lpV = filtfilt(HS.data.LPF.d.sosMatrix,HS.data.LPF.d.ScaleValues,HS.data.V);
            HS.data.fV = filtfilt(HS.data.HPF.d.sosMatrix,HS.data.HPF.d.ScaleValues,lpV);
            HS.data.dVdT = [diff(HS.data.fV);0].*HS.data.sampleRate;
            
            % Make an average spikes waveform for calculating the residuals
            HS.data = makeSpikeAvg(HS.data);
            HS.getResidualPeaks();
           
        end
        
   
        
        function getResidualPeaks(HS)
            HS.residual = makeResidual(HS.data);
            [peakSamples, peakHeights] = peakFind(HS.residual,[1,1]);
            % Remove low peaks to allow fast scanning.
            ix = find(abs(peakHeights) < HS.peakThreshFactor*std(HS.residual));
            peakSamples(ix) = [];
            peakHeights(ix) = [];
            HS.peaks.peakSamples = peakSamples;
            HS.peaks.peakHeights = peakHeights;
        end
        
        function plotStimulus(HS)
            

            minSpace = min(HS.data.dVdT);
            span = 50;
            minSpace = minSpace - 3*span;
            lowVal  = minSpace + span;
            highVal = minSpace + 2*span;
            redLow  = minSpace;
            redHigh = minSpace + span;
                     
            pulses = HS.data.stimulus.pulse;
            for pulseN = 1:length(pulses)
                onset = pulses(pulseN).onset;
                offset = onset + pulses(pulseN).duration;
                fill([onset onset offset offset], [lowVal highVal highVal lowVal],'b',...
                    'EdgeColor','none','FaceColor','b');                
            end
            redOnset = HS.data.stimulus.redBG.onset;
            redOffset = redOnset + HS.data.stimulus.redBG.duration;
            fill([redOnset redOnset redOffset redOffset], [redLow redHigh redHigh redLow],'r',...
                    'EdgeColor','none','FaceColor','r');   
            
        end
            
        
        function rePlotMain(HS)
            
            figure(HS.mainFig.handle);
            cla;
            
            % Plot the main trace
            plot(HS.time,HS.data.dVdT,'k'); hold on;
            % Set the bounds
            xlim(HS.plotPosition + HS.plotWin.*[-.5 .5]);  
            
            % Set trace background
            if HS.data.rejectTrace
                set(gca,'Color',[1 .8 .8]);    
            else
                set(gca,'Color',[.85 .85 1]);
            end

            % Plot the residual with bounds
            plot([HS.time(1) HS.time(end)],...
                (abs(min(HS.residual)) + max(HS.data.dVdT) + HS.peakThreshFactor*std(HS.residual)).*[1 1],...
                'k--');
            plot([HS.time(1) HS.time(end)],...
                (abs(min(HS.residual)) + max(HS.data.dVdT) - HS.peakThreshFactor*std(HS.residual)).*[1 1],...
                'k--');
            plot(HS.time,HS.residual + abs(min(HS.residual)) + max(HS.data.dVdT),'Color',[0 0 1]);

            % Plot the spikes
            clusterList = unique(HS.data.spikeClusters);
            for clustNn = 1:length(clusterList)
                clustN = clusterList(clustNn);
                ix = find(HS.data.spikeClusters == clustN);
                scatter(HS.time(HS.data.spikeSamples(ix)),HS.data.dVdT(HS.data.spikeSamples(ix)) - 20*(clustN-1),...
                    'Marker','.','MarkerEdgeColor',HS.colorList(clustN,:));
            end
            
            HS.plotStimulus(); hold on;

        end
        
        function keyPress(HS,H,E)

            clustNum = 0;
            
            switch E.Key
                case '2'
                    HS.peakThreshFactor = HS.peakThreshFactor*1.1;
                    HS.getResidualPeaks();
                    HS.rePlotMain();
                case '1'
                    HS.peakThreshFactor = HS.peakThreshFactor/1.1;
                    HS.getResidualPeaks();
                    HS.rePlotMain();
                case 'l'
                    newPos = HS.plotPosition + HS.plotWin*HS.translateFactor;
                    HS.setFocusLocation(newPos);
                    HS.setMode(0);
                case 'semicolon'
                    newPos = HS.time(end) - HS.plotWin/2;
                    HS.setFocusLocation(newPos);
                    HS.setMode(0);
                case 'h'
                    newPos = HS.time(1) + HS.plotWin/2;
                    HS.setFocusLocation(newPos);
                    HS.setMode(0);
                case 'j'
                    newPos = HS.plotPosition - HS.plotWin*HS.translateFactor;
                    HS.setFocusLocation(newPos);
                    HS.setMode(0);
                case 'i'
                    HS.plotWin = HS.plotWin/HS.zoomFactor;
                    xlim(HS.plotPosition + HS.plotWin.*[-.5 .5]);
                case 'period'
                    HS.plotWin = 0.5;
                    xlim(HS.plotPosition + HS.plotWin.*[-.5 .5]);
                case 'k'
                    HS.plotWin = HS.plotWin*HS.zoomFactor;
                    xlim(HS.plotPosition + HS.plotWin.*[-.5 .5]);
                case 'comma'
                    HS.plotWin = HS.time(end)-HS.time(1);
                    newPos = HS.plotWin/2;
                    HS.setFocusLocation(newPos);
                    HS.setMode(0);
                    
                % Seek right to the next spike
                case 'o'
                    distance = HS.time(HS.data.spikeSamples) - HS.plotPosition;
                    distIX = find(distance > 0);
                    [C,minIX] = min(distance(distIX));
                    ix = distIX(minIX);
                    if ~isempty(ix)
                        newPos =  HS.time( HS.data.spikeSamples(ix));
                        HS.selectedPointIX = ix;
                        HS.setFocusLocation(newPos);
                        HS.setMode(1, ix);
                    end
                % Seek left to the next spike
                case 'u'
                    distance = -(HS.time(HS.data.spikeSamples) - HS.plotPosition);
                    distIX = find(distance > 0);
                    [C,minIX] = min(distance(distIX));
                    ix = distIX(minIX);
                    if ~isempty(ix)
                        newPos =  HS.time( HS.data.spikeSamples(ix));
                        HS.selectedPointIX = ix;
                        HS.setFocusLocation(newPos);
                        HS.setMode(1, ix);
                    end
                    
                % Seek right to the next peak
                case 'p'
                    distance = HS.time(HS.peaks.peakSamples) - HS.plotPosition;
                    distIX = find(distance > 0);
                    [C,minIX] = min(distance(distIX));
                    ix = distIX(minIX);
                    if ~isempty(ix)
                        newPos =  HS.time(HS.peaks.peakSamples(ix));
                        HS.setFocusLocation(newPos);
                        HS.setMode(2);      
                    end
                    
                case 'backquote'
                    
                    fprintf('Running pair-wise matching...  ');
                    HS.data = doubleSpike(HS.data,HS.plotPosition);
                    HS.refreshData();
                    
                case 'tab'
                    
                    fprintf('Running single-spike matching...  ');
                    HS.data = singleSpike(HS.data,HS.plotPosition);
                    HS.refreshData();
                    % Seek to the added spike
                    newPos =  HS.time( HS.data.spikeSamples(end));
                    HS.selectedPointIX = length(HS.data.spikeSamples);
                    HS.setFocusLocation(newPos);
                    HS.setMode(1, HS.selectedPointIX);
                    
                    
                % Seek left to the next peak
                case 'y'
                    distance = -(HS.time(HS.peaks.peakSamples) - HS.plotPosition);
                    distIX = find(distance > 0);
                    [C,minIX] = min(distance(distIX));
                    ix = distIX(minIX);
                    if ~isempty(ix)
                        newPos =  HS.time(HS.peaks.peakSamples(ix));
                        HS.setFocusLocation(newPos);
                        HS.setMode(2);         
                    end
                case 'r'
                    % If we're fixed on a spike, remove it.
                    if (HS.mode == 1)                                                   
                        remIX = dsearchn(HS.time(HS.data.spikeSamples)',HS.plotPosition);
                        disp(['Removed ',HS.spikeCategories(HS.data.spikeClusters(remIX))]);
                        % Notify all listeners that we're removing a spike
                        HS.removeSpike(remIX);
                        HS.setMode(2);
                    % Otherwise remove the last added spike    
                    else
                        newPos = HS.time(HS.data.spikeSamples(end));
                        HS.setFocusLocation(newPos);
                        HS.setMode(0);
                        remIX = length(HS.data.spikeSamples);
                        disp(['Removed last: ',HS.spikeCategories(HS.data.spikeClusters(remIX))]);
                        HS.removeSpike(remIX);
                    end
                case 's'
                    data = HS.data;
                    save(HS.currentFilename,'data');
                    clear data;
                    disp(['Saved to: ',HS.currentFilename]);
                    
                case 'n'
                    HS.data.rejectTrace = ~HS.data.rejectTrace;
                    disp(['rejectTrace set to: ',num2str(HS.data.rejectTrace)]);
                    HS.rePlotMain();
                
                case 'a'
                    clustNum = 1;
                case 'b'
                    clustNum = 2;
                case 'c'
                    clustNum = 3;
                case 'd'
                    clustNum = 4;
                case 'e'
                    clustNum = 5;
                case 'f'
                    clustNum = 6;
                case 'g'
                    clustNum = 7;
                    
                case 'z'
                    if strcmp(input('Are you sure you want to revert to the original sort? (y/n) ','s'),'y')
                        HS.data = HS.originalData;
                        HS.refreshData();
                    end
                
                case 'm'
                    fromSpike = input('Map from: ','s');
                    toSpike   = input('Map to: ','s');
                    for n = 1:length(HS.spikeCategories)
                        if strcmpi(fromSpike,HS.spikeCategories(n))
                            fromSpikeN = n;
                        end
                        if strcmpi(toSpike,HS.spikeCategories(n))
                            toSpikeN = n;
                        end
                    end
                    ix = find(HS.data.spikeClusters == fromSpikeN); 
                    if strcmpi(toSpike,'x')
                        HS.data.spikeClusters(ix) = [];
                        HS.data.spikeSamples(ix) = [];
                        HS.data.spikeEmbedding(ix,:) = [];
                    else
                        HS.data.spikeClusters(ix) = toSpikeN;
                    end
                    HS.refreshData();
                    
                case 'q'
                    HS.quit();
                
                case 'f1'
                    disp('Re-embedding current spikes');
                    HS.data = embedFromResidual(HS.data);
                    HS.refreshData();
                    
                case 'f2'
                    disp('Template matching with current waveforms...');
                    HS.data = doubleScan(HS.data,4,true,false);
                    HS.data = embedFromResidual(HS.data);
                    HS.refreshData();
                
                case 'f3'
                    disp('Select points in embedding plot...');
                    EP = HS.daughterFigs{1};
                    figure(EP.windowHandle);
                    [x1,y1] = ginput(1);
                    [x2,y2] = ginput(1);
                    xVec = sort([x1 x2],'ascend');
                    yVec = sort([y1 y2],'ascend');
                    newCluster = input('What cluster to map to? ','s');
                    for n = 1:length(HS.spikeCategories)
                        if strcmpi(newCluster,HS.spikeCategories(n))
                            toSpikeN = n;
                        end
                        if strcmpi(newCluster,'x')
                            toSpikeN = 0;
                        end
                    end
                    ix = find((HS.data.spikeEmbedding(:,1) > xVec(1)) & ...
                              (HS.data.spikeEmbedding(:,1) < xVec(2)) & ...
                              (HS.data.spikeEmbedding(:,2) > yVec(1)) & ...
                              (HS.data.spikeEmbedding(:,2) < yVec(2)));
                    if toSpikeN > 0      
                        HS.data.spikeClusters(ix) = toSpikeN;
                        disp(['Changed ',num2str(length(ix)),' spikes.']);
                    else
                        HS.data.spikeClusters(ix) = [];
                        HS.data.spikeEmbedding(ix,:) = [];
                        HS.data.spikeSamples(ix) = [];
                    end
                    HS.refreshData();
                    
                    
                otherwise
                    disp(['Uncaught keypress: ',E.Key]);
            end
            
            % Do spike adds and switches
            if clustNum > 0
                % If we're unfixed, do a click-spike
                if (HS.mode == 0)
                    disp(['Click to add an ',HS.spikeCategories(clustNum),':']);
                	[x,y] = ginput(1);
                    % Normalize for equal screen pixels
                    aspectRatio = daspect();
                    % Use peaks in residual
                    [peakSamples, peakHeights] = peakFind(HS.residual,[1,1]);
                    ix = dsearchn([HS.time(peakSamples)', peakHeights./aspectRatio(2)],[x,y./aspectRatio(2)]);
                    % Add the spike
                    disp(['Added: ',HS.spikeCategories(clustNum)]);
                    HS.addSpike(peakSamples(ix),clustNum);
                    % Scan to spike
                    newPos = HS.time(peakSamples(ix));
                    HS.setFocusLocation(newPos);
                    HS.setMode(1, length(HS.data.spikeSamples));
                % If we're spike fixed, convert the locked spike    
                elseif (HS.mode == 1)     	
                    spikeIX = dsearchn(HS.time(HS.data.spikeSamples)',HS.plotPosition);
                    disp(['Changed ',HS.spikeCategories(HS.data.spikeClusters(spikeIX)),...
                          ' -> ',HS.spikeCategories(clustNum)]);  
                    HS.convertSpike(spikeIX, clustNum);
                    HS.setMode(1, spikeIX);
                % If we're peak fixed, add a spike at the peak    
                elseif (HS.mode == 2)
                    peakSample = dsearchn(HS.time',HS.plotPosition);
                    disp(['Added: ',HS.spikeCategories(clustNum)]);
                    HS.addSpike(peakSample, clustNum);
                    HS.setMode(1, length(HS.data.spikeSamples));
                 end
                
            end
            
        end
        
        
        function refreshData(HS)
            
            HS.conditionData();
            HS.rePlotMain();
            
            notify(HS, 'RefreshData');
        end
       
        function setMode(HS, modeNum, varargin)

            HS.mode = modeNum;
            if (modeNum == 1)
                spikeIX = varargin{1};
            else
                spikeIX = [];
            end

            try
                if ishandle(HS.centerLineHandle)
                    delete(HS.centerLineHandle);
                end
            catch
            end

            figure(HS.mainFig.handle);

            if (HS.mode == 0)
                HS.centerLineHandle = plot(HS.plotPosition.*[1 1],ylim(),'--','Color',[.7 .7 .7]);
                HS.selectedPointIX = [];
            elseif (HS.mode == 1)
                HS.centerLineHandle = plot(HS.plotPosition.*[1 1],ylim(),'--','Color',[.5 .5 1]);
            elseif (HS.mode == 2)
                HS.centerLineHandle = plot(HS.plotPosition.*[1 1],ylim(),'--','Color',[1 .5 .5]);  
                HS.selectedPointIX = [];
            end
            notify(HS,'SetPointLock',passEventData(spikeIX));

        end
        
        function removeSpike(HS, spikeIX)

            if (spikeIX <= length(HS.data.spikeSamples))
                HS.data.spikeSamples(spikeIX) = [];
                HS.data.spikeClusters(spikeIX) = [];
                HS.data.spikeEmbedding(spikeIX,:) = [];
                HS.selectedPointIX = [];
                HS.getResidualPeaks();
                HS.rePlotMain();
                
                notify(HS, 'RemoveSpike', passEventData(spikeIX));
            end          
        end
        
        function addSpike(HS, spikeSample, spikeCluster)
            
            HS.data.spikeSamples(end+1)  = spikeSample;
            HS.data.spikeClusters(end+1) = spikeCluster;
            HS.data.spikeEmbedding(end+1,:) = [NaN,NaN];
            spikeIX = length(HS.data.spikeSamples);
            HS.selectedPointIX = spikeIX;
            
            HS.getResidualPeaks();
            HS.rePlotMain();
            
            notify(HS, 'AddSpike', passEventData(spikeIX));
        end
        
        function convertSpike(HS, spikeIX, newCluster)
            
            HS.data.spikeClusters(spikeIX) = newCluster;
            
            HS.getResidualPeaks();
            HS.rePlotMain();
            
            notify(HS, 'ConvertSpike', passEventData(spikeIX));
        end
        
        function setFocusLocation(HS, newPos)

            HS.plotPosition = newPos;
            figure(HS.mainFig.handle);
            
            % Redraw the centerline marker
            try
                if ishandle(HS.centerLineHandle)
                    delete(HS.centerLineHandle);
                end
            catch
            end

            if (HS.mode == 0)
                HS.centerLineHandle = plot(HS.plotPosition.*[1 1],ylim(),'--','Color',[.7 .7 .7]);
                HS.selectedPointIX = [];
            elseif (HS.mode == 1)
                HS.centerLineHandle = plot(HS.plotPosition.*[1 1],ylim(),'--','Color',[.5 .5 1]);
            elseif (HS.mode == 2)
                HS.centerLineHandle = plot(HS.plotPosition.*[1 1],ylim(),'--','Color',[1 .5 .5]);    
                HS.selectedPointIX = [];
            end
                       
            xlim(HS.plotPosition + HS.plotWin.*[-.5 .5]);  

        end
        
        
        function quit(HS)
            
            notify(HS,'Quit');
            
            disp('Quitting...');
            close(HS.mainFig.handle);
            
            % Move on to the next file
            HS.data.handSorted = true;
            if ~isempty(HS.caller)
                pause(.1);
                if HS.caller.processFlag
                    HS.caller.n();
                end
            end
            
        end
        
    end
    
end


    