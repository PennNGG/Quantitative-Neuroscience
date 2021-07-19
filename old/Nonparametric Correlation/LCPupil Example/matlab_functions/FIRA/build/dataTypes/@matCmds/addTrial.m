function addTrial(mt, trial, data)
% function addTrial(mt, trial, data)
%
% addTrial method for class matCmds
%
% Input:
%   mt    ... the matCmds object
%   data  ... matrix of matCmds
%
% Output:
%   nada, but fills FIRA.matCmds(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.matCmds, 1) < FIRA.header.numTrials
    FIRA.matCmds(end+1:FIRA.header.numTrials) = {[]};
end

% data is cell array, just save it
FIRA.matCmds{end} = data;
