function rejectTraces(dateCode,expCode,traceNums)

    baseName = ['~/Desktop/Data/',dateCode,'/'];
    

    for traceNn = 1:length(traceNums)
        traceN = traceNums(traceNn);
        
        fileString = ['RL',dateCode,'_',expCode,'_',num2str(traceN,'%03d'),'.mat'];
        disp(['Rejecting: ',fileString]);
        load([baseName,fileString]);
        data.rejectTrace = true;
        
        save([baseName,fileString],'data');
    end