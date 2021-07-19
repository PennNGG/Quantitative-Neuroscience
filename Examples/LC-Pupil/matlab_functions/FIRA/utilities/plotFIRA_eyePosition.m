function plotFIRA_eyePosition(trials, begin_times, end_times, wrt_times, ...
    epoch, sbc_selectors, marker_times, gain, ax1, ax2, ax3)
%function plotFIRA_eyePosition(trials, begin_times, end_times, wrt_times, ...
%    epoch, sbc_selectors, marker_times, gain, ax1, ax2, ax3)
%
% Plots eye position data in X vs T, Y vs T, and X vs Y format
%
% Arguments:
%   trials          ... array of trials to use
%   begin_times     ... array of epoch start times (re: trial wrt)
%   end_times       ... array of epoch end times (re: trial wrt)
%   wrt_times       ... array of epoch wrt times (re: trial wrt)
%   epoch           ... min, max epoch length
%   sbc_selectors   ... selection matrix, rows are trials, cols are colors
%   marker_times    ... matrix of times of markers (re: trial wrt), cols
%                           are different markers
%   gain            ... additional gain for the X, Y channels
%   ax1             ... axis to plot X vs T. [] if not shown.
%   ax2             ... axis to plot Y vs T. [] if not shown.
%   ax3             ... axis to plot X vs Y. [] if not shown.
%

% updated 11/05/04 by jig for new FIRA
% Created 2/22/02 by jig

global FIRA

if nargin < 11
    return
end
% outta if there's nothing to do
if isempty(FIRA) || isempty(FIRA.analog) || isempty(trials)
    return
end

% get some useful variables
eyeX = strmatch('horiz_eye', FIRA.analog.name); % index of x eye data
eyeY = strmatch('vert_eye',  FIRA.analog.name); % index of y eye data

% check that we got something
if (~isempty(ax1) || ~isempty(ax3)) && isempty(eyeX)
    return
end
if (~isempty(ax2) || ~isempty(ax3)) && isempty(eyeY)
    return
end

% get array of start, end times for each trial of analog data
% use t_int (sample interval in ms, assumed to be the same for each 
%   channel)
astart  = round([FIRA.analog.data(trials, eyeX).start_time]');
t_int   = 1000/FIRA.analog.store_rate(1);
lengths = [FIRA.analog.data(trials, eyeX).length]';

% get begin indices, check that it doesn't start too soon
if isempty(begin_times)
    begin_inds = ones(length(trials), 1);
else
    begin_inds = ceil((begin_times-astart)/t_int) + 1;
    begin_inds(isnan(begin_inds) | begin_inds < 1) = 1;
end

% get end indices, check that it doesn't last too long
if isempty(end_times)
    end_inds = lengths;
else
    end_inds = ceil((end_times-astart)/t_int)+1;
    end_inds(isnan(end_inds) | end_inds > lengths) = ...
        lengths(isnan(end_inds) | end_inds > lengths);
end

% check for too long
if length(epoch) == 2 && epoch(2) > 0
    Lt = (end_inds - begin_inds)*t_int > epoch(2);
    if any(Lt)
        end_inds(Lt) = begin_inds(Lt) + ceil(epoch(2)/t_int);
        end_inds(end_inds > lengths) = lengths(end_inds > lengths);
    end
end

% check wrt
if isempty(wrt_times)
    wrt_times = zeros(length(trials), 1);
end

% look for good trials
if isempty(epoch)
    epoch = [-inf inf];
end
Lgood = ~isnan(astart) & begin_inds < end_inds & (end_inds-begin_inds)*t_int >= epoch(1);
if ~any(Lgood)
    return
end
if ~all(Lgood)
    trials        = trials(Lgood);
    begin_inds    = begin_inds(Lgood);
    end_inds      = end_inds(Lgood);
    astart        = astart(Lgood);
    wrt_times     = wrt_times(Lgood);
    sbc_selectors = sbc_selectors(Lgood, :);
    if ~isempty(marker_times)
        marker_times = marker_times(Lgood, :);
    end
end
num_trials = length(trials);

% default wrt is 0
wrt_times(isnan(wrt_times)) = 0;

% sort by colors
% color list is an array of indices into the color array
color_list = ones(num_trials, 1);
colors     = {'k' 'r' 'g' 'b' 'c' 'm' 'y' [.2 .2 .2] [.5 .5 .5] [.8 .8 .8]};
lenc       = length(colors);

% remember sbc_selectors is a matrix of selection arrays
if size(sbc_selectors, 2) > 1

    % check to make sure we have enough colors...
    if size(sbc_selectors, 2) > lenc
        sbc_selectors = [sbc_selectors(:, 1:lenc-1) ...
            any(sbc_selectors(:, lenc:end), 2)];
    end

    % for each selection array, assign a different color index
    for i = 1:size(sbc_selectors, 2)
        color_list(sbc_selectors(:,i)) = i;
    end
end

% set up markers arrays
markers = {'v' 'd' '*'};
ind = 1;
while ind <= size(marker_times, 2)    
    if all(isnan(marker_times(:,ind)))
        marker_times(:,ind) = [];
    else
        ind = ind + 1;
    end
end
num_markers  = size(marker_times, 2);
if num_markers
    marker_times = marker_times - repmat(wrt_times, 1, num_markers);
end

%%%
% draw dummy data, which sets up the appropriate handles
%%%
nt = num_trials*(num_markers+1);
zs = zeros(2, nt);
hs = zeros(nt, 3);
if ax1
    axes(ax1); cla; %hold on;
    hs(:,1) = plot(zs,zs,'-');
end
if ax2
    axes(ax2); cla; %hold on;
    hs(:,2) = plot(zs,zs,'-');
end
if ax3
    axes(ax3); cla; %hold on;
    hs(:,3) = plot(zs,zs,'-');
end

% make time array, base
tarray = (0:max(end_inds))'*t_int;
tbase  = astart + tarray(begin_inds) - wrt_times;
%%%
% now loop through the data and associate it with the appropriate plots
%%%
for i = 1:num_trials

    % get the data
    Xs = gain*FIRA.analog.data(trials(i), eyeX).values(begin_inds(i):end_inds(i));
    Ys = gain*FIRA.analog.data(trials(i), eyeY).values(begin_inds(i):end_inds(i));
    Ts = tarray(1:length(Xs))+tbase(i);
    
    co = colors{color_list(i)};
    if ~(isempty(Xs) || isempty(Ys) || isempty(Ts))
        
        %%%
        % plot X vs T
        %%%
        if ax1
            set(hs(i,1), 'XData', Ts, 'YData', Xs, 'Color', co);
        end

        %%%
        % plot Y vs T
        %%%
        if ax2
            set(hs(i,2), 'XData', Ts, 'YData', Ys, 'Color', co);
        end

        %%%
        % plot X vs Y
        %%%
        if ax3
            set(hs(i,3), 'XData', Xs, 'YData', Ys, 'Color', co);
        end

        %%%
        % plot the markers
        %%%
        co = colors{color_list(i)+2};
        for j = 1:num_markers
            if ~isnan(marker_times(i,j))
                ind = find(Ts>=marker_times(i,j), 1, 'first');
                if ~isempty(ind)
                    ii = i+j*num_trials;
                    if ax1
                        set(hs(ii,1), 'XData', Ts(ind), 'YData', Xs(ind), ...
                            'Marker', markers{j}, 'Color', co, 'MarkerFaceColor', co);
                    end
                    if ax2
                        set(hs(ii,2), 'XData', Ts(ind), 'YData', Ys(ind), ...
                            'Marker', markers{j}, 'Color', co, 'MarkerFaceColor', co);
                    end
                    if ax3
                        set(hs(ii,3), 'XData', Xs(ind), 'YData', Ys(ind), ...
                            'Marker', markers{j}, 'Color', co, 'MarkerFaceColor', co);
                    end
                end
            end
        end
    end
end
    