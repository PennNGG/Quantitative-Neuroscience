%% Descriptive statistics
%
% Colab: https://colab.research.google.com/drive/1R26jZt5UmttyMWS2Aucb-wD-JSRBDYPt#scrollTo=Z32Do1n-bkQ9
%
% Simple examples to compute central tendencies, dispersion, and shapes
%   of samples of data%
% Copyright 2020 by Joshua I. Gold, University of Pennsylvania

% Generate some normally distributed random numbers
mu = 5;
sigma = 10;
N = 10000;

% Get samples
samples = normrnd(mu, sigma, N, 1);

% Central tendencies (do on binned data for mode)
bins = -100.5:100.5;
fprintf('mean=%.2f, median=%.2f, mode (binned data)=%d\n', ...
    mean(samples), median(samples), mode(discretize(samples, bins, bins(1:end-1)+0.5)))

% Dispersion
fprintf('standard deviation = %.2f, interquartile range = [%.2f %.2f]\n', ...
    std(samples), prctile(samples, 25), prctile(samples, 75))

% Shape (this example should be symmetric)
fprintf('skew = %.2f, kurtosis = %.2f\n', ...
    skewness(samples), kurtosis(samples))
