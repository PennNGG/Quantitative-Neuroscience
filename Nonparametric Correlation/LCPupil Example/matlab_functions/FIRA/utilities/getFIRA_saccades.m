function [sacs_, bf_] = getFIRA_saccades(trial, num_saccades, recal, ...
    heye, veye, fpoff, fpx, fpy, max_time, hgain, vgain)
%function [sacs_, bf_] = getFIRA_saccades(trial, num_saccades, recal, ...
%    heye, veye, fpoff, fpx, fpy, max_time, hgain, vgain)
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

% 6/2/07 jig added gain
%
% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

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

if nargin < 10 || isempty(hgain)
    hgain = 1;
end

if nargin < 11 || isempty(vgain)
    vgain = 1;
end

sacs_ = [];

if isfield(FIRA, 'analog')

    % get indices of horizontal, vertical eye position data
    eyeX = strcmp(heye, FIRA.analog.name);
    eyeY = strcmp(veye, FIRA.analog.name);

    % check that we have appropriate analog data
    if any(eyeX) && ~isempty(FIRA.analog.data(trial, eyeX).values) && ...
            any(eyeY) && ~isempty(FIRA.analog.data(trial, eyeY).values)

        % check that store rate is the same for both channels
        if FIRA.analog.store_rate(eyeX) ~= FIRA.analog.store_rate(eyeY)
            disp('getFIRA_saccades: bad store rates')
        end
        
        % get the sample number in the analog data array corresponding
        % to the time of fp offset
        fpoff_samp = ceil((FIRA.ecodes.data(trial, strcmp(fpoff, FIRA.ecodes.name)) - ...
            FIRA.analog.data(trial, 1).start_time) * ...
            FIRA.analog.store_rate(eyeX)/1000);

        % check for enough data
        if isnan(fpoff_samp) || ...
                FIRA.analog.data(trial, eyeX).length <= fpoff_samp
           
            % return, with flag for broken fixation set
            bf_= true;
            return
        end            

        % possibly use gain to re-scale traces
        if hgain ~= 1
            FIRA.analog.data(trial, eyeX).values = hgain*...
                FIRA.analog.data(trial, eyeX).values;
        end
        if vgain ~= 1
            FIRA.analog.data(trial, eyeY).values = vgain*...
                FIRA.analog.data(trial, eyeY).values;
        end

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

            % look for at most max_time time (ms)
            end_ind = fpoff_samp + round(FIRA.analog.store_rate(1)/1000*max_time);
            if end_ind > FIRA.analog.data(trial, eyeX).length
                end_ind = FIRA.analog.data(trial, eyeX).length;
            end
            
            % call findSaccades to do the work
            sacs_ = findSaccadesA( ...
                FIRA.analog.data(trial, eyeX).values(fpoff_samp:end_ind), ...
                FIRA.analog.data(trial, eyeY).values(fpoff_samp:end_ind), ...
                FIRA.analog.store_rate(1), num_saccades, false);
        end        
    end
end

% no broken fixation
bf_ = false;

