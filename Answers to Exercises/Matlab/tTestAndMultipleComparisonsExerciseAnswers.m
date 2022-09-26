% T-Test and Multiple comparisons
%  Answers to Exercise found here:
%
%  https://github.com/PennNGG/Quantitative-Neuroscience/blob/master/Concepts/Python/Multiple%20Comparisons.ipynb

%% Exercise: 
% In this exercise we will run through an example of correcting for 
%   multiple comparisons with both the Benjamini-Hochberg procedure and 
%   the more conservative Bonferroni correction. 

%% First, simulate multiple (say, 1000) t-tests comparing two samples 
%   with equal means and standard deviations, and save the p-values. 
%   Obviously, at p<0.05 we expect that ~5% of the simulations to yield 
%   a "statistically significant" result (of rejecting the NULL hypothesis 
%   that the samples come from distributions with equal means).

% determine how many comparisons (feel free to change this up and see what happens)
N_tests = 1000;

% Set sample parameters
% Sample 1
mu_1 = 1;
sigma_1 = 2;
N_1 = 100;

% sample 2 
mu_2 = mu_1;
sigma_2 = sigma_1;
N_2 = N_1;

p_values = nan.*zeros(N_tests, 1); % initialize an empty array where we will store our p-values
% Loop through the comparisons
for ii = 1:N_tests
  sample_1 = normrnd(mu_1, sigma_1, N_1, 1); % generate sample 1
  sample_2 = normrnd(mu_2, sigma_2, N_2, 1); % generate sample 2

  % Use Matlab's ttest2 (2 independent samples)
  [~, p_values(ii)] = ttest2(sample_1, sample_2);
end

alpha = 0.05;
fprintf('Found %d out of %d at p<%0.2f\n', sum(p_values<alpha), N_tests, alpha)

%% Second, once you have the simulated p-values, apply both methods to 
%   address the multiple comparisons problem.

% Bonferroni: simply divide alpha by the number of comparisons
num_bonferroni_corrected = sum(p_values<(alpha/N_tests));

% BH: 
%   1. Rank the individual p-values in ascending order, labeled i=1...n
sorted_ps = sort(p_values);

%   2. For each p-value, calculate its "critical value" as:
%       (i/n)Q, where i is the rank, n is the total number of tests, and 
%       Q is the false discovery rate (a percentage) that you choose (typically 0.05).
Q = 0.05;
CVS = (1:N_tests)'./N_tests.*Q;

%   3. In your rank-ordered, original p-values, find the largest value 
%   that is smaller than its associated critical value; this p-value 
%   is the new criterion (i.e., reject H_0 for all cases for which p≤this value).
new_criterion = sorted_ps(find(sorted_ps<CVS,1,'last'));
if isempty(new_criterion)
    num_bh_corrected = 0;
else
    num_bh_corrected = sum(p_values<new_criterion);
end

fprintf('Before correction, %d trials were deemed significant. After B&H correction, %d trials were deemed significant. After Bonferroni correction, %d trials were deemed significant.\n', ...
    sum(p_values<alpha), num_bh_corrected, num_bonferroni_corrected);

%% Third, set the sample 1 and sample 2 means to be 1 and 2 respectively, 
%   and re-run the exercise. What do you notice? What if you make the 
%   difference between means even greater?

% Answer: Bonferroni is much more conservative (rejects many more true positives)
