function fits_ = plotFIRA_neurometricROCT(trials, Lsd, Lsc, ...
    cohs, spikei, begin_times, end_times, bin_start, bin_end, ...
    do_fits, ax1, ax2)
%function fits_ = plotFIRA_neurometricROCT(trials, Lsd, Lsc, ...
%    cohs, spikei, begin_times, end_times, bin_start, bin_end, ...
%    do_fits, ax1, ax2)
%
% Function to plot time-dependent fits to ROC analysis
%   of spike data. alphas are fit with decaying
%   exponential. betas are fit with a line.
%
% Returns:
%   fits_   ... cols are best fit & sem
%               rows are:
%                   lambda
%                   alpha (threshold) asymptote
%                   alpha (threshold) time constant
%                   beta  (slope)     y-intercept
%                   beta  (slope)     slope

% fit the whole thing to get lambda
lfits = plotFIRA_neurometricROC(trials, Lsd, ...
    Lsc, cohs, spikei, begin_times, end_times);

num_bins = length(bin_start);

% store the fits, sems
dat = nans(num_bins, 3, 2);

% loop through the bins, collecting fits. Send in lambda
%   from whole fit
for nn = 1:num_bins
    
    fits = plotFIRA_neurometricROC(trials, ...
        Lsd, Lsc, cohs, spikei, ...
        min(begin_times+bin_start(nn), end_times), ...
        min(begin_times+bin_end(nn),   end_times), lfits(3, 1));
    
    dat(nn, :, 1) = fits(:, 1)';
    dat(nn, :, 2) = fits(:, 2)';

end

% xax is middle of the bins
xax = [bin_start + (bin_end-bin_start)./2]';

[xax dat(:, 1,1) dat(:,2,1)]

% plot the fits
axes(ax1); hold off;
errorbar(xax, dat(:, 1, 1), dat(:, 1, 2), 'k.-');
title(sprintf('Lambda = %.1f+%.1f', 100*lfits(3, 1), 100*lfits(3, 2)));
set(gca, 'YLim', [0 60]);

axes(ax2); hold off;
errorbar(xax, dat(:, 2, 1), dat(:, 2, 2), 'k.-');
set(gca, 'YLim', [0 3]);

% fit the fits, if necessary
if do_fits
    
    
    % fit betas to a line
%    [b,bint,h,p] = regressW(dat(:,2,1), dat(:,2,2), ...
%        [xax ones(size(xax))])
    
%    xx = min(xax):max(xax);
%    plot(xx, polyval(b,xx), 'k--');
end
        
    
% return
if nargout == 1
    fits_ = [ ...
        lfits(3, :); ...
        ];
end