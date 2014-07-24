function [peakSamples, peakHeights] = peakFind(varargin)

    signal = varargin{1};
    if nargin > 1
        signsToUse = varargin{2};
    else
        %  Use Upper peaks, Lower peaks
        signsToUse = [1,1];
    end

    sigSlope  = [diff(signal);0];
    signSlope = sign(sigSlope);
    % Can be -1, 0, 1, prevent adjacent hits by removing 0 slopes
    % In practice, this is quite uncommon
    signSlope = (round((signSlope/2)+.5)-.5)*2;
    diffSignSlope = [diff(signSlope);0];
    
    peakSamples = [];
    peakHeights = [];
    if (signsToUse(1) == 1)
        ix = find(diffSignSlope < 0);
        peakSamples = [peakSamples;ix];
    end
    if (signsToUse(2) == 1)
        ix = find(diffSignSlope > 0);
        peakSamples = [peakSamples;ix];
    end
    peakSamples = peakSamples + 1;
    peakHeights = signal(peakSamples);
    
%     figure;
%     plot(signal,'b.'); hold on;
%     plot(peakSamples,peakHeights,'ro');
%     pause();
    