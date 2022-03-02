function addTrial(as, data)
% function addTrial(as, data)
%
% addTrial method for class aslData
%
% Input:
%   as    ... the aslData object
%   data  ... cell array of eye data
%             nx4 with rows [pupil_diam, horz, vert, frame_num]
%
% Output:
%   nada, but fills FIRA.aslData(trial) with given data

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.aslData, 1) < FIRA.header.numTrials
    FIRA.aslData(end+1:FIRA.header.numTrials,1) = {[]};
end

% data is cell array, just save it
FIRA.aslData{end,1} = data;