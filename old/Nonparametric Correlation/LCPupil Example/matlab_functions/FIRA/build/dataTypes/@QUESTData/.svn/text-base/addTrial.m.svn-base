function addTrial(q, data)
% function addTrial(q, data)
%
% addTrial method for class QUESTData
%
% Input:
%   q    ...  the QUESTData object
%   data  ... cell array of QUEST data
%
% Output:
%   nada, but fills FIRA.QUESTData(trial) with given data

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.QUESTData, 1) < FIRA.header.numTrials
    FIRA.QUESTData(end+1:FIRA.header.numTrials, 1) = {[]};
end

% data is cell array, just save it
FIRA.QUESTData{end, 1} = data;