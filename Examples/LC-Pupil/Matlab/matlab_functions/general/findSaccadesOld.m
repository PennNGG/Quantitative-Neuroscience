function sacs_ = findSaccadesOld(Xin, Yin, store_rate, num_sacs, show_fig)
% function sacs_ = findSaccadesOld(Xin, Yin, store_rate, num_sacs, show_fig)
%
% finds the first "num_sacs" saccades in the given X, Y eye movement traces
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
D_MIN  = 1;    % minimum distance of a sacccade (deg)
VP_MIN = 0.07; % minimum peak velocity of a saccade (deg/ms)
VI_MIN = 0.03; % minimum instantaneous velocity of a saccade

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
vels = sqrt(diff(Xin).^2 + diff(Yin).^2)/t_int;
vel  = vels - median(vels);

% find all instantaneous velocities >= min peak
vps = find(vel >= VP_MIN);

% so we don't have to keep checking the same samples
last_end = 1;

while size(sacs_, 1) < num_sacs

    % find first velocity bigger than peak .. must be followed
    % by at least 4 more in a row
    while length(vps) > 4 && vps(5)-vps(1) ~= 4
        vps = vps(2:end);
    end
    
    if length(vps) < 5
        break
    end

    % sac begins at start of positive velocity
    sac_begin = last_end + find(vel(last_end:vps(1))<=VI_MIN, 1, 'last');

    % check if any found
    if isempty(sac_begin)
        break
    end

    % sac ends at end of positive velocity
    sac_end = vps(5) + find(vel(vps(5)+1:end)<=VI_MIN, 1) - 1;

    % check if any found
    if isempty(sac_end)
        break
    end

    % new start point
    vps      = vps(vps > sac_end);
    last_end = sac_end;

    % vector distance
    len = sqrt((Xin(sac_end+1)-Xin(sac_begin)).^2 + ...
        (Yin(sac_end+1)-Yin(sac_begin)).^2);
    
    if len >= D_MIN

        % return stuff
        sacs_(end+1, :) = [ ...
            sac_begin * t_int,                  ...  % latency
            (sac_end - sac_begin) * t_int,      ...  % duration
            max(vel(sac_begin:sac_end)),        ...  % vmax
            mean(vel(sac_begin:sac_end)),       ...  % vavg
            Xin(sac_end),                       ...  % end x
            Yin(sac_end),                       ...  % end y
            sum(vels(sac_begin:sac_end)*t_int), ...  % raw distance
            len];                               ...  % vector distance
    end
end

% useful debug plot
if nargin >= 5 && show_fig

    co = {'r' 'g' 'b'};

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

    tax = [0:t_int:length(Xin)*t_int-t_int]';

    % bottom plot is vs. time
    botp = subplot(2,1,2);
    hold off;
    plot(tax, Xin, 'b-');              % x vs time
    hold on;
    plot(tax, Yin, 'r-');              % y vs time
    plot(tax(2:end), vel*10,  'c-'); % velocity (deg/s) vs time
    plot([0 max(tax)], [VI_MIN VI_MIN]*10, 'k:');

    % plot each sac
    for i = 1:size(sacs_, 1)
        plot([sacs_(i, 1) sacs_(i, 1)], [-8 8], 'k--');
        plot([sacs_(i, 1)+sacs_(i, 2) sacs_(i, 1)+sacs_(i, 2)], [-8 8], 'k--');
    end

    sacs_
    
    % wait for input
    a = input('what next?', 's');
    if a == 'q'
        error('done')
    end
end
