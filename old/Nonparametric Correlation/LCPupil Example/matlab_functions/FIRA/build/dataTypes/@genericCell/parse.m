function parse(gc)
% function parse(gc)
% 
% Parse method for class genericCell
% Reads FIRA.raw.genericCell and FIRA.raw.trial
% and fills FIRA.genericCell
%
% Input:
%   gc ... the genericCell object
%

% Copyright 2010 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% get the commands (<timestamp> <port> <data>)
Ld = FIRA.raw.dio(:,1)>=FIRA.raw.trial.start_time & ...
    FIRA.raw.dio(:,1)<=FIRA.raw.trial.next_time;

FIRA.genericCell{FIRA.raw.trial.good_count, 1} = [ ...
    FIRA.raw.dio(Ld, 1) - FIRA.raw.trial.wrt, ...
    FIRA.raw.dio(Ld, 2:3)];