function continue_ = parse(a)
% function continue_ = parse(a)
%
% Parse method for class analog. Actually
%   does nothing but call the analog parsing
%   function stored in FIRA.raw.analog.func
%
% Input:
%   a ... the analog object
%
% Output:
%   return flag
%   also reads FIRA.raw.trial and FIRA.raw.analog
%   and fills FIRA.analog

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% return flag
continue_ = true;

% call the parsing routine
if ~isempty(FIRA.raw.analog.func)
    feval(FIRA.raw.analog.func);
end

% useful variables
trial = FIRA.raw.trial.good_count;
if ~isempty(FIRA.analog.data) && trial> size(FIRA.analog.data,1)
    FIRA.raw.trial.good_count =  FIRA.raw.trial.good_count -1;
    trial = FIRA.raw.trial.good_count;
end
ch = find([FIRA.analog.data(trial,:).length] ~= 0);
if isempty(ch)
    return
end

% possibly resample
if ~isempty(a.resample)
    for aa = ch
        if FIRA.analog.store_rate(aa) ~= FIRA.analog.acquire_rate(aa)
            FIRA.analog.data(trial, aa).values = ...
                resample(FIRA.analog.data(trial, aa).values, ...
                FIRA.analog.store_rate(aa), FIRA.analog.acquire_rate(aa));
            FIRA.analog.data(trial, aa).length = ...
                length(FIRA.analog.data(trial, aa).values);
        end
    end
end

% possibly rezero
if isfield(FIRA.raw.analog.params, 'rezero_array') && ...
      ~isempty(FIRA.raw.analog.params.rezero_array)
    for aa = 1:size(FIRA.raw.analog.params.rezero_array, 2)
        vals = FIRA.raw.analog.params.rezero_array(:,aa);

        % check that we have appropriate analog data
        if FIRA.analog.data(trial, vals(1)).length > 0

            % get the sample number in the analog data array corresponding
            % to the time of fp offset
            offset_sample = ceil((FIRA.ecodes.data(trial, vals(2)) - ...
                FIRA.analog.data(trial, 1).start_time) * ...
                FIRA.analog.store_rate(vals(1))/1000);

            % check for enough data
            if isfinite(offset_sample) && ...
                    FIRA.analog.data(trial, vals(1)).length >= offset_sample

                % rezero
                FIRA.analog.data(trial, vals(1)).values = ...
                    FIRA.analog.data(trial, vals(1)).values - ...
                    mean(FIRA.analog.data(trial, vals(1)).values(offset_sample-a.rezero_samples:offset_sample)) + ...
                    FIRA.ecodes.data(trial, vals(3));
            end
        end
    end
end

