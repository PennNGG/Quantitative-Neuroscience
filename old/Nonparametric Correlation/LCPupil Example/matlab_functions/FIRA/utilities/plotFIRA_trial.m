function plotFIRA_trial(aData, aStart, aSR, epoch, times, sac_times, ...
    locs, sac_locs, fig)
%function plotFIRA_trial(aData, aStart, aSR, epoch, times, sac_times, ...
%    locs, sac_locs, fig)
%
% Utility for viewing the parameters
%   associated with the current trial.
%   A debugging tool for spm files.
%
% Arguments:
%   aData     ... X, Y analog data (nx2 array)
%   aStart    ... start time of analog data (wrt)
%   aSR       ... sample rate of analog data
%   epoch     ... start, wrt, end times to use
%   times     ... list of times to show events in X,Y vs T plots
%   sac_times ...
%   locs      ...
%   sac_locs  ...
%   ax        ...

% Created 9/7/05 by jig

global FIRA

if nargin < 3 || isempty(aData)
    return
end

t_int = 1000/aSR; % time interval in ms per sample

if nargin < 4 || length(epoch) < 3
    epoch = [1 1 size(aData, 1)*t_int];
elseif isnan(epoch(2)) || isnan(epoch(3))
    subplot(2,1,1); cla
    subplot(2,1,2); cla
    return
elseif isnan(epoch(1))
    epoch(1) = epoch(2) - 100;
end

if nargin < 9 || isempty(fig)
    fig = gcf;
end

% time axis
time_ax   = [epoch(1):t_int:epoch(3)]' - epoch(2);

% get start, end indices of analog data
start_ind = ceil(epoch(1) - aStart)*t_int;
end_ind   = start_ind + size(time_ax, 1) - 1;

if start_ind < 1
    start_ind = 1;
end

if end_ind > size(aData, 1)
    end_ind = size(aData, 1);
end

% top plot is X, Y vs T
subplot(2, 1, 1);
hold off;
plot(time_ax, aData(start_ind:end_ind, 1), 'b-');
hold on;
plot(time_ax, aData(start_ind:end_ind, 2), 'r-');

% plot time points
% these need to be updated to epoch wrt
cols = {'k' 'm' 'c' 'r' 'g' 'b'};
for tt = 1:min(length(times), length(cols))
    if ~isnan(times(tt))
        plot([times(tt) times(tt)] - epoch(2), ...
            [-10 10], ':', 'Color', cols{tt});
    end
end

% plot sacs ... these should already be wrt
cols = {'b' 'b' 'c' 'c' 'm' 'm'};    
for ss = 1:2:length(sac_times)
    if ~isnan(sac_times(ss))
        % latency to onset
        plot([sac_times(ss) sac_times(ss)], ...
            [-12 12], '-', 'Color', cols{ss});
    end
    if ~isnan(sac_times(ss+1))
        % duration
        plot(sac_times(ss) + [sac_times(ss+1) sac_times(ss+1)], ...
            [-12 12], '--', 'Color', cols{ss+1});
    end
end

% set axis
set(gca, 'YLim', [-12 12]);

% bottom plot is X vs Y
subplot(2,1,2);
hold off;
plot(aData(start_ind:end_ind, 1), aData(start_ind:end_ind, 2), 'k-');
hold on;

% plot objects
cols = {'g' 'r' 'b' 'k' 'c' 'm'};
for ll = 1:2:min(length(locs), length(cols)*2)
    if ~isnan(locs(ll)) && ~isnan(locs(ll+1))
        plot(locs(ll), locs(ll+1), 'o', ...
            'MarkerFaceColor', cols{floor(ll/2)+1}, ...
            'MarkerEdgeColor', cols{floor(ll/2)+1});
    end
end

% plot sacs
cols = {'b' 'c' 'm'};    
for ss = 1:2:length(sac_locs)
    if ~isnan(sac_locs(ss)) && ~isnan(sac_locs(ss+1))
        plot(sac_locs(ss), sac_locs(ss+1), 'x', ...
            'MarkerFaceColor', cols{floor(ss/2)+1}, ...
            'MarkerSize', 20);
    end
end

% set axis
axis([-12 12 -12 12]);