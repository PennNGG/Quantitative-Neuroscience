function purge(p)
% function purge(p)
%
% Purge method for class PMDHIDData. 
%   Purges PMDHIDData data from FIRA
%
% Input:
%   p ... the PMDHIDData object
%
% Output:
%   squat

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge data from FIRA.PMDHIDData
FIRA.PMDHIDData = {};