function [sacs_] = findSaccadesA(Xin, Yin, store_rate, num_sacs, show_fig)
% function [sacs_] = findSaccadesA(Xin, Yin, store_rate, num_sacs, show_fig)
%
% Finds the first "num_sacs" saccades in the given X, Y eye movement
%   traces. "A" for acceleration (the other findSaccades uses only
%   velocity information).
%
% Arguments:
%  Xin         ... raw analog horizontal data
%  Yin         ... raw analog vertical data
%  store_rate  ... samples/sec
%  num_sacs    ... number of saccades to check for
%  show_fig     ... optional argument to print debugging figure
%
% Returns an nx8 vectors, rows are saccades found, columns are:
%  1 .. latency
%  2 .. duration (ms)
%  3 .. maximum speed
%  4 .. average speed
%  5 .. end point x
%  6 .. end point y
%  7 .. distance raw  (the actual length of the saccade, calculated sample-by-sample)
%  8 .. distance vect (the length of the saccade calculated as the linear vector)

% default return
sacs_ = [];

% USER-DEFINED PARAMETERS
D_MIN  = 0.2;   % 0.75 minimum distance of a sacccade (deg)
VP_MIN = 0.08;  % 0.12 minimum peak velocity of a saccade (deg/ms)
VI_MIN = 0.04;  % minimum instantaneous velocity of a saccade (deg/ms)
A_MIN  = 0.005; % minimum instantaneous acceleration of a saccade

% for smoothing
smf   = [0.0033 0.0238 0.0971 0.2259 0.2998 0.2259 0.0971 0.0238 0.0033];
hsmf  = (size(smf,2)-1)/2;
t_int = 1000/store_rate;       % sample interval, in ms

% make sure there's data to be parsed
if (length(Xin) ~= length(Yin)) || length(Xin) < length(smf)
    return
end

% smooth the curves
Xin = conv(Xin, smf);
Xin = Xin(hsmf+1:end-hsmf-2);
Yin = conv(Yin, smf);
Yin = Yin(hsmf+1:end-hsmf-2);

% get velocity, sub out median
vel  = [0; sqrt(diff(Xin).^2 + diff(Yin).^2)/t_int];
vels = vel - median(vel);
% acc  = [0; diff(vels)];
acc  = conv([.2 .2 .2 .2 .2], [0; diff(vels)]);
acc  = acc(1:end-4);

% find all instantaneous velocities >= min peak
vps = find(vels >= VP_MIN);

% so we don't have to keep checking the same samples
last_end = 1;

while size(sacs_, 1) < num_sacs

    % find first string of 5 consecutive velocities bigger than peak 
    while length(vps) > 4 && vps(5)-vps(1) ~= 4
        vps = vps(2:end);
    end
    
    if length(vps) < 5
        break
    end

    % sac begins at earliest of acc > A_MIN & 
    %   vel > VI_MIN -OR- acc < -A_MIN & vel < VP_MIN
    sac_begin = last_end + min(...
        find(acc(last_end:vps(1)) < A_MIN, 1, 'last'), ...
        find(vels(last_end:vps(1)) <= VI_MIN | ...
        (acc(last_end:vps(1)) < -A_MIN & vels(last_end:vps(1)) < VP_MIN), ...
        1, 'last'));

    %    find(acc(last_end:vps(1))<A_MIN & ...
    %        vels(last_end:vps(1)) <= VI_MIN, 1, 'last');

    % sac ends at first acc > -A_MIN after deceration. the -5 accounts
    % for the acc smoothing.
    decel = vps(5) + find(acc(vps(5)+1:end) < -A_MIN, 1);

    % check if any found
    if isempty(sac_begin) || isempty(decel)

        % new start point
        last_end = vps(5);
        vps      = vps(5:end);
        
    else
        
        sac_end = decel-5 + max(...
            find(acc(decel+1:end-1) > -A_MIN, 1), ...
            find(vels(decel:end-2) <= VI_MIN | ...
            (acc(decel+2:end) > A_MIN & vels(decel:end-2) < VP_MIN), 1));

        %    sac_end = decel + find(acc(decel+1:end-1) > -A_MIN & ...
        %        (vels(decel:end-2) <= V_MIN | ...
        %        acc(decel+1:end-1) > A_MIN & acc(decel+2:end) > A_MIN), 1) - 5;

        % check if any found
        if isempty(sac_end)
            
                % new start point
                last_end = vps(5);
                vps      = vps(5:end);
        else

            % new start point
            vps      = vps(vps > sac_end);
            last_end = sac_end + 1;

            % vector distance
            len = sqrt((Xin(sac_end)-Xin(sac_begin-1)).^2 + ...
                (Yin(sac_end)-Yin(sac_begin-1)).^2);

            if len >= D_MIN

                % return stuff
                sacs_(end+1, :) = [ ...
                    sac_begin * t_int,                  ...  % latency
                    (sac_end - sac_begin) * t_int,      ...  % duration
                    max(vel(sac_begin:sac_end)),        ...  % vmax
                    mean(vel(sac_begin:sac_end)),       ...  % vavg
                    Xin(sac_end),                       ...  % end x
                    Yin(sac_end),                       ...  % end y
                    sum(vel(sac_begin:sac_end)*t_int),  ...  % raw distance
                    len];                               ...  % vector distance
            end
        end
    end
end

% add final sac if eye position of final sac is different
% than position at 300 ms
if size(sacs_, 1) < num_sacs && ...
        (isempty(sacs_) || sacs_(end,1)+sacs_(end,2) < 500)
    sacs_(end+1, :) = [inf nan nan nan ...
        Xin(end) Yin(end) nan nan];
end

% useful debug plot
if nargin >= 5 && show_fig

    co = {'r' 'g' 'b' 'k' 'y' 'c' 'm'};

    % top plot is x vs y
    topp = subplot(2,1,1);
    hold off
    plot(Xin, Yin, 'k-');  % raw eye position
    hold on;

    % plot each sac
    for i = 1:size(sacs_, 1)
        plot(sacs_(i, 5), sacs_(i, 6), 'x', 'MarkerFaceColor', co{i});
    end

    % plot zero lines
    plot([0 0], [-15 15], 'k--');
    plot([-15 15], [0 0], 'k--');
    axis([-12 12 -12 12]);

    tax = (0:t_int:length(Xin)*t_int-t_int)';

    % bottom plot is vs. time
    botp = subplot(2,1,2);
    hold off;
    plot(tax, vels*10,  'm-');  % velocity (deg/s) vs time
    hold on;
    plot(tax, acc*100, 'g-');   % acc (deg/s/s) vs time
    plot(tax, Xin, 'b-');       % x vs time
    plot(tax, Yin, 'r-');       % y vs time
    plot([0 max(tax)], [VI_MIN VI_MIN]*10, 'k:');
    plot([0 max(tax)], [VP_MIN VP_MIN]*10, 'k:');

    % plot each sac
    for i = 1:size(sacs_, 1)
        plot([sacs_(i, 1) sacs_(i, 1)], [-50 50], 'k--');
        plot([sacs_(i, 1)+sacs_(i, 2) sacs_(i, 1)+sacs_(i, 2)], [-50 50], 'k--');
    end
    
    axes(topp);
end
%     sacs_
%     
%     % wait for input
%     a = input('what next?', 's');
%     if a == 'q'
%         error('done')
%     end
% end
