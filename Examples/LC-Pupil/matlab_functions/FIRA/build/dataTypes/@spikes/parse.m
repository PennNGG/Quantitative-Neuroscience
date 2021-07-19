function continue_ = parse(s)
% function continue_ = parse(s)
%
% Parse method for class spikes. Reads
%   FIRA.raw.spikes and FIRA.raw.trial
%   and fills FIRA.spikes
%
% Input:
%   s ... the spikes object
%
% Output:
%   continue_ ... flag that for now always returns true

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% return flag
continue_ = true;

% get the indices of spikes from this trial
if isempty(FIRA.raw.spikes)
    return
end

rs = FIRA.raw.spikes( ...
    FIRA.raw.spikes(:,1) >= FIRA.raw.trial.start_time & ...
    FIRA.raw.spikes(:,1) <= FIRA.raw.trial.end_time, :);

if isempty(rs)
    return
end

% save them individually (as wrt times) per spike id
for i = 1:size(FIRA.spikes.id, 2)
    FIRA.spikes.data{FIRA.raw.trial.good_count, i} = ...
        rs(rs(:,2)==FIRA.spikes.id(i), 1) - FIRA.raw.trial.wrt;
end
