function cleanup(a)
% function cleanup(a)
%
% Cleanup method for class analog.
%
% Input:
%   a ... the analog object
%
% Output: nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% trim empty trial fields in FIRA.analog.data
if size(FIRA.analog.data, 1) > FIRA.raw.trial.good_count
    FIRA.analog.data(FIRA.raw.trial.good_count+1:end, :) = [];
end

% get rid of extra data in FIRA.raw.analog.data
% BUT ONLY IF THIS IS A NEX FILE
if strcmp(FIRA.header.filetype, 'nex') && ...
    FIRA.raw.trial.start_time && ~isempty(FIRA.raw.analog.data)
    Ls = FIRA.raw.analog.data(:,1) >= FIRA.raw.trial.start_time;
    if sum(Ls) < sum(~Ls)
        FIRA.raw.analog.data = FIRA.raw.analog.data(Ls, :);
    else
        FIRA.raw.analog.data(~Ls, :) = [];
    end
end
