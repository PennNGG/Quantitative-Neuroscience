% Power anaylysis Example from Button et al
%
% Python: https://github.com/PennNGG/Quantitative-Neuroscience/blob/master/Concepts/Python/Error%20Types%2C%20P-Values%2C%20False-Positive%20Risk%2C%20and%20Power%20Analysis.ipynb
%
% Copyright 2020 by Joshua I. Gold, University of Pennsylvania

% Write some code to play with the analysis shown in Fig. 1 of:
%  Button et al (2013), Power failure: why small sample size undermines 
%  the reliability of neuroscience, Nature Reviews Neuroscience.
%
% From the legend: 
%  Statistical power of a replication study. a | If a study finds evidence 
%  for an effect at p=0.05, then the difference between the mean of the 
%  null distribution (indicated by the solid blue curve) and the mean of 
%  the observed distribution (dashed blue curve) is 1.96×sem. b | Studies 
%  attempting to replicate an effect using the same sample size as that 
%  of the original study would have roughly the same sampling variation 
%  (that is, sem) as in the original study. Assuming, as one might in a 
%  power calculation, that the initially observed effect we are trying 
%  to replicate reflects the true effect, the potential distribution of 
%  these replication effect estimates would be similar to the distribution 
%  of the original study (dashed green curve). A study attempting to 
%  replicate a nominally significant effect (p~0.05), which uses the 
%  same sample size as the original study, would therefore have (on 
%  average) a 50% chance of rejecting the null hypothesis (indicated by 
%  the coloured area under the green curve) and thus only 50% statistical 
%  power. c | We can increase the power of the replication study (coloured 
%  area under the orange curve) by increasing the sample size so as to 
%  reduce the sem. Powering a replication study adequately (that is, 
%  achieving a power ?80%) therefore often requires a larger sample size 
%  than the original study, and a power calculation will help to decide 
%  the required size of the replication sample.

% Recreate the figure (mostly), with notes, simulations, and additions
figure

% Assume that an original study identified an effect size, representing
%  the difference in the mean value of a test distribution versus a 
%  null distribution, divided by their common standard deviation (i.e., 
%  the z-score of their difference), at exactly p=0.05. 
% Remember that these are distributions of mean values, so the standard
%  deviations of these distributions represent standard errors of the mean.
% For a two-tailed test, this p-value implies that 0.975 of the area of the null 
%  distribtion is less than the effect size:
effectSize = norminv(0.975);

% We can now reproduce the first panel:
subplot(4,1,1); cla reset; hold on;
mu0 = 0;
sem = 1; % make it easy by assuming sem=1
mu1 = effectSize.*sem;
binsz = 0.01;
xax = -4:binsz:6;
plot(mu0.*[1 1], [0 0.45], 'k-');
plot(mu1.*[1 1], [0 0.45], 'k-');
plot(xax, normpdf(xax, mu0, sem), 'b-');
plot(xax, normpdf(xax, mu1, sem), 'b--');
xlabel('value');
ylabel('probability');

% Now what happens when we try to replicate the result under the exact same
% conditions? Let's simulate N experiments:
N = 10000;

% In each simulated experiment, we end up with a mean value that comes from the
% experimental distribution, and we only reject the Null hypothesis if the
% value is greater than or equal to the previous effect size:
outcomes = normrnd(mu1, sem, N, 1);
LpositiveOutcomes = outcomes >= effectSize;
fprintf('%d positive outcomes out of %d experiments (%.2f pct)\n', ...
   sum(LpositiveOutcomes), N, sum(LpositiveOutcomes)/N*100)

% We can plot these results as a normalized histogram
subplot(4,1,2); cla reset; hold on;
edges = xax(1)-binsz/2:binsz:xax(end)+binsz/2;
Nall      = histcounts(outcomes, edges);
NnoEffect = histcounts(outcomes(~LpositiveOutcomes), edges);
Neffect   = histcounts(outcomes(LpositiveOutcomes), edges);
normalizer = trapz(xax, histcounts(outcomes, edges));

% h11=bar(xax, NnoEffect./(sum(NnoEffect)+sum(Neffect))./binsz);
h1=bar(xax, NnoEffect./normalizer);
set(h1, 'EdgeColor', [0.9 0.9 0.9])

% h2=bar(xax, Neffect./(sum(NnoEffect)+sum(Neffect))./binsz);
h2=bar(xax, Neffect./normalizer);
set(h2, 'EdgeColor', [0.1 0.1 0.1])

plot(mu0.*[1 1], [0 0.45], 'k-');
plot(mu1.*[1 1], [0 0.45], 'k-');
plot(xax, normpdf(xax, mu0, sem), 'b-');
plot(xax, normpdf(xax, mu1, sem), 'b--');
xlabel('value');
ylabel('probability');

% We can increase the power by increasing the signal-to-noise ratio (SNR) 
%  of our sample, via a reduction in sem and assuming the same mean effect 
%  size. The figure in the paper is confusing, because increasing SNR would 
%  narrow *both* distributions (because we assume that the two hypotheses
%  differ only by their mean value, not the STD of the distributions). It
%  is the change in both distributions that explains why you would be less 
%  likely to reject the Null hypothesis for the same effect size under
%  these conditions.
%  
% Also note that sem depends on both the number of samples (N) and the 
%  STD of the sampled distribution, so we need to define N or STD to be 
%  able to express sem in terms of the other of those two values.
%
% We can use a power analysis to find the new sem. The key point is that a
%  power analysis describes a relationship between the effect size and the
%  power -- so we can define a particular power to compute the effect size.
%  In this case, this is equivalent to doing a z test with one sample and a
%  power of 80%:
newEffectSize = sampsizepwr('z', [0 1], [], 0.8, 1);

% This effect size is again the z-score, given the existing mean difference
%  and the new sem -- so we can use it to compute the new sem (remember 
%  that the z-score is the difference in means divided by the common sem):
newSEM = (mu1-mu0)./newEffectSize;

% To show that this is the case, let's try a bunch of sems and find the
%  value that corresponds to when 80% of the effect distribution is >= 
%  the p=0.05 cutoff for the null distribution

% Try a bunch of sems, smaller than before (i.e., <1)
sems = 0:0.01:1;
vals = zeros(length(sems), 1);

% Loop through them
for ss = 1:length(sems)
   
   % The probability of not rejecting the null hypothesis when the null
   %  hypothesis is false is the mass of the effect distribution, which
   %  still has a mean value of effectSize but now has the given sem, that
   %  is to the right of the new cutoff    
   newCutoff = norminv(0.975, mu0, sems(ss));
   vals(ss) = 1-normcdf(newCutoff, effectSize, sems(ss)); 
end

% Plot it
subplot(4,1,3); cla reset; hold on;
plot(sems, vals, 'ko');
valIndex = find(vals<=0.8, 1);
newSEM2 = sems(valIndex);
plot(newSEM2.*[1 1], [0 0.8], 'r-', 'LineWidth', 2);
plot([0 newSEM2], [0.8 0.8], 'r-', 'LineWidth', 2);
plot(newSEM, 0.8, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 10);
xlabel('sem');
ylabel('probability true positive');

% Now do the simulated experiments as above, but with the new distributions
outcomes = normrnd(mu1, newSEM, N, 1);
LpositiveOutcomes = outcomes >=  norminv(0.975, mu0, newSEM);
fprintf('New sem=%.2f: %d positive outcomes out of %d experiments (%.2f pct)\n', ...
   newSEM, sum(LpositiveOutcomes), N, sum(LpositiveOutcomes)/N*100)

% Show it as normalized histograms
subplot(4,1,4); cla reset; hold on;
NnoEffect = hist(outcomes(~LpositiveOutcomes), xax);
Neffect   = hist(outcomes(LpositiveOutcomes), xax);
h1=bar(xax, NnoEffect./(sum(NnoEffect)+sum(Neffect))./binsz);
set(h1, 'EdgeColor', [0.9 0.9 0.9])
h2=bar(xax, Neffect./(sum(NnoEffect)+sum(Neffect))./binsz);
set(h2, 'EdgeColor', [0.1 0.1 0.1])
plot(mu0.*[1 1], [0 0.45], 'k-');
plot(mu1.*[1 1], [0 0.45], 'k-');
plot(xax, normpdf(xax, mu0, newSEM), 'b-');
plot(xax, normpdf(xax, mu1, newSEM), 'b--');
xlabel('value');
ylabel('probability');
