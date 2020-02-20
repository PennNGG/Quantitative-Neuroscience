function continue_ = parse(d)
% function continue_ = parse(d)
%
% Parse method for class dio (Digital I/O).
% Reads FIRA.raw.dio and FIRA.raw.trial
% and fills FIRA.dio
%
% Input:
%   d ... the dio object
%
% Output:
%   continue_ ... false when no more FIRA.raw.startcds

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% return flag
continue_ = true;

% get the commands (<timestamp> <port> <data>)
Ld = FIRA.raw.dio(:,1)>=FIRA.raw.trial.start_time & ...
    FIRA.raw.dio(:,1)<=FIRA.raw.trial.next_time;

FIRA.dio{FIRA.raw.trial.good_count, 1} = [ ...
    FIRA.raw.dio(Ld, 1) - FIRA.raw.trial.wrt, ...
    FIRA.raw.dio(Ld, 2:3)];