function [stats_, badTrials_] = plotFIRA_rasterPSTH(trials, Lsb, spikei, ...
    raster_begin, raster_end, rate_begin, rate_end, user_markers, ...
    bin_size, sort_raster, raster_axs, raster_hs, psth_axs, psth_hs, ribbon)
% function [stats_, badTrials_] = plotFIRA_rasterPSTH(trials, Lsb, spikei, ...
%    raster_begin, raster_end, rate_begin, rate_end, user_markers, ...
%    bin_size, sort_raster, raster_axs, raster_hs, psth_axs, psth_hs, ribbon)
%
% Makes raster and psth plots from FIRA. Will make a series
%   of plots depending on the selection array Lsb (see below).
%
% Arguments:
%   trials ... nx1 array of valid trial indices (default all)
%   Lsb    ... nxm selection arrays -- each column specifies data for a
%               separate pair of raster/psth plots
%   spikei ... scalar index of spike channel to plot
%   raster_begin ... nx1 array of start times of raster data
%   raster_end   ... nx1 array of end times of raster data
%   rate_begin   ... nx1 array of rate begin times for psth (also wrt
%                       times for raster)
%   rate_end     ... nx1 array of rate end times for psth
%   user_markers ... nx(1 or 2) matrix of (optional) marker times for m1, m2
%   bin_size     ... scalar size of bins plotted in psth (in ms)
%                    optional [bin_size step_size]
%   sort_raster  ... flag for sorting raster data:
%                       2 = sort by raster time
%                       3 = sort by rate time
%   raster_axs   ... m axes to plot rasters
%   raster_hs    ... mx5 handles to plot raster data. 5 plot objects are:
%                       1. the raster data
%                       2. line at 0
%                       3. marker at raster on (small green diamond)
%                       3. marker at raster off (small red diamond)
%                       3. marker at rate off (small
%                       4. m1 (optional; cyan)
%                       5. m2 (optional, magenta)
%   psth_axs     ... m axes to plot psth
%   psth_hs      ... mx2 handles to plot psth data. 2 plot objects are:
%                       1. bar plot
%                       2. line at 0
%   ribbon       ... flag -- if present, plot psth as ribbon
%
% Returns:
%   stats_ ... array (one per plot) of
%               mean sem std median iqr n
global FIRA

%% CHECK FOR FIRA
if isempty(FIRA) || isempty(FIRA.spikes.data)
    if nargout > 0
        stats_ = [];
    end
    if nargout > 1
        badTrials_ = inf;
    end
    return
end

%% CHECK ARGUMENTS
% trials is array of valid trial indices from FIRA
if nargin < 1 || isempty(trials)
    trials = (1:size(FIRA.spikes.data,1))';
elseif islogical(trials)
    trials = find(trials);
end
ntrials = size(trials,1);

% Lsb is matrix of selection arrays
if nargin < 2 || isempty(Lsb)
    Lsb = true(size(trials));
elseif ntrials<size(Lsb,1) && trials(end)<=size(Lsb,1)
    Lsb = Lsb(trials,:);
end

% spikei is spike index
if nargin < 3 || isempty(spikei) || spikei < 1
    spikei = 1;
elseif spikei > size(FIRA.spikes.data,2)
    spikei = size(FIRA.spikes.data,2);
end

%% check times...
Lgood = true(size(trials));

% raster_begin determines start time of the plotted raster
if nargin < 4 || isempty(raster_begin)
    raster_begin = zeros(size(trials));
else
    if size(raster_begin,1) > ntrials && size(raster_begin,1) >= trials(end)
        raster_begin = raster_begin(trials);
    end
    Lgood = Lgood & ~isnan(raster_begin);
end

% raster_end determines end time of the plotted raster
if nargin < 5 || isempty(raster_end)
    raster_end = 5000*ones(size(trials));
else
    if size(raster_end,1) > ntrials && size(raster_end,1) >= trials(end)
        raster_end = raster_end(trials);
    end
    Lgood = Lgood & ~isnan(raster_end);
end

% rate_begin determines rate computation, for polar plot
% also used as "wrt" for raster plot
if nargin < 6 || isempty(rate_begin) % use for wrt
    rate_begin = zeros(size(trials));
    wrt        = zeros(size(trials));
else
    if size(rate_begin,1) > ntrials && size(rate_begin,1) >= trials(end)
        rate_begin = rate_begin(trials);
    end
    wrt        = rate_begin;
    Lgood      = Lgood & ~isnan(rate_begin);
end

% rate_end is end of rate computation
if nargin < 7 || isempty(rate_end)
    rate_end = rate_begin+100;
else
    if size(rate_end,1) > ntrials && size(rate_end,1) >= trials(end)
        rate_end = rate_end(trials);
    end
    Lgood = Lgood & ~isnan(rate_end);
end

% add markers to raster begin, end and rate end
markers = [raster_begin raster_end rate_end];
if nargin > 8 && ~isempty(user_markers)
    if size(user_markers,1) == ntrials
        markers = cat(2, markers, user_markers);
    elseif size(user_markers,1) >= trials(end)
        markers = cat(2, markers, user_markers(trials));
    end
end

% trim data
if ~all(Lgood)
    trials       = trials(Lgood);
    Lsb          = Lsb(Lgood, :);
    raster_begin = raster_begin(Lgood);
    raster_end   = raster_end(Lgood);
    rate_begin   = rate_begin(Lgood);
    rate_end     = rate_end(Lgood);
    wrt          = wrt(Lgood);
    markers      = markers(Lgood, :);
end

% size of bins plotted in psth (in ms)
if nargin < 9 || isempty(bin_size)
    bin_size  = 50;
    step_size = 50;
elseif isscalar(bin_size)
    step_size = bin_size;
else
    step_size = bin_size(2);
    bin_size  = bin_size(1);
end

% flag for sorting raster data
if nargin < 10 || isempty(sort_raster)
    sort_raster = 0;
end

% number of raster/psth pairs to plot
num_sets = size(Lsb, 2);

if nargin < 15 || isempty(ribbon)
    ribbon = {};
elseif ~iscell(ribbon)
    ribbon = cell(1,num_sets);
    for xx = 1:num_sets
        ribbon{xx} = 0.5.*ones(1,3);
    end
end

% axes, handles for raster & psth data
if nargin < 11 || (isempty(raster_axs) && (nargin < 13 || isempty(psth_axs)))
    raster_axs = nans(num_sets, 1);
    psth_axs   = nans(num_sets, 1);
    for xx = 1:num_sets
        raster_axs(xx) = subplot(2, num_sets, xx); cla reset; hold on;
        psth_axs(xx)   = subplot(2, num_sets, num_sets+xx); cla reset; hold on;
    end
elseif nargin < 13
    psth_axs = [];
end
if ~isempty(raster_axs) && (nargin < 12 || isempty(raster_hs))
    raster_hs = nans(num_sets, 8);
    for xx = 1:num_sets
        axes(raster_axs(xx));
        raster_hs(xx,1) = plot(0, 0, 'k.', 'MarkerSize', 2)'; hold on;
        raster_hs(xx,2) = plot(0, 0, 'r-', 'LineWidth', 2.5)';
        if ~isempty(ribbon)
            set(raster_hs(xx,2), 'Color', ribbon{xx});
        end
        raster_hs(xx,3) = plot(0, 0, 'r.', 'MarkerFaceColor', 'r', 'MarkerSize', 3)';
        raster_hs(xx,4) = plot(0, 0, 'r.', 'MarkerFaceColor', 'r', 'MarkerSize', 3)';
        raster_hs(xx,5) = plot(0, 0, 'g.', 'MarkerFaceColor', 'g', 'MarkerSize', 5)';
        raster_hs(xx,6) = plot(0, 0, 'c.', 'MarkerFaceColor', 'c', 'MarkerSize', 5)';
        raster_hs(xx,7) = plot(0, 0, 'b.', 'MarkerFaceColor', 'b', 'MarkerSize', 5)';
        raster_hs(xx,8) = plot(0, 0, 'm.', 'MarkerFaceColor', 'm', 'MarkerSize', 5)';
    end
end
if ~isempty(psth_axs) && (nargin < 14 || isempty(psth_hs))
    psth_hs = nans(num_sets, 2);
    for xx = 1:num_sets
        axes(psth_axs(xx));
        if ~isempty(ribbon)
            psth_hs(xx, 1) = patch(0, 0, ribbon{xx})'; hold on;
            set(psth_hs(xx, 1), 'LineStyle', 'none');
%            psth_hs(xx, 1) = plot(0, 0, '-', 'Color', ribbon{xx})'; hold on;
        else
            psth_hs(xx, 1) = bar(0, 0)'; hold on;
            set(psth_hs(xx, 1), 'BarWidth', 1, 'FaceColor', 'k');
        end
        psth_hs(xx, 2) = plot(0, 0, 'k-', 'LineWidth', 2.5)';
    end
end

% keep track of axis limits (height, left, right)
lims = zeros(num_sets, 4);

% stats_ contains for each axis information about the rate:
% mean sem std median iqr n
stats_ = nans(num_sets, 6);

%%%
% DATA LOOP
%%%
%
% loop through the sets (psth/raster pairs), plotting and saving stats
Lgtimes = isfinite(raster_begin) & isfinite(raster_end) & isfinite(wrt);
for i = 1:num_sets
    
    % get the trial indices
    trs    = find(Lsb(:,i) & Lgtimes);
    ntrs   = size(trs,1);
    raster = [];
    rate   = zeros(ntrs, 1);
    
    if ntrs > 0
        
        % sort, if neccesary
        if sort_raster == 2 % sort by raster time
            [I,Y] = sort(raster_end(trs) - raster_begin(trs));
            trs = trs(Y);
            
        elseif sort_raster == 3 % sort by rate time
            [I,Y] = sort(rate_end(trs) - rate_begin(trs));
            trs = trs(Y);
        end
        
        % (hopefully) faster way of keeping track of the number of
        %   trials per bin, for the psth
        mint = floor(min(raster_begin(trs)-wrt(trs)));
        maxt = ceil(max(raster_end(trs)-wrt(trs)));
        lent = maxt - mint;
        if ~isempty(ribbon)
            psth_times  = (mint:step_size:maxt)';
            psth_times  = [psth_times psth_times+bin_size];
            ntimes      = size(psth_times,1);
            psth_counts = nans(ntrs, ntimes);
            psth_bts    = raster_begin(trs) - wrt(trs);
            psth_ets    = raster_end(trs)   - wrt(trs);
        elseif ~isempty(psth_axs) && lent < 10000
            psth_times = zeros(1, lent+1);
            psth_bts   = floor(raster_begin(trs) - wrt(trs)) - mint + 1;
            psth_ets   = ceil(raster_end(trs) - wrt(trs)) - mint + 1;
        else
            lent       = [];
            psth_times = [];
        end
        
        % loop through the trials
        for tt = 1:ntrs
            
            % get trial index
            ti = trs(tt);
            
            % get spikes from this trial
            sp = FIRA.spikes.data{trials(ti), spikei};
            
            if ~isempty(sp)
                
                % raster ... not sure how to speed this
                % makes a matrix with 2 columns: spike times, row number
                msp = sp(sp>=raster_begin(ti)&sp<=raster_end(ti));
                if ~isempty(msp)
                    raster = [raster; msp-wrt(ti) tt*ones(size(msp))];
                end
                
                % rate
                if rate_end(ti) > rate_begin(ti)
                    rate(tt) = 1000*sum(sp>=rate_begin(ti)&sp<=rate_end(ti)) / ...
                        (rate_end(ti)-rate_begin(ti));
                end
                
                % psth -- keep track of the eligible time bins
                if ~isempty(psth_axs)
                    if ~isempty(ribbon)
                        msp = msp - wrt(ti);
                        for bb = 1:ntimes
                            if psth_bts(tt) <= psth_times(bb,1) && psth_ets(tt) >= psth_times(bb,2)
                                psth_counts(tt,bb) = sum(msp>=psth_times(bb,1) & msp<psth_times(bb,2));
                            end
                        end
                        
                    elseif ~isempty(lent)
                        
                        % this is the way we like to compute it -- increment counts
                        % for the given time interval
                        psth_times(psth_bts(tt):psth_ets(tt)) = ...
                            psth_times(psth_bts(tt):psth_ets(tt)) + 1;
                        
                    elseif ~isinf(raster_begin(ti)) && ~isinf(raster_end(ti))
                        
                        % this is a much slower way -- keep track of all the times
                        psth_times = [psth_times; (raster_begin(ti):raster_end(ti))'-wrt(ti)];
                        
                    else
                        
                        % this way sucks -- we don't really even know when the
                        % trial begins & ends
                        psth_times = [psth_times; (min(sp):max(sp))'-wrt(ti)];
                    end
                end
            end
        end
        
        if ~isempty(raster)
            
            % compute stats
            stats_(i,:) = [mean(rate) std(rate) std(rate) ...
                median(rate,1) iqr(rate) length(rate)];
            
            % plot raster, markers
            if ~isempty(raster_hs)
                set(raster_hs(i, 1), 'XData', raster(:,1), 'YData', raster(:,2));
                for m = 1:size(markers,2)
                    set(raster_hs(i,2+m), 'XData', markers(trs,m)-wrt(trs), ...
                        'YData', 1:ntrs);
                end
            end
            
            % plot psth
            if ~isempty(psth_hs)
                if ~isempty(ribbon)
                    xs = mean(psth_times,2);
                    ys = nanmean(psth_counts)';
                    es = nanse(psth_counts)';
                    p1 = ys-es;
                    p2 = ys+es;
                    xs = [xs;xs(end:-1:1)];
                    ys = [p1;p2(end:-1:1)];
                    Lg = isfinite(ys);
                    xs = xs(Lg);
                    ys = ys(Lg);
                else
                    if ~isempty(lent)
                        xs = (mint:bin_size:maxt)';
                        ys = histc(raster(:,1), xs)*1000; % ctl & jig removed bin_size scale term, 6/27/05
                        ys = ys(:);
                        yd  = zeros(bin_size, length(xs));
                        len = min(length(psth_times), length(xs)*bin_size);
                        yd(1:len) = psth_times(1:len);
                        yd = sum(yd,1)';
                    else
                        xs = (min(psth_times):bin_size:max(psth_times))';
                        ys = histc(raster(:,1), xs)*1000;
                        ys = ys(:);
                        yd = histc(psth_times, xs);
                    end
                    Lp      = yd>0;
                    ys(Lp)  = ys(Lp)./yd(Lp);
                    ys(~Lp) = 0;
                end
                set(psth_hs(i,1), 'XData', xs, 'YData', ys);
                lims(i, 4) = max(ys);
            end
            
            % keep track of axis limits
            lims(i, 1:3) = [max(raster(:,2)) min(raster(:,1)) max(raster(:,1))];
            if isfinite(mint)
                lims(i,2) = mint;
            end
            if isfinite(maxt)
                lims(i,3) = maxt;
            end
        end
    end
end

% clear extra markers
if ~isempty(raster_hs) && size(markers,2) < 3
    set(raster_hs(:, size(markers,2)+3:end), 'XData', [], 'YData', []);
end

if ~isempty(raster_axs) || ~isempty(psth_axs)
    minx = min(lims(:,2));
    maxx = max(lims(:,3));
    if minx == maxx
        maxx = minx + 1;
    end
end

% set the raster axes, draw line at 0
if ~isempty(raster_axs)
    
    % set axes
    nrows = max(lims(:,1));
    if nrows == 0
        nrows = 1;
    end
    set(raster_axs, 'XLim', [minx-1 maxx+1], 'YLim', [0 nrows]);
    
    % draw line at zero
    set(raster_hs(:,2), 'XData', [0 0], 'YData', [0 nrows]);
    
    % set marker style for raster
    if nrows > 20
        set(raster_hs(:,1), 'Marker', '.', 'MarkerSize', 2);
    else
        set(raster_hs(:,1), 'Marker', '+', 'MarkerSize', 2);
    end
end

% set the psth axes, draw line at 0
if ~isempty(psth_axs)
    
    % set axes
    nrows = max(lims(:,4));
    if nrows == 0
        nrows = 1;
    end
    set(psth_axs, 'XLim', [minx-1 maxx+1], 'YLim', [0 nrows]);
    
    % draw line at zero
    set(psth_hs(:,2), 'XData', [0 0], 'YData', [0 nrows]);
end

if nargout == 2
    badTrials_ = sum(~Lgood);
end
