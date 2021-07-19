function cleanup(e)
% function cleanup(e)
%
% Cleanup method for class ecodes.
%
% Input:
%   e ... the ecodes object
%
% Output: nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% cleanup FIRA.ecodes
if size(FIRA.ecodes.data, 1) > FIRA.raw.trial.good_count
    
    % remove empty (trailing) trials
    FIRA.ecodes.data(FIRA.raw.trial.good_count+1:end, :) = [];    
end

% cleanup FIRA.raw.ecodes
% FIRA.raw.trial.wrt is a flag indicating we stopped parsing mid-trial
if isempty(FIRA.raw.trial.wrt)
    FIRA.raw.ecodes = FIRA.raw.trial.ecodes;
else
    FIRA.raw.ecodes = [];
end

% cleanup numTrials in header
FIRA.header.numTrials = size(FIRA.ecodes.data, 1);