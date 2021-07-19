function  [rates_, zs_, raws_] = getFIRA_rateByBin(Ltr, spikei, rate_begin, rate_end, rate_wrt, bins)
% function  [rates_, zs_, raws_] = getFIRA_rateByBin(Ltr, spikei, rate_begin, rate_end, rate_wrt, bins)
%
% Compute spike rate for each trial TRIALS for each bin in BINS.
%  function rate = getFIRA_rateBined(trials, spikei, rate_begin, rate_end, rate_wrt, bins)%
%
% INPUTS:
%   Ltr         : selection array for trials
%   spikei      : spike id
%   rate_begin  : rate begin time
%   rate_end    : rate end time
%   rate_wrt    : rate with respect to time
%   bins        : time bins for which spike rate is computed for each trial.
%                 BINS = [t0 t1; t1 t2;... tn-1 tn], bin edges can be overlapped.
% OUTPUTS:
%   rates_      : bins x [mean std sem n]
%   zs_         : zscores of rate per trial per bin
%   raws_       : raw rates per trial per bin
%

% modified from plotFIRA_raterPSTH.m (written by jig) by ctl on 8/10/05

global FIRA

% easy check for now
if nargin < 4 || isempty(FIRA) || isempty(FIRA.spikes.data) || ...
        isempty(Ltr) || ~any(Ltr) || isempty(spikei) || spikei < 1 || ...
        spikei > size(FIRA.spikes.data,2)
    rates_ = [];
    if nargout > 1
        zs_ = [];
    end
    if nargout > 2
        raws_ = [];
    end
    return
end

%%%
% DATA LOOP
%%%
%
% loop through the trials, get spike rate for each bins
% get the trial indices
if islogical(Ltr)
    trials = find(Ltr);
else
    trials = Ltr;
end
% good trials
Lgood      = isfinite(rate_end) & isfinite(rate_begin) & rate_end > rate_begin;
if nargin < 6 || isempty(bins)
    
    % no time bins
    rpt = nans(length(trials), 1);
    rts = rate_end - rate_begin;
    for ii = find(Lgood)'

        % get spikes from this trial
        sp      = FIRA.spikes.data{trials(ii), spikei};
        rpt(ii) = sum(sp>=rate_begin(ii) & ...
            sp<=rate_end(ii))/rts(ii);
    end

else

    % check wrt
    if isempty(rate_wrt)
        rate_wrt = rate_begin;
    end
    
    % time bins
    rpt = nans(length(trials), size(bins,1));
    rts = bins(:,2)-bins(:,1); % in msec
    for ii = find(Lgood)'

        % get spikes from this trial, good bins
        sp   = FIRA.spikes.data{trials(ii), spikei};
        wrtb = bins+rate_wrt(ii);
        
        % add spikes per bin
        for bb = find(wrtb(:,1)>=rate_begin(ii) & wrtb(:,2)<=rate_end(ii))'
            rpt(ii,bb) = sum(sp>=wrtb(bb,1) & sp<=wrtb(bb,2))/rts(bb);
        end
    end
end

% convert to sp/s
rpt = rpt*1000;

% return mean, std, se n per bin
rates_ = [nanmean(rpt,1)', nanstd(rpt,[],1)', nanse(rpt,1)', sum(isfinite(rpt),1)'];

% return z-scores per trial per bin
if nargout > 1
    zs_ = nanzscore(rpt);
end

% return raw rates
if nargout > 2
    raws_ = rpt;
end

