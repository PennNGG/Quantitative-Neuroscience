function continue_ = parse(e)
% function continue_ = parse(e)
%
% Parse method for class ecodes.
% Reads FIRA.raw.ecodes and FIRA.raw.trial
% and fills FIRA.ecodes
%
% Input:
%   e ... the ecodes object
%
% Output:
%   return flag
%

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania
%
% Modified by Long Ding 3/28/2016 to accomodate multiple instances of one
% ecode. 
% Modified by Long Ding 3/21/2017 to add trial# in data.ecodes.multi

global FIRA

% return flag
continue_ = true;

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
FIRA.ecodes.multi{cti, 1} = FIRA.raw.trial.total_count;

% get the "extracted" ecode values
if e.num_extract

    % loop through the "extracted" structs
    ind_multi = [];
    for i = 1:e.num_extract
        temp = feval(e.extract(i).func, FIRA.raw.trial.ecodes, e.extract(i).params{:});
        if length(temp)<=1
            FIRA.ecodes.data(cti, 4+i) = temp;
        else
            FIRA.ecodes.multi{cti, 4+i} = temp; 
            ind_multi = [ind_multi, 4+i];
        end
    end

    % subtract wrt from the time codes
    FIRA.ecodes.data(cti, e.time_inds) = ...
        FIRA.ecodes.data(cti, e.time_inds) - FIRA.raw.trial.wrt;
    if ~isempty(ind_multi)
        time_inds_multi = intersect(ind_multi, e.time_inds);
        if ~isempty(time_inds_multi)
            FIRA.ecodes.multi{cti, time_inds_multi} = ...
                FIRA.ecodes.multi{cti, time_inds_multi} - FIRA.raw.trial.wrt;
        end
    end
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
