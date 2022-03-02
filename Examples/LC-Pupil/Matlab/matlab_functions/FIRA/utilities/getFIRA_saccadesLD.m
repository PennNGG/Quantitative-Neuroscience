function [sacs_, bf_] = getFIRA_saccadesLD(trial, num_saccades, recal, ...
    heye, veye, fpoff, fpx, fpy, max_time)
%function [sacs_, bf_] = getFIRA_saccades(trial, num_saccades, recal, ...
%    heye, veye, fpoff, fpx, fpy, max_time)
%
% Convenience function to do standard stuff within an spm file --
%   recalibrate eye position to fixation, and return saccade
%   parameters
%
% Arguments:
%   trial        ... trial number
%   num_saccades ... argument to findSaccades
%   recal        ... flag, whether to recalibrate
%
% Returns:
%   sacs_ ... list of saccade parameters computed by parseSaccades
%               ([] if no saccade found)
%   bf_   ... flag for (true if) broken fixation 
%               (eye record stops before fpoff)

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA
global eyes 

if nargin < 2
    num_saccades = 1;
end

if nargin < 3
    recal = true;
end

if nargin < 4 || isempty(heye)
    heye = 'horiz_eye';
end

if nargin < 5 || isempty(veye)
    veye = 'vert_eye';
end

if nargin < 6 || isempty(fpoff)
    fpoff = 'fp_off';
end

if nargin < 7 || isempty(fpx)
    fpx = 'fp_x';
end

if nargin < 8 || isempty(fpy)
    fpy = 'fp_y';
end

if nargin < 9 || isempty(max_time)
    max_time = 1000; % ms
end

sacs_ = [];

if isfield(FIRA, 'analog')

    % get indices of horizontal, vertical eye position data
    eyeX = strcmp(heye, FIRA.analog.name);
    eyeY = strcmp(veye, FIRA.analog.name);

    % check that we have appropriate analog data
    if any(eyeX) && ~isempty(FIRA.analog.data(trial, eyeX).values) && ...
            any(eyeY) && ~isempty(FIRA.analog.data(trial, eyeY).values)

        % get the sample number in the analog data array corresponding
        % to the time of fp offset
        fpoff_samp = ceil((FIRA.ecodes.data(trial, strcmp(fpoff, FIRA.ecodes.name)) - ...
            FIRA.analog.data(trial, 1).start_time) * ...
            FIRA.analog.store_rate(1)/1000);

        % check for enough data
        if isnan(fpoff_samp) || ...
                FIRA.analog.data(trial, eyeX).length <= fpoff_samp || fpoff_samp<10
           
            % return, with flag for broken fixation set
            bf_= true;
            return
        end

        eyes(end+1,[1 2]) = ...
            [mean(FIRA.analog.data(trial, eyeX).values(fpoff_samp-10:fpoff_samp)), ...
            mean(FIRA.analog.data(trial, eyeY).values(fpoff_samp-10:fpoff_samp))];
            

        if recal

            % re-calibrate eye position to last 10 samples of fixation
            FIRA.analog.data(trial, eyeX).values = ...
                FIRA.analog.data(trial, eyeX).values - ...
                mean(FIRA.analog.data(trial, eyeX).values(fpoff_samp-10:fpoff_samp)) + ...
                FIRA.ecodes.data(trial, strcmp(fpx, FIRA.ecodes.name));

            FIRA.analog.data(trial, eyeY).values = ...
                FIRA.analog.data(trial,eyeY).values - ...
                mean(FIRA.analog.data(trial,eyeY).values(fpoff_samp-10:fpoff_samp)) + ...
                FIRA.ecodes.data(trial, strcmp(fpy, FIRA.ecodes.name));
        end

        % get saccade parameters
        if num_saccades > 0

            % look for at most one second
            end_ind = fpoff_samp + round(FIRA.analog.store_rate(1)/1000*max_time);
            if end_ind > FIRA.analog.data(trial, eyeX).length
                end_ind = FIRA.analog.data(trial, eyeX).length;
            end
            if end_ind-fpoff_samp>150
                % call findSaccades to do the work
                %             sacs_ = findSaccadesA( ...
                %                 FIRA.analog.data(trial, eyeX).values(fpoff_samp:end_ind), ...
                %                 FIRA.analog.data(trial, eyeY).values(fpoff_samp:end_ind), ...
                %                 FIRA.analog.store_rate(1), num_saccades, false);
                % use sac_detectLD instead
                %                sacs_ = sac_detectLD( ...
                % jig changed to findSaccadesYL
                sacs_ = findSaccadesA( ...                
                    FIRA.analog.data(trial, eyeX).values(fpoff_samp:end_ind), ...
                    FIRA.analog.data(trial, eyeY).values(fpoff_samp:end_ind), ...
                    FIRA.analog.store_rate(1), num_saccades);
            end
        end
    end
end

% no broken fixation
bf_ = false;

