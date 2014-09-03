function plotPrelimSort(dateCode, wildcardString) 

    load('dataLocation.mat');    
    baseName = [dataLocation,'/',dateCode,'/'];
    wildcard = ['RL',dateCode,'_',wildcardString];
    fileList = dir([baseName,wildcard]);
    
    plotSize = [5,6];
    plottingFigure = figure();



    plotN = 1;
    page = 1;
    for fileN = 1:length(fileList)
    
    	load([baseName,fileList(fileN).name]);
    	if (true) %data.stimulus.stimNumber == 5
       		    
            figure(plottingFigure);
		    subplot(plotSize(1),plotSize(2),plotN);
		    plotWaveforms(data); set(gca,'XTick',[],'YTick',[]);
		    title(fileList(fileN).name,'Interpreter', 'none');
		    plotN = plotN + 1;
            
            subplot(plotSize(1),plotSize(2),plotN);
            plotEmbeddings(data);
            plotN = plotN + 1;      
		    pause(.1);
		    
		    % When the page is full, save it.
		    if ((plotN > plotSize(1)*plotSize(2)) || (fileN == length(fileList)))
		        plotN = 1;
		        savePDF(['SpikeSortingP',num2str(page),'.pdf']);
		        close all;
                if (fileN < length(fileList))
                    plottingFigure = figure();
                    page = page + 1;
                end
		    end  
		    
		end 
    end
