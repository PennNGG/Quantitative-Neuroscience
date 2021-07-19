function playSound(freq, dur)
% function playSound(freq, dur)
%
% freq in Hz
% dur(ation) in sec

if nargin < 1 || isempty(freq)
    freq = 1000;
end

if nargin < 2 || isempty(dur)
    dur = 0.5;
end

sampFreq = 44100;           % sample frequency (Hz)
nn = sampFreq * dur;   % number of samples
tt = linspace(0, dur, nn);     % time samples
myBeep = sin(2*pi*freq*tt);
playTest = audioplayer(myBeep, sampFreq);
play(playTest);


