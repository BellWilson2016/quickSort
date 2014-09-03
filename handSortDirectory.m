classdef handSortDirectory < handle
    
    
    properties
        baseDir
        wildcardString
        fileList
        fileNumber 
        processFlag
    end
    
    methods
        
        function HSD = handSortDirectory(baseDir,wildcardString)
            HSD.baseDir = baseDir;
            HSD.wildcardString = wildcardString;
            HSD.fileList = jdir([baseDir,wildcardString]);
            HSD.fileNumber = 0; 
            HSD.processFlag = false;
        end
        
        function process(HSD, varargin)
            
            if nargin > 1
                HSD.fileNumber = varargin{1} - 1;
            end
            
            HSD.processFlag = true;
            HSD.n();
            
        end
        
        function n(HSD)
           
            if (HSD.fileNumber < length(HSD.fileList))
                HSD.fileNumber = HSD.fileNumber + 1;
            else
                disp(['All sorted from: ',HSD.wildcardString]);
                return;
            end
            HSD.sortOne();
        end
        
        function p(HSD)
           
            if (HSD.fileNumber > 1)
                HSD.fileNumber = HSD.fileNumber - 1;
            else
                disp(['At start of list.']);
                return;
            end
            HSD.sortOne();
        end
        function sortOne(HSD)
            disp(['Loading: ',[HSD.baseDir,HSD.fileList(HSD.fileNumber).name]]);
            handSort([HSD.baseDir,HSD.fileList(HSD.fileNumber).name],HSD);
        end
        
    end
    
    

end
