function prelimSortDirectory(dateCode, wildcardString, nClusters)

    load('dataLocation.mat');    
    baseName = [dataLocation,'/',dateCode,'/'];
    wildcard = ['RL',dateCode,'_',wildcardString];
    
    incrementalPlotOn = false;

    fileList = dir([baseName,wildcard]);

    for fileN = 1:length(fileList)
        
        load([baseName,fileList(fileN).name]);
        
        
        disp(fileList(fileN).name);
        data = quickSort(data, nClusters, incrementalPlotOn);
        
        save([baseName,fileList(fileN).name],'data');
    end
