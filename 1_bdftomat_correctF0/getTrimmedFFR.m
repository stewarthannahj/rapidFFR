function x = getTrimmedFFR(fileName, nSamples,prestim, F0x)

% This function does 4 main things:
%   opens up the appropriate mat file
%   extracts the recorded wave for nSamples from the single trigger
%   (optionally) resamples the wave so that its F0=128 Hz if it is not
%       already at that value. The script does not determine this itself -
%       that is specified in the function call. Default: no resampling

% prestim is in ms

% F0x gives the F0 as found in the original wave
% if not 128 Hz, the original wave is resampled
if nargin < 4
    F0x=128; 
end

SampFreq=16384;
prestimSamples=(prestim/1000)*SampFreq;

load(fileName);
% ffr(:,1) is the wave
x=double(ffr(:,1));

% t=(0:length(x)-1)/SampFreq;
% plot(t,x), xlabel('time (s)')

% a 3rd-order Butterworth with cutoff=50 Hz will, with two in cascade,
% result in a filter that is -6 dB at 50 Hz, about -1 dB at 70 Hz,
% about -0.5 dB at 80 Hz and about -0.1 dB at 100 Hz.
%
% For 100 Hz:   100 150     175
%               -6  -0.8    -0.3
% For 80 Hz:   100 150
%               -2  -0.2
% design an appropriate filter
% HighPassCutoff = 70;
% [b,a] = butter(3,HighPassCutoff/(SampFreq/2),'high');
% x = filtfilt(b,a, x);
% 
% LoPassCutoff = 2000;
% [b,a] = butter(3,LoPassCutoff/(SampFreq/2));
% x = filtfilt(b,a, x);

if F0x ~= 128
    % new rate
    xOld = x;
    NewSampFreq=128*F0x;
    t=(0:length(x)-1)/SampFreq;
    tNew=(0:1/NewSampFreq:max(t));
    x = interp1(t,xOld,tNew)';
    trigger = interp1(t,ffr(:,2),tNew,'next'); %HJS debugging try 'nearest'. original = next
    % also need to find the new trigger point
    start = find(trigger);
    % need to adjust number of samples returned due 
    % to different sampling frequency
    x = x(start+prestimSamples:start+prestimSamples+128*floor(nSamples/F0x)-1); 
else
    % ffr(:,2) is the trigger
    start = find(ffr(:,2));
    x = x(start+prestimSamples:start+prestimSamples+nSamples-1);
end

