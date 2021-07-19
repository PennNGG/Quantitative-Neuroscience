function parse(e)
% function parse(e)
%
% Parse method for class ecodes.
% Reads FIRA.raw.ecodes and FIRA.raw.trial
% and fills FIRA.ecodes
%
% Input:
%   e ... the ecodes object
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% current trial index
cti = FIRA.raw.trial.good_count;

% fill in default ecodes -- for now assuming they
% have NOT changed & are the predefined set of 4:
%   total trial count
%   trial start time
%   trial end time
%   trial wrt
FIRA.ecodes.data(cti, 1:4) = [ ...
    FIRA.raw.trial.total_count, ...
    FIRA.raw.trial.start_time - FIRA.raw.trial.wrt, ...
    FIRA.raw.trial.end_time   - FIRA.raw.trial.wrt, ...
    FIRA.raw.trial.wrt];

% get the "extracted" ecode values
if e.num_extract

    % loop through the "extracted" structs
    for i = 1:e.num_extract
        FIRA.ecodes.data(cti, 4+i) = ...
            feval(e.extract(i).func, FIRA.raw.trial.ecodes, e.extract(i).params{:});
    end

    % subtract wrt from the time codes
    FIRA.ecodes.data(cti, e.time_inds) = ...
        FIRA.ecodes.data(cti, e.time_inds) - FIRA.raw.trial.wrt;
end

% get "tmp" ecodes
if e.num_tmp

    % loop through the "tmp" structs
    for i = 1:e.num_tmp
        FIRA.raw.trial.tmp_ecodes(i) = ...
            feval(e.tmp(i).func, FIRA.raw.trial.ecodes, e.tmp(i).params{:});
    end

    % subtract wrt from the time codes
    FIRA.raw.trial.tmp_ecodes(e.tmp_time_inds) = ...
        FIRA.raw.trial.tmp_ecodes(e.tmp_time_inds) - FIRA.raw.trial.wrt;
end
