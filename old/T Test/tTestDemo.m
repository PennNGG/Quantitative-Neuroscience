% t-test demo
%
% Copyright 2020 by Joshua I. Gold

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
data_bins = -xax(1):data_bin_size:xax(end);

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
   counts = hist(samples(1,:), data_bins);
   bar(data_bins, counts./trapz(data_bins, counts));
   plot(xax, normpdf(xax, null_mu, null_std), 'r-', 'LineWidth', 2);
   plot(xax, normpdf(xax, test_mu, test_std), 'r--', 'LineWidth', 2);

   % set/label axes
   axis([-10 10 0 0.25]);
   set(gca, 'FontSize', 12);
   xlabel('data value (actual units)')
   ylabel('probability')      

   % Distributions of means
   subplot(4,1,3); cla reset; hold on;
   counts = hist(mean(samples,2), data_bins);
   bar(data_bins, counts./trapz(data_bins, counts));
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