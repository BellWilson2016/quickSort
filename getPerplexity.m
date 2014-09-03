function perplexity = getPerplexity(nPoints)

    if (nPoints < 100)
        perplexity = round(nPoints/5);       
    else
        perplexity = 30;
    end
        