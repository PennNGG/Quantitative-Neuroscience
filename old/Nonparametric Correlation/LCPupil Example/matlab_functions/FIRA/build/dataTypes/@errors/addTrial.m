function addTrial(e, data)
% function addTrial(e, data)
%
% addTrial method for class errors
%
% Input:
%   e       ... the errors object
%   data    ... cell array of error info
%
% Output:
%   squat and a half, but fills FIRA.errors(trial) with given data

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.errors, 1) < FIRA.header.numTrials
    FIRA.errors(end+1:FIRA.header.numTrials,1) = {[]};
end

% data is cell array, just save it
FIRA.errors{end,1} = data;