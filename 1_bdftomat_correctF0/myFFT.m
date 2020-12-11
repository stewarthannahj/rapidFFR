function [f, dB, V, phz] = myFFT(y, varargin)
%
%  Version 1.0 - December 2014
%  Version 2.0 - December 2014
%     allow choice of NFFT and option to display in rms
%  Version 2.5 - September 2016
%     allow reference for dB scale and option for plotting
%  Version 3.0 - October 2016
%     return phase values and have linear voltage values as peak or rms
%     use argument parser for easier calling

%  y - signal
%  SampFreq
%  keepLength - logical value: If TRUE, do not adjust to the next power of 2
%  RMS = 1 gives all outputs in rms
%  DR
%  dBref
%  mainTitle
%  Plots
%   Plots = 0 : no plots
%   Plots = 1 : ordinary line graph
%   Plots = 2 : points instead

p = inputParser;
p.addRequired('y', @isnumeric);
p.addParameter('SampFreq', 22050, @isnumeric);
p.addParameter('keepLength', 0, @isinteger);
p.addParameter('Plots', 0, @isnumeric);
p.addParameter('linearPlots', 0, @isnumeric);
p.addParameter('dBref', 1, @isnumeric);
p.addParameter('DR', 50, @isnumeric);
p.addParameter('RMS', 1, @isnumeric);
p.addParameter('nearestMult', 10, @isnumeric);
p.addParameter('mainTitle', 'Single-Sided Amplitude Spectrum', @ischar);

p.parse(y, varargin{:});
a=p.Results;

if a.linearPlots 
    a.Plots=1;
end

% for ease, make the signal have an even number of points
if mod(max(size(y)),2)
    y=[y;0];
end

L=length(a.y);
if ~a.keepLength
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
else
    NFFT=L;
end
Y = fft(a.y,NFFT)/L;
f = a.SampFreq/2*linspace(0,1,NFFT/2+1);
% phz = angle(Y);
% phz = phz(1:NFFT/2+1);

phz=atan2(imag(Y),real(Y))*180/pi;
phz = phz(1:NFFT/2+1);

if a.RMS
    V = 2*abs(Y(1:NFFT/2+1))/sqrt(2);
    % calculate amplitude spectrum in units of rms
    dB = 20*log10(2*abs(Y(1:NFFT/2+1))/(a.dBref*sqrt(2)));
else
    V = 2*abs(Y(1:NFFT/2+1));
    % Plot single-sided amplitude spectrum re peak amplitude
    dB = 20*log10(2*abs(Y(1:NFFT/2+1))/a.dBref);
end

if a.Plots
    % mask phase values outside DR
    X2=(dB>max(dB)-a.DR);
    h = stem(f(X2), phz(X2));
    ylim([-720 720])
    xlim([0 a.SampFreq/2])
    figure
    if a.linearPlots
        h=stem(f,V);
        if a.RMS
            ylabel('|Y(f)| rms')
        else
            ylabel('|Y(f)| peak')
        end
    else 
        newYup = ceil(max(dB)/a.nearestMult)*a.nearestMult;        
        h=stem(f,dB,'BaseValue',newYup-a.DR);
        if a.RMS
            ylabel('|Y(f)| re rms (dB)')
        else
            ylabel('|Y(f)| re peak (dB)')
        end
        
        ylim([newYup-a.DR newYup])
        xlim([0 a.SampFreq/2])
        title(a.mainTitle)
        xlabel('Frequency (Hz)')
        grid on 
    end
    
end

