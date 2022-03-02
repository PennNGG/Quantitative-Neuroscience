function addTrial(gc, data)
% function addTrial(gc, data)
%
% addTrial method for class genericCell
%
% Input:
%   gc    ... the genericCell object
%   data  ... cell array of genericCell data
%
% Output:
%   nada, but fills FIRA.genericCell(trial) with given data

% Copyright 2010 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.genericCell, 1) < FIRA.header.numTrials
    FIRA.genericCell(end+1:FIRA.header.numTrials) = {[]};
end

% save data
FIRA.genericCell{trial} = data;
