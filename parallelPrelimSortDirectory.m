function parallelPrelimSortDirectory(dateCode, wildcardString, nClusters, nHosts)

    load('dataLocation.mat');    
    baseName = [dataLocation,'/',dateCode,'/'];
    wildcard = ['RL',dateCode,'_',wildcardString];
    
    fileList = dir([baseName,wildcard]);
        
    jm = findResource('scheduler','type','lsf');
    set(jm,'ClusterMatlabRoot','/opt/matlab');
    job = createJob(jm);
    queueString = '-W 12:00 -q short';
    set(jm,'SubmitArguments',['-R "rusage[matlab_dc_lic=1]" ',queueString]);
    
    filesPerHost = ceil(length(fileList)/nHosts);
    startFile = 1; endFile = 1;
    while endFile < length(fileList)
        endFile = startFile + filesPerHost - 1;
        if endFile > length(fileList)
            endFile = length(fileList);
        end
        
        for n = 1:(endFile - startFile + 1)        
            wholeNames{n} = [baseName, fileList(startFile + n - 1).name];  
            disp(wholeNames{n});
        end
        disp('Grouping as job...');
        functionArgs = {wholeNames, nClusters};
		createTask(job, @prelimSortFiles, 0, functionArgs);
        
        startFile = endFile + 1;
    end
    
    submit(job);
        
        
    
    
    
    
    