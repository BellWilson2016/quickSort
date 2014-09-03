    function compareSort(old, new)
        
        
        oldIX = old.spikeClusters;
        newIX = new.spikeClusters;
        if (length(oldIX) == length(newIX))
            disp(['     Changed: ',num2str(nnz(newIX(:) - oldIX(:)))]);
        else
            disp(['     Added: ',num2str(length(newIX) - length(oldIX))]);
        end