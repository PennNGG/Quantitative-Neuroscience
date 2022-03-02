function cleanup(d)
% function cleanup(d)
%
% Cleanup method for class dio (Digital I/O).
%
% Input:
%   d ... the dio object
%
% Output: nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% cleanup FIRA.dio
if size(FIRA.dio, 1) > FIRA.raw.trial.good_count
    
    % remove empty (trailing) trials
    FIRA.dio(FIRA.raw.trial.good_count+1:end, :) = [];
end

% cleanup FIRA.raw.dio
% FIRA.raw.trial.wrt is a flag indicating we stopped parsing mid-trial
if isempty(FIRA.raw.dio)
    return
elseif isempty(FIRA.raw.trial.wrt)
    FIRA.raw.dio = FIRA.raw.dio(FIRA.raw.dio(:,1)>=FIRA.raw.trial.start_time, :);
else
    FIRA.raw.dio = [];
end
