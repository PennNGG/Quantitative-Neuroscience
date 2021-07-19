function addTrial(dio, data)
% function addTrial(dio, data)
%
% addTrial method for class dio (Digital I/O)
%
% Input:
%   dio   ... the dio object
%   data  ... cell array of dio data
%
% Output:
%   nada, but fills FIRA.dio(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.dio, 1) < FIRA.header.numTrials
    FIRA.dio(end+1:FIRA.header.numTrials) = {[]};
end

% save data
FIRA.dio{trial} = data;
