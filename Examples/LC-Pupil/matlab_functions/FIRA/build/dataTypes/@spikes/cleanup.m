function cleanup(s)
% function cleanup(s)
%
% Cleanup method for class spikes.
%
% Input:
%   s ... the spikes object
%
% Output: nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if ~isfield(FIRA, 'raw')
    return
end

% cleanup FIRA.spikes
if isfield(FIRA.raw, 'trial') && size(FIRA.spikes.data, 1) > FIRA.raw.trial.good_count
    
    % remove empty (trailing) trials
    FIRA.spikes.data(FIRA.raw.trial.good_count+1:end, :) = [];
end

% cleanup FIRA.raw.spikes
% FIRA.raw.trial.wrt is a flag indicating we stopped parsing mid-trial
if ~isfield(FIRA.raw, 'spikes') || isempty(FIRA.raw.spikes)
    return
elseif isempty(FIRA.raw.trial.wrt)
    FIRA.raw.spikes = FIRA.raw.spikes(FIRA.raw.spikes(:,1)>=FIRA.raw.trial.start_time, :);
else
    FIRA.raw.spikes = [];
end
