function addTrial(kb, data)
% function addTrial(kb, data)
%
% addTrial method for class kbdData
%
% Input:
%   kb    ... the kbdData object
%   data  ... cell array of kbd data
%
% Output:
%   nada, but fills FIRA.kbdData(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.kbdData, 1) < FIRA.header.numTrials
    FIRA.kbdData(end+1:FIRA.header.numTrials,1) = {[]};
end

% data is cell array, just save it
FIRA.kbdData{end,1} = data;
