% t-test demo
%
% Here is a demo showing how the t-distribution evolves in a simple 
%   experiment as the sample size increases, when we have Gaussian-
%   distributed data and want to use a one-sample t-test to determine 
%   if we can reject the Null hypothesis that the mean of the test 
%   distribution equals zero.
%
% Run the full block of code below to generate an animation, 
%   with four panels (listed bottom-to-top):
%
% 1. The data-generating process: The dashed red curve shows the true 
%   generating process, which is a Gaussian distribution with mean=1, 
%   std=3. Data from one "experiment" are shown as a normalized histogram 
%   (blue bars) for each *n*. For comparison, the Null distribution 
%   (mean=0, std=3) is shown as the solid red curve. 
%
% 2. The distribution of means across many (now set to 10000) experiments: 
%   The dashed red curve shows the true distribution of means from the 
%   true data-generating process, with mean=1 and a standard error of the 
%   mean that decreases with increasing *n*. The distribution of means 
%   from the simulated experiments are shown as a normalized histogram 
%   (bars). For comparison, the distribution of means from the Null 
%   distribution is shown as the solid red curve. 
%
% 3. The test statistic is the t-statistic, which we compute for each 
%   experiment using the equation shown above. The bars are a normalized 
%   histogram of this statistic across the simulated experiments. The 
%   dashed red line is the expected distribution of this statistic, 
%   given our (known) data-generating process. The solid red line is 
%   the expected distribution of the t-statistic if the Null hypothesis 
%   were true. The solid green line is the standard normal distribution 
%   (mean=0, std=1) -- note that the Null distribution quickly approaches 
%   the standard normal distribution as *n* increases. The vertical bar 
%   is the point at which 0.025 of the Null distribution is to the left 
%   of that point; i.e., the value of the test statistic that would 
%   correspond to (two-tailed) *p*=0.05.
%
% 4. The probability of a "hit" (using a one-sample t-test to reject 
%   the null hypothesis when it should be rejected) as a function of 
%   the number of samples in each experiment.
%
% Copyright 2020 by Joshua I. Gold, University of Pennsylvania

%% Define a test distribution with a population mean different than 0
%  and a std of >1
%
test_mu  = 1;
test_std = 3;

% Null distribution
null_mu  = 0;
null_std = test_std;

% Max n
max_n = 100;

% Define an x-axis to show distributions
xax = -10:0.01:10;

% for histograms
data_bin_size = 0.1;
data_bins = xax(1):data_bin_size:xax(end);
trapz_spacing = data_bins(1:end-1)+data_bin_size/2;

% for simulations 
num_experiments = 100000;

% Set up top plot
subplot(4,1,1); cla reset; hold on;
set(gca, 'FontSize', 12);
axis([0 max_n 0 1]);
xlabel('n')
ylabel('p(hit)')

%% Simulate differemt sample sizes
for n = 2:max_n
   
   % Simulate multiple experiments
   samples = normrnd(test_mu, test_std, num_experiments, n);
   
   % Compute the t-statistic from each experiment
   tstats = mean(samples,2)./std(samples,[],2).*sqrt(n);
   
   % bottom plot is null, test distributions
   % Show one 'experiment'
   subplot(4,1,4); cla reset; hold on;   
   counts = histcounts(samples(1,:), data_bins);
   bar(trapz_spacing, counts./trapz(trapz_spacing, counts), 'k');
   plot(xax, normpdf(xax, null_mu, null_std), 'r-', 'LineWidth', 2);
   plot(xax, normpdf(xax, test_mu, test_std), 'r--', 'LineWidth', 2);

   % set/label axes
   axis([-10 10 0 0.25]);
   set(gca, 'FontSize', 12);
   xlabel('data value (actual units)')
   ylabel('probability')      

   % Distributions of means
   subplot(4,1,3); cla reset; hold on;
   counts = histcounts(mean(samples,2), data_bins);
   bar(trapz_spacing, counts./trapz(trapz_spacing, counts));
   plot(xax, normpdf(xax, null_mu, null_std./sqrt(n)), 'r-', 'LineWidth', 2)
   plot(xax, normpdf(xax, test_mu, test_std./sqrt(n)), 'r--', 'LineWidth', 2)
   
   % set/label axes
   axis([-10 10 0 1.5]);
   set(gca, 'FontSize', 12);
   xlabel('mean value (actual units)')
   ylabel('probability')      

   % next plot normal, t distributions of mean, and samples
   subplot(4,1,2); cla reset; hold on;
   counts = hist(tstats, xax);
   bar(xax, counts./trapz(xax, counts));
   plot(xax, tpdf(xax, n-1), 'r-', 'LineWidth', 2);
   plot(xax, tpdf(xax-test_mu/test_std*sqrt(n), n-1), 'r--', 'LineWidth', 2);
   plot(xax, normpdf(xax, 0, 1), 'g-', 'LineWidth', 2);
   plot(tinv(0.975, n-1).*[1 1], [0 0.5], 'm-', 'LineWidth', 4);
   
   % set/label axes
   axis([-4 4 0 0.5]);
   set(gca, 'FontSize', 12);
   xlabel('Value (t units)')
   ylabel('probability')

   subplot(4,1,1);
   plot(n, sum(tstats>tinv(0.975, n-1))./num_experiments, 'k.', 'MarkerSize', 8)
   title(sprintf('n=%d, mean(sigma)=%.2f', n, mean(std(samples,[],2))));
   pause(0.1);
end