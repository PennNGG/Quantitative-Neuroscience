% Example power analysis for LC-pupil correlations (Joshi et al 2016)

Ntr  = 200;
Nexp = 1000;
spikeRates = poissrnd(2, Ntr, Nexp);
pupils = normrnd(0, 1, Ntr, Nexp);

corrs = nans(Nexp, 1);
for ii = 1:Nexp
   corrs(ii) = corr(spikeRates(:,ii), pupils(:,ii), 'type', 'Spearman');
end

hist(corrs, 50);
xlabel('Correlation coefficients');
ylabel('Count');
disp([mean(corrs) std(corrs)])

% We can use a power analysis to find the new sem. The key point is that a
%  power analysis describes a relationship between the effect size and the
%  power -- so we can define a particular power to compute the effect size.
%  In this case, this is equivalent to doing a z test with one sample and a
%  power of 80%:

% Argument 1: test type
test_type = 't2';

% Argument 2: mean and std under null hypothesis
P0 = [0 std(corrs)];

% Argument 3: effect size
% Compute n at 80% power for different effect sizes
effect_sizes = (0.01:0.01:1)';
num_effect_sizes = length(effect_sizes);

% Argument 4: power
power = 0.8;

% Loop through each effect size
ns = nans(num_effect_sizes, 1);
for ii = 1:num_effect_sizes
   ns(ii) = sampsizepwr(test_type, P0, effect_sizes(ii), power);
end

plot(effect_sizes, ns, 'ko-')
xlabel('Effect sizes')
ylabel('n for 80% power')