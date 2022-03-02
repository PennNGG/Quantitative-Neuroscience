function err_ = playSound(freq, dur, reps, isi)
% function playSound(freq, dur, reps, isi)
%
% freq in Hz
% dur(ation) in sec
% reps is # of (identical) repetitions
% isi is time between reps

if nargout == 1
    err_ = 0;
end

if nargin < 1 || isempty(freq)
    freq = 1000;
end

if nargin < 2 || isempty(dur)
    dur = 0.5;
end

if nargin < 3 || isempty(reps)
    reps = 1;
end

if nargin < 4 || isempty(isi)
    isi = 0.15;
end


sampFreq = 44100;           % sample frequency (Hz)

beepFreq = 440;             % signal frequency (Hz)
beepDura = 1.0;             % duration (sec)

nn = sampFreq * beepDura;   % number of samples
tt = linspace(0, beepDura, nn);     % time samples
myBeep = sin(2*pi*beepFreq*tt);
playTest = audioplayer(myBeep, sampFreq);
play(playTest);


ts = 0:0.0001:dur;
for i = 1:reps
    sound(sin(2*pi*freq.*ts), 10000);
    pause(isi);
end