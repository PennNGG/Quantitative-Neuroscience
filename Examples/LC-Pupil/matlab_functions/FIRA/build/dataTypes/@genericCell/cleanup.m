function cleanup(gc)
% function cleanup(gc)
%
% Cleanup method for class genericCell
%
% Input:
%   gc ... the genericCell object
%
% Output: nada

% Copyright 2010 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% cleanup FIRA.genericCell
if size(FIRA.genericCell, 1) > FIRA.raw.trial.good_count
    
    % remove empty (trailing) trials
    FIRA.genericCell(FIRA.raw.trial.good_count+1:end, :) = [];
end

% cleanup FIRA.raw.genericCell
% FIRA.raw.trial.wrt is a flag indicating we stopped parsing mid-trial
if isempty(FIRA.raw.genericCell)
    return
elseif isempty(FIRA.raw.trial.wrt)
    FIRA.raw.genericCell = FIRA.raw.genericCell(FIRA.raw.genericCell(:,1)>=FIRA.raw.trial.start_time, :);
else
    FIRA.raw.genericCell = [];
end
