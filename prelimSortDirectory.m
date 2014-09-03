function prelimSortDirectory(dateCode, wildcardString, nClusters)

    load('dataLocation.mat');    
    baseName = [dataLocation,'/',dateCode,'/'];
    wildcard = ['RL',dateCode,'_',wildcardString];
    
    fileList = jdir([baseName,wildcard]);

    for fileN = 1:length(fileList)
        
        wholeName = [baseName,fileList(fileN).name];
        prelimSortFiles({wholeName}, nClusters);

    end
