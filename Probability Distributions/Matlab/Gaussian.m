%% Normal (Gaussian) distribution
%
% Colab: https://colab.research.google.com/drive/1-KxH3FCq5rDyyO33HXxewIv-kKldkINi#scrollTo=Z32Do1n-bkQ9
%
% This is another CONTINOUS distribution that describes the relative 
%  frequencies of occurrence of continuous values following a bell-shaped
%  curve.
%  
% Let's compare simulated and theoretical Gaussians
mu = 5;
sigma = 10;
N = 10000;

% Get samples
samples = normrnd(mu, sigma, N, 1);

% plot histogram, pick number of bins
cla reset; hold on;
nbins = 100;
[counts, edges] = histcounts(samples, nbins);
xaxis = edges(1:end-1)+diff(edges);
npdf = counts./trapz(xaxis, counts);
bar(xaxis, npdf);

% Show theoretical pdf in red
plot(xaxis, normpdf(xaxis, mu, sigma), 'r-', 'LineWidth', 2);

% labels, ets
title(sprintf('Gaussian pdf, mu=%.2f, sigma=%.2f', mu, sigma))
xlabel('Value');
ylabel('Probability');
legend('Simulated', 'Theoretical')

% Some summary statistics
% 1. The sample mean
disp(mean(samples))

% 2. The expected value of the empirical distribution: the sum of 
%     probability x value per bin. This should be similar to the sample 
%     mean, but recognize that we lost some information from the binning
%     (i.e., use more bins and this should get closer to the sample mean)
disp(sum(xaxis.*diff(edges).*npdf))

% 3. The expected value of the theoretical distribution
disp(sum(xaxis.*diff(edges).*normpdf(xaxis, mu, sigma)))

% Now standardize ("z-score") the samples by subtracting the mean and 
%  dividing by the STD
% The harder way
zSamples = (samples-mean(samples))./std(samples);

% The easier way
z2Samples = zscore(samples);

% Check that they are the same
disp(unique(zSamples-z2Samples))

% Show the distribution of z-scored values
cla reset; hold on;
nbins = 500;
[counts, edges] = histcounts(zSamples, nbins);
xaxis = edges(1:end-1)+diff(edges);
npdf = counts./trapz(xaxis, counts);
bar(xaxis, npdf);

% This is the "standard normal" pdf with mean=0, std=var=1
npdf = normpdf(xaxis);
plot(xaxis, npdf, 'r-', 'LineWidth', 2);

% labels, ets
title(sprintf('Gaussian pdf, mu=%.2f, sigma=%.2f', ...
   mean(zSamples), std(zSamples)))
xlabel('Value');
ylabel('Probability');
legend('Simulated', 'Theoretical')

%%%
%
% How much of the distribution is within 1,2,3+ standard deviations (also
% called z-scores)? Here it's easy to tell after we standardized the
% distribution
stds = (1:6)';

% Will compute in several ways (here we are just preallocating arrays to 
%  store the data, the columns are the different calculations): 
%  1. From the sampled distribution
%  2. From the (sampled) theoretical distribution
%  3. From the real theoretical distribution
pcts = zeros(length(stds), 3);

% Loop through and compute for each std
for ss = 1:length(stds)
   
   % 1. From the sampled distribution (compute as pct)
   pcts(ss,1) = 100.*sum(abs(zSamples) <= stds(ss))./length(zSamples);
   
   %  2. From the (sampled) theoretical distribution using trapz
   Lz = xaxis>=-stds(ss) & xaxis<=stds(ss); % Logical array to take only samples within given std
   pcts(ss, 2) = 100.*trapz(xaxis(Lz), npdf(Lz));
   
   %  3. From the real theoretical distribution: use the Gaussian 
   %     cumulative probability density function at z (i.e., at the 
   %     given std in the standardized normal). So 1-cdf is the integral 
   %     of the tail. We want the integral of the pdf minus the integral 
   %     of both tails:
   pcts(ss, 3) = 100.*(1-2.*(1-normcdf(stds(ss))));
end

% Show all
disp([stds pcts])

%%%
%
% Some other useful properties of Gaussians

% Get samples
mu = 5;
sigma = 10;
N = 10000;
samples = normrnd(mu, sigma, N, 1);

fprintf('mean=%.2f, std=%.2f, var=%.2f\n', ...
   mean(samples), std(samples), var(samples))

% 1. Add a constant changes the mean, not the std
offset = 20;
fprintf('mean=%.2f, std=%.2f, var=%.2f\n', ...
   mean(samples+offset), std(samples+offset), var(samples+offset))

% 2. Multiply by a constant scales the mean by that amount, the variance by
%     that amount squared
scale = 7;
fprintf('mean=%.2f, std=%.2f, var=%.2f\n', ...
   mean(samples*scale), std(samples*scale), var(samples*scale))

% 3. Adding two Gaussian random variables gives you a gaussian random 
%     variable with:
%        mean = sum of the two means
%        variance = sum of the two variances
mu2 = 5;
sigma2 = 10;

samples2 = normrnd(mu2, sigma2, N, 1);
fprintf('mean2=%.2f, std2=%.2f, var2=%.2f\n', ...
   mean(samples+samples2), std(samples+samples2), var(samples+samples2)))
