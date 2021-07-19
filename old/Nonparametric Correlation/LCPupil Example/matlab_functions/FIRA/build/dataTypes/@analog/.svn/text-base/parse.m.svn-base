function parse(a)
% function parse(a)
%
% Parse method for class analog. Actually
%   does nothing but call the analog parsing
%   function stored in FIRA.raw.analog.func
%
% Input:
%   a ... the analog object
%
% Output:
%   nada, but reads FIRA.raw.trial and FIRA.raw.analog
%   and fills FIRA.analog

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% call the parsing routine
if ~isempty(FIRA.raw.analog.func)
    feval(FIRA.raw.analog.func);
end

% disp(sprintf('analog parse: start=%.2f, end=%.4f', ...
%     FIRA.analog.data(FIRA.raw.trial.good_count).start_time, ...
%     FIRA.analog.data(FIRA.raw.trial.good_count).start_time + ...
%     FIRA.analog.data(FIRA.raw.trial.good_count).length./FIRA.analog.store_rate(1)*1000))

% possibly resample
for aa = 1:length(FIRA.analog.store_rate)
    if FIRA.analog.store_rate(aa) ~= FIRA.analog.acquire_rate(aa)
        FIRA.analog.data(FIRA.raw.trial.good_count, aa).values = ...
            resample(FIRA.analog.data(FIRA.raw.trial.good_count, aa).values, ...
            FIRA.analog.store_rate(aa), FIRA.analog.acquire_rate(aa));
        FIRA.analog.data(FIRA.raw.trial.good_count, aa).length = ...
            length(FIRA.analog.data(FIRA.raw.trial.good_count, aa).values);
    end
end
