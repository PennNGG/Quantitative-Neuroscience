function cleanup(m)
% function cleanup(m)
%
% Cleanup method for class matCmds
%
% Input:
%   m ... the matCmds object
%
% Output: nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% cleanup FIRA.matCmds
if size(FIRA.matCmds, 1) > FIRA.raw.trial.good_count
    
    % remove empty (trailing) trials
    FIRA.matCmds(FIRA.raw.trial.good_count+1:end, :) = [];
end

% cleanup FIRA.raw.matCmds
% FIRA.raw.trial.wrt is a flag indicating we stopped parsing mid-trial
if isempty(FIRA.raw.trial.wrt)
    
    if ~isempty(FIRA.raw.matCmds.cmds)
        Lremain = FIRA.raw.matCmds.cmds(:,1)>=FIRA.raw.trial.start_time;
        FIRA.raw.matCmds.cmds = FIRA.raw.matCmds.cmds(Lremain, :);
        FIRA.raw.matCmds.args = FIRA.raw.matCmds.args(Lremain, :);
    end
    FIRA.raw.matCmds.ind  = 1;
else
    FIRA.raw.matCmds.cmds = [];
    FIRA.raw.matCmds.args = [];
    FIRA.raw.matCmds.ind  = 1;    
end
