function ctPsych_plotNice(data, fits, fun, tb1, tb2, cohs, ax1, ax2)
% function ctPsych_plotNice(data, fits, fun, tb1, tb2, cohs, ax1, ax2)
%
% plots data & fit
%
% Arguments:
%   data, in 5 columns...
%       data(1) = coh  (0 .. 99.9%)
%       data(2) = time (fractional seconds)
%       data(3) = dot dir: left (-1) / right (1)
%       data(4) = pct or correct (1) / error (0)
%       data(5) = (optional) n
%   fits    ... ML fits of data to given fun
%   fun     ... "val" function
%   tbins   ... scalar number of bins, or [bin_start bin_end] x bins
%   cohs

if nargin < 3
    return
end

% time bins
if nargin < 4 || isempty(tb1)
    tb1 = 4;
end

if nargin < 5 || isempty(tb2)
    tb2 = 15;
end

% cohs
if nargin < 6 || isempty(cohs)
    cohs = nonanunique(data(:,1));
end

co          = {'m' 'c' 'r' 'g' 'b' 'k' 'y'};
font_size   = 18;
marker_size = 15;
line_width  = 1;
cmm         = [0.008 1];
tmm         = [0.05 1];

%%
% plot vs coh, binned by time
%%
if nargin > 6 && ~isempty(ax1)

    axes(ax1);cla;hold on;

    if ~isempty(data)

        %%%
        % show data
        %%%
        [pcts, tb] = makeData(data, tb1, cohs);

        for tt = 1:size(tb, 2)

            % plot the data
            plot(cohs, pcts(:,tt), '.', ...
                'MarkerSize', marker_size, 'Color', co{mod(tt-1,length(co))+1});
        end
    else
        tb = tb1;
    end

    if ~isempty(fits)

        %%%
        % show fits
        %%%
        xs = linspace(cmm(1), cmm(2), 100)';
        ds = [xs repmat([1 1], length(xs), 1)];
        ts = sum(tb)./2;

        for tt = 1:size(tb, 2)

            % get & plot the fits
            ds(:,2) = ts(tt);
            plot(xs, 100.*feval(fun, fits, ds), ...
                '-', 'Color', co{mod(tt-1,length(co))+1}, 'LineWidth', line_width);
        end
    end

    plot(cmm, [50 50], 'k--');
    set(ax1, 'XScale', 'log', 'FontSize', font_size);
    axis([cmm 45 100]);
    xlabel('Motion strength (% coherence)');
    ylabel('Percent correct');
end

%%
% plot vs time, per coh
%%
if nargin > 7 && ~isempty(ax2)

    axes(ax2);cla;hold on;

    if ~isempty(data)

        %%%
        % show data
        %%%
        [pcts, tb] = makeData(data, tb2, cohs);

        ts = sum(tb)./2;
        for cc = 1:length(cohs)

            % plot the data
            plot(ts, pcts(cc, :), '.', ...
                'MarkerSize', marker_size, 'Color', co{cc});
        end
    end
    
    if ~isempty(fits)

        %%%
        % show fits
        %%%
        xs = linspace(tmm(1), tmm(2), 100)';
        ds = [ones(size(xs)) xs ones(size(xs))];

        for cc = 1:length(cohs)

            % get the fits
            ds(:,1) = cohs(cc);
            plot(xs, 100.*feval(fun, fits, ds), ...
                '-', 'Color', co{cc}, 'LineWidth', line_width);
        end
    end

    plot(tmm, [50 50], 'k--');
    set(ax2, 'FontSize', font_size);
    axis([tmm 45 100]);
%    xlabel('View time');
    ylabel('Percent correct');
end

function [pcts, tb, cb] = makeData(data, tb, cb)

% get time bins
% if "tbins" is a scalar, it indicate the number
% of bins; otherwise, the actual bins are given
if length(tb) == 1

    if isinf(tb)

        % if tbins = inf, show unique times
        tb = repmat(nonanunique(data(:,2))', 2, 1);

    else

        % make tbins # of bins
        tb = prctile(data(:,2), linspace(0, 100, tb+1));
        tb = [tb(1:end-1); tb(2:end)];
    end
end

% get cohs
if isempty(cb)
    cb = nonanunique(data(:,1));
end

% pct correct data
pcts = zeros(size(cb,1), size(tb,2));

for cc = 1:size(cb,1)

    % select coherence
    Lc = data(:,1) == cb(cc);

    for tt = 1:size(tb,2)

        % select time and coherence
        Ltr = Lc & data(:,2)>=tb(1,tt) & data(:,2)<=tb(2,tt);

        % compute percent correct
        pcts(cc, tt) = sum(data(Ltr,4)==1)./sum(Ltr).*100;
    end
end
