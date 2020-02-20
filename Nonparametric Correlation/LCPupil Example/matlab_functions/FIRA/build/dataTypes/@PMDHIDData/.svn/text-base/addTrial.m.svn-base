function addTrial(p, data)
% function addTrial(p, data)
%
% addTrial method for class PMDHIDData
%
% Input:
%   p    ... the PMDHIDData object
%   data  ... cell array of data from dXPMDHID
%
% Output:
%   squat and a half, but fills FIRA.PMDHIDData(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.PMDHIDData, 1) < FIRA.header.numTrials
    FIRA.PMDHIDData(end+1:FIRA.header.numTrials,1) = {[]};
end

% data is cell array, just save it
FIRA.PMDHIDData{end,1} = data;
