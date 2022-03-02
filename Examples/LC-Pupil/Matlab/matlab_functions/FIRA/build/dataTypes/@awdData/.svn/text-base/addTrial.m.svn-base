function addTrial(aw, data)
% function addTrial(aw, data)
%
% addTrial method for class awdData (Active Wire Device data)
%
% Input:
%   aw    ... the awdData object
%   data  ... matrix of awdData:
%               <pin> <value> <time>
%
% Output:
%   nada, but fills FIRA.awdData(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.awdData, 1) < FIRA.header.numTrials
    FIRA.awdData(end+1:FIRA.header.numTrials) = {[]};
end

% data is double matrix, just save it at the end
FIRA.awdData{end} = data;
