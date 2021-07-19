function [fits_, stats_] = plotFIRA_neurometricROC( ...
    trials, Lsd, Lsc, cohs, spikei, begin_times, end_times, ...
    lambda, mainaxis, cohhs)
%function [fits_, stats_] = plotFIRA_neurometricROC( ...
%    trials, Lsd, Lsc, cohs, spikei, begin_times, end_times, ...
%    mainaxis, cohaxes, cohhs)
%
%   Arguments:
%
%       trials      ... list of trials in FIRA
%       Lsd         ... mx2 selection array, cols are directions
%       Lsc         ... mxn selection array, cols are cohs
%       cohs        ... coh values corresponding to cols of Lsc
%       spikei      ... spike index (scalar)
%       begin_times ... begin time of trial epoch 
%       end_times   ... end time of trial epoch
%       lambda      ... optional value of lambda (lapse) to send to fit
%       mainaxis    ... axis to plot % correct and fits
%       cohhs       ... handles to plot objects
%
%   Returns:
%       fits_       ... best fit & sem of alpha, beta, lambda
%       stats_      ... LLR, p
%

global FIRA

% default outputs
if nargout >= 1
    fits_ = [];
end

if nargout >= 2
    stats_ = [];
end

% check args
if nargin < 4 || isempty(FIRA)
    return
end

if nargin < 5 || isempty(spikei)
    spikei = 1;
end

if nargin < 6 || isempty(begin_times)
    begin_times = FIRA.ecodes.data(trials, 2);
end

if nargin < 7 || isempty(end_times)
    end_times = FIRA.ecodes.data(trials, 3);
end

if nargin < 8
    lambda = [];
end

if nargin < 9
    mainaxis = [];
end

if nargin < 10
    cohhs = [];
else
    cohaxes = get(cohhs(:, 1), 'Parent');
    cohaxes = [cohaxes{:}]';
end

% pre-compute the durations, in s
durs = (end_times - begin_times)/1000;

% check that trials have positive durations
Lgood = ~isnan(durs) & durs > 0;

if ~any(Lgood)

    return

elseif ~all(Lgood)

    % ugh. trim inputs.
    durs        = durs(Lgood);
    trials      = trials(Lgood);
    Lsd         = Lsd(Lgood, :);
    Lsc         = Lsc(Lgood, :);
    begin_times = begin_times(Lgood);
    end_times   = end_times(Lgood);    
end

% loop through all the trials, collecting spikes per one sec
rates   = zeros(length(trials), 1);
for tt = find(sum(Lsc, 2) & sum(Lsd, 2))'
    rates(tt) = sum(FIRA.spikes.data{trials(tt), spikei} >= ...
        begin_times(tt) & FIRA.spikes.data{trials(tt), spikei} <= ...
        end_times(tt));
end
rates = rates./durs;

% matrix to hold 
rocs = nans(length(cohs), 3);

% loop through the coherences
for cc = 1:length(cohs)

    % collect spike counts for direction #1
    r1 = rates(Lsc(:, cc) & Lsd(:, 1));
    r2 = rates(Lsc(:, cc) & Lsd(:, 2));
    
    if length(r1) > 2 && length(r2) > 2
        
        % compute roc
        rocs(cc, :) = [cohs(cc) rocN(r1, r2, 75), (length(r1)+length(r2))/2];
        
        % get max count
        max_count = max([r1;r2]);
        
        % store raw data, if necessary
        if ~isempty(cohhs) && max_count > 0
                        
            % make histograms from bar plots
            these_xs = 1:max_count;
            set(cohhs(cc, 1), 'XData', these_xs, ...
                'YData', hist(r1, these_xs));
            set(cohhs(cc, 2), 'XData', these_xs+0.3, ...
                'YData', hist(r2, these_xs));
            ylabel(cohaxes(cc), sprintf('%.1f', cohs(cc)));
        end
    else

        rocs(cc, :) = [cohs(cc) nan 0];
    end
end

% set the axes
if ~isempty(cohhs)
    set(cohaxes, 'XLim', [0 min(80, max(rates))]);
end

% eliminate 0% coh from fits (dir is arbitrary)
rocs = rocs(rocs(:, 1) ~= 0, :);

% flip the dirs if necessary
if mean(rocs(:, 2)) < 0.5
    rocs(:, 2) = 1 - rocs(:, 2);
end

% get the fits
[fits, sems, stats] = quick_fit(rocs, lambda);

% plot the ROC data
if ~isempty(mainaxis)
    quick_plot(rocs, fits(1), fits(2), fits(3), mainaxis, 'k');
    title(sprintf('p=%.2f: a=%.1f+%.1f, b=%.1f+%.1f, l=%.1f+%.1f', ...
        stats(3), fits(1), sems(1), fits(2), sems(2), 100*fits(3), 100*sems(3)));
end

if nargout >= 1
    fits_ = [fits sems];
end

if nargout >= 2
    stats_ = stats;
end
