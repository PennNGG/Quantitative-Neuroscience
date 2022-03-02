function addTrial(g, data)
% function addTrial(g, data)
%
% addTrial method for class gameHIDData
%
% Input:
%   g    ... the gameHIDData object
%   data  ... cell array of data from gamepad
%
% Output:
%   squat and a half, but fills FIRA.gameHIDData(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.gameHIDData, 1) < FIRA.header.numTrials
    FIRA.gameHIDData(end+1:FIRA.header.numTrials,1) = {[]};
end

% data is cell array, just save it
FIRA.gameHIDData{end,1} = data;
