% Power Analysis Example (Joshi et al, 2016)
%   Answers to exersises
%
% Python: https://github.com/PennNGG/Quantitative-Neuroscience/blob/master/Concepts/Python/Error%20Types%2C%20P-Values%2C%20False-Positive%20Risk%2C%20and%20Power%20Analysis.ipynb
%
% Copyright 2020 by Joshua I. Gold, University of Pennsylvania

% Create a null distribution of "no relationship between LC spike rate and
% pupil size" by simulateing a bunch of "experiments" with no effect. Here
% we are assuming that LC spike counts are poisson distributed with a rate
% of 1 Hz, and pupil has already been z-scored (so the mean is zero and the
% std is one)
trialsPerExeriment  = 200;
numExperiments = 1000;
spikeRates = poissrnd(1, trialsPerExeriment, numExperiments);
pupils = normrnd(0, 1, trialsPerExeriment, numExperiments);

corrs = nans(numExperiments, 1);
for ii = 1:numExperiments
   corrs(ii) = corr(spikeRates(:,ii), pupils(:,ii), 'type', 'Spearman');
end

% Show the histogram of the simulated null distribution
histogram(corrs, 50);
xlabel('Correlation coefficients');
ylabel('Count');
disp([mean(corrs) std(corrs)])

% We can perform a power analysis to find the n needed for different 
%  effect sizes at a given power (here 80%):

% Argument 1: test type
test_type = 't2';

% Argument 2: mean and std under null hypothesis
P0 = [0 std(corrs)];

% Argument 3: effect size
% Compute n at 80% power for different effect sizes (effect sizes are mean
% correlation coefficient for a positive effect)
effect_sizes = (0.01:0.01:0.2)';
num_effect_sizes = length(effect_sizes);

% Argument 4: power
power = 0.8;

% Loop through each effect size
ns = nans(num_effect_sizes, 1);
for ii = 1:num_effect_sizes
   ns(ii) = sampsizepwr(test_type, P0, effect_sizes(ii), power);
end

plot(effect_sizes, ns, 'bo-')
xlabel('Effect sizes')
ylabel('n for 80% power')