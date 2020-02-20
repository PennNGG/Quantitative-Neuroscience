function showFIRA_saccades(trial, fig)
% function showFIRA_saccades(trial, fig)

global FIRA

% make figure current
figure(fig)
co = {'r' 'g' 'b' 'k'};

%% get data
% eye traces
Xrec = FIRA.analog.data(trial, strcmp(FIRA.analog.name, 'horiz_eye'));
Yrec = FIRA.analog.data(trial, strcmp(FIRA.analog.name, 'vert_eye'));
Ts   = Xrec.start_time+(1./FIRA.analog.store_rate(1))*1000*(0:Xrec.length-1)';Xs = Xrec.values;
Ys   = Yrec.values;

% top plot is x vs y
topp = subplot(2,1,1);
hold off
plot(Xs, Ys, 'k-');  % raw eye position
hold on;

% plot targets, sacs
xys = getFIRA_ec(trial, {'t1_x', 't1_y', 't2_x', 't2_y', ...
    'stim_endrx', 'stim_endry', 'vol_endrx', 'vol_endry'});
co = {'ro' 'bo' 'gx' 'kx'};
for ii = 1:2:length(xys)
    if ~isnan(xys(ii))
        plot(xys(ii), xys(ii+1), co{(ii+1)/2}, 'MarkerSize', 20);
    end
end

% plot zero lines
xmax = 18;
plot([0 0], [-xmax xmax], 'k--');
plot([-xmax xmax], [0 0], 'k--');
axis([-xmax xmax -xmax xmax]);

% bottom plot is vs. time
botp = subplot(2,1,2);
hold off;
plot(Ts, Xs, 'b-');       % x vs time
hold on;
plot(Ts, Ys, 'r-');       % y vs time

% plot stim, vol sac
times = getFIRA_ec(trial, {'fp_off', 'vol_lat', 'vol_dur', 'stim_lat', 'stim_dur'});
if ~isnan(times(1)) && ~isnan(times(2)) && ~isnan(times(3))

    % fpoff
    plot([times(1) times(1)], [-xmax xmax], 'r-');

    % vol sac begin, end
    plot(sum(times(1:2))*[1 1], [-xmax xmax], 'k-');
    plot(sum(times(1:3))*[1 1], [-xmax xmax], 'k--');

    % stim sac
    if ~isnan(times(4)) && ~isnan(times(5))
        plot(sum(times([1 4]))*[1 1], [-xmax xmax], 'g-');
        plot(sum(times([1 4 5]))*[1 1], [-xmax xmax], 'g--');
    end

    % plot zero line
    plot([min(Ts) max(Ts)], [0 0], 'k--');

    % set axis
    axis([times(1)-100 times(1)+times(2)+100 -xmax xmax]);
end
