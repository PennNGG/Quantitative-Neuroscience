function [rocs_, ns_, sems_] = getFIRA_neurometricROCT(trials, Lsd, Lsc, ...
    spikei, begin_times, end_times, time_bins, min_n)
%function [rocs_, ns_, sems_] = getFIRA_neurometricROCT(trials, Lsd, Lsc, ...
%    spikei, begin_times, end_times, time_bins, min_n)
%
% Arguments:
%   trials      ... list of FIRA trials
%   Lsd         ... nx2 selection matrix, cols are 2 dirs
%   Lsc         ... nxm selection matrix, cols are coherences
%   spikei      ... index of spike (unit/channel)
%   begin_times ...
%
% Returns:

global FIRA

if nargin < 8 || isempty(min_n)
    min_n = 5;
end

num_times = size(time_bins, 1);
num_cohs  = size(Lsc, 2);

% make matrix of roc areas, rows are time bins, cols
%    are cohs
rocs_ = nans(num_times, num_cohs);
ns_   = nans(num_times, num_cohs);
sems_ = nans(num_times, num_cohs);

% loop through each time/coh pair
for tt = 1:num_times

    % bin start, end should not exceed end times
    bin_start = begin_times + time_bins(tt, 1);
    bin_end   = begin_times + time_bins(tt, 2);
    Ltime     = bin_end <= end_times;

    % collect spikes per bin
    spikes = zeros(size(Ltime));

    for ss = find(Ltime)'

        spikes(ss) = sum(FIRA.spikes.data{trials(ss), spikei} >= ...
            bin_start(ss) & FIRA.spikes.data{trials(ss), ...
            spikei} <= bin_end(ss));
    end

    % loop through each coherence & compute ROC area
    for cc = 1:num_cohs

        % collect spike counts for direction #1
        r1 = spikes(Ltime & Lsc(:, cc) & Lsd(:, 1));
        r2 = spikes(Ltime & Lsc(:, cc) & Lsd(:, 2));

        if length(r1) > min_n && length(r2) > min_n

            % compute roc
            rocs_(tt, cc) = rocN(r1, r2, 75);
            ns_  (tt, cc) = length(r1) + length(r2);
        end
    end
end

% flip the dirs if necessary
if nanmean(rocs_(:)) < 0.5
    rocs_(:) = 1 - rocs_(:);
end
