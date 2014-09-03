function out = jdir(wildcard)

    [status, result] = system(['dir -1 ',wildcard,' | xargs -n1 basename']);
    if status == 0
        
        newlineIX = find(uint32(result) == 10);
        sIX = 1;
        for lineN = 1:length(newlineIX)
            out(lineN).name = result(sIX:(newlineIX(lineN)-1));
            sIX = newlineIX(lineN) + 1;
        end
        
    else
        out = [];
    end
    
    

    