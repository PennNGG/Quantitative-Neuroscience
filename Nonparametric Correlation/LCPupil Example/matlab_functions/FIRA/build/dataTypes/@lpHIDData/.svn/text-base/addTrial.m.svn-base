function addTrial(lp, data)
% function addTrial(lp, data)
%
% addTrial method for class lpHIDData
%
% Input:
%   lp    ... the lpHIDData object
%   data  ... cell array of data from lpHID
%
% Output:
%   squat and a half, but fills FIRA.lpHIDData(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.lpHIDData, 1) < FIRA.header.numTrials
    FIRA.lpHIDData(end+1:FIRA.header.numTrials) = {[]};
end

% data is cell array, just save it
FIRA.lpHIDData{end} = data;
