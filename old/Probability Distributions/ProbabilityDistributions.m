% Probability distributions
%
% To use this tutorial, read the commands and execute the code line-by-line.
%
% The learning objectives are to gain insights into:
%  - how to pseudo-randomly sample from probability distributions in Matlab
%     (typically *rnd commands; e.g., normrnd for a normal distribution)
%  - how to generate theoretical distributions in Matlab
%     (typically *pdf commands; e.g., normpdf for a normal distribution)
%  - characteristics of several specific distribuions:
%     Bernoulli
%     binomial
%     Poisson
%     exponential
%     normal (Gaussian)
%  - comparing probability distribution functions (pdfs) and 
%     cumulative distribution functions (cdfs)
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania
% Tested with:
%   MATLAB Version: 9.8.0.1323502 (R2020a)

% open a figure that we will use to plot stuff
figure

%% Bernoulli distribution
%
%  Canvas Discussion: https://canvas.upenn.edu/courses/1358934/discussion_topics/5121835
%  Wikipedia: https://en.wikipedia.org/wiki/Bernoulli_distribution
%  Mathworld: http://mathworld.wolfram.com/BernoulliDistribution.html
%
% A single Bernoulli trial: 
%  outcome = 1 with probabilty p
%  outcome = 0 with probabilty 1-p
% 
%  This is a DISCRETE distribution because by definition it only takes on
%  specific, discrete values (in this case either 0 or 1)

% We can use rand, which produces a random variable on the interval (0,1),
%  which means that all values are greater than 0 and less than 1
p = 0.7; % choose value for p
single_outcome_method_1 = rand() <= p; % create logical variable from single pick
fprintf('outcome using rand = %.2f\n', single_outcome_method_1)

% Or, equivalently, use binornd -- a random pick from a binomial
%  distribution with n=1 (i.e., a Bernoulli distribution is a special
%  case of a binomial distribution with n=1)
p = 0.7; % choose value for p
n = 1;   % special case of just one trial
single_outcome_method_2 = binornd(n,p);
fprintf('outcome using binornd = %.2f\n', single_outcome_method_2)

% Check that we are generating the probability correctly by generating a
% lot of trials and testing if the outcome is as expected.
N = 10000; % Generate a lot of trials
outcomes = zeros(N,1); % pre-allocate a big array
for ii = 1:N % loop through the trials
   outcomes(ii) = binornd(n,p);
end

% Print out the results
fprintf('%d zeros, %d ones, simulated p = %.2f, empirical p = %.2f\n', ...
   sum(outcomes==0), sum(outcomes==1), p, sum(outcomes==1)/N)

%% Binomial distribution
%
%  Canvas Discussion: https://canvas.upenn.edu/courses/1358934/discussion_topics/5002068
%  Wikipedia: https://en.wikipedia.org/wiki/Binomial_distribution
%  Mathworld: http://mathworld.wolfram.com/BinomialDistribution.html
%
% Distribution of the number of successful outcomes for a given number 
%  of Bernoulli trials in a given experiment, defined by two parameters:
%  p = probability of success on each trial (constant across trials)
%  n = number of trials
%
%  This is also a DISCRETE distribution because by definition it only 
%  takes on specific, discrete values (in this case non-negative integers 
%  corresponding to the number of successes in n tries; thus, values 0:n).

% Choose some values for the parameters n and p
p = 0.7;
n = 1000;

% Generate random picks. Note that this is as if we did the Bernoulli
% trials as above, but then just counted the successes
outcome = binornd(n,p);

% Print out the results
fprintf('%d successes out of %d trials, simulated p = %.2f, empirical p = %.2f\n', ...
   n, outcome, p, outcome/n))

% The full probability distribution describes the probabilty of obtaining
%  each possible number of successes (k), given n and p. If we set n=10,
%  the the possible values of k are 0, 1, ..., 10. Now we use binornd
%  to simulate many different picks to get a full distribution
p = 0.7;
n = 10;       % number of "trials" per "experiment"
NumExperiments = 1000;     % number of "experiments"
outcomes = binornd(n,p,NumExperiments,1);

% Make histogram of all possible outcomes. We want bins centered on whole
% numbers so we offset the edges
edges = -0.5:10.5;
counts = histcounts(outcomes, edges);

% Show a bar plot of the simulated bionimal distribution
clf;
xs = edges(1:end-1)+diff(edges)/2;
bar(xs, counts);
title(sprintf('Histogram of binomial distribution, n=%d, p=%.2f, N=%d simulations', ...
   n,p,N));
xlabel(sprintf('Number of successes in %d tries', n));
ylabel('Count');

% Normalize it to make it a pdf. Here counts (the x-axis of the histogram)
%  is a DISCRETE variable, so we just have to add up the values
bar(xs, counts./sum(counts));
title(sprintf('PDF of binomial distribution, n=%d, p=%.2f, N=%d simulations', ...
   n,p,N));
xlabel(sprintf('Number of successes in %d tries', n));
ylabel('Probability');

% Compare it to the real binomial distribution, which we find using binopdf
Y = binopdf(xs,n,p);
hold on;
plot(xs,Y,'ro-', 'LineWidth', 2, 'MarkerSize', 10);
legend('Simulated', 'Theoretical')

% Fun animation showing different values of p and N. Note that, of course,
% the more picks you make of the random variable (hihger N), the more
% closely the outcomes (the "samples") match the true distribution.
for p = 0.1:0.1:0.9
   for N = round(logspace(1,5,10))
      
      % Get the pdf
      Y = binopdf(xs,n,p);
      
      % Get the random picks
      outcomes = binornd(n,p,N,1);
      counts = histcounts(outcomes, edges);
      
      % Set up the plot
      cla reset; hold on;
      
      % Show both
      bar(xs, counts./sum(counts));
      plot(xs,Y,'ro-', 'LineWidth', 2, 'MarkerSize', 10);
      
      % Labels, etc
      title(sprintf('p=%.1f, n=10, N=%d', p, N))
      xlabel(sprintf('Number of successes in %d tries', n));
      ylabel('Probability');
      legend('Simulated', 'Theoretical')
      axis([0 10 0 0.45])
      
      % Wait
      pause(0.15);
   end
end

% The cumulative distribution function is just the proability of obtaining
% an outcome that is equal to OR LESS THAN a particular value.
p = 0.7;
n = 10;        % number of "trials" 
N = 10000;     % number of "simulations"
outcomes = binornd(n,p,N,1);

% Make histogram of all possible outcomes. We want bins centered on whole
% numbers so we offset the edges
edges = -0.5:10.5;
counts = histcounts(outcomes, edges);

% Show a bar plot of the cdf (the cumulative sum of the normalized counts)
% Clear the figure
clf;
% Set up the x axis based on the edges
xs = edges(1:end-1)+diff(edges)/2;
% Compute the cumulative sum of the counts normalized by the total counts
%  (so it is a probability function and not just a histogram -- note that
%  the final value in the cdf should equal 1 because every value should be
%  equal to or less than that value).
scounts = cumsum(counts./sum(counts));
bar(xs, scounts);

% Compare it to the real binomial cumulative distribution, 
%  which we find using binocdf
Y = binocdf(xs,n,p);
hold on;
plot(xs,Y,'ro-', 'LineWidth', 2, 'MarkerSize', 10);

% Labels, etc
title(sprintf('Cumulative binomial distribution, p=%.1f, n=%d, N=%d', p, n, N))
xlabel(sprintf('Number of successes in %d tries', n));
ylabel('Cumulative probability');
legend('Simulated', 'Theoretical')

%% Poisson distribution
%
%  Canvas Discussion: https://canvas.upenn.edu/courses/1358934/discussion_topics/5130868
%  Wikipedia: https://en.wikipedia.org/wiki/Poisson_distribution
%  Mathworld: http://mathworld.wolfram.com/PoissonDistribution.html
%
% The Poisson distribution is closely related to the binomial distribution.
% In both cases, they measure the number of "successes" (or binary events)
%  within a given interval. For the binomial distribution, these events
%  occur within discrete "attempts" (that is, within individaul Bernoulli
%  trials) that we assume occur at regularly spaced times throughout the
%  full interval. For the Poisson distribution, these events can occur at any
%  time in the interval. Thus, the Poisson distribution describes the case
%  in which the time between Bernoulli "attempts" or trials -> zero (the 
%  "->" reads as "approaches"). This is equivalent to saying that the number
%  of attempts approaces infinity. 
%
% This is a CONTINUOUS distribution because it describes the probability of
%  any possible time of an event occurring within the given interval.

% Let's examine the relationship between the Poisson pdf and binomial pdf 
%  by introducing the concept of a Poisson point process (PPP). A PPP is 
%  a process that generates binary events at a constant RATE lambda. The
%  key here is that time is contininuous, so probability cannot be
%  determined with respect to a fixed time but rather a fixed time
%  interval (because any fixed time is infinitesimally small). 
%  Thus, we think of events occuring at some rate (mean number of
%  events per unit time) as opposed to a probability (probability of
%  occurrance of the event at a given time).
%  The number of events that the PPP generates in a given interval is a random 
%  variable that is distributed as a Poisson pdf (i.e., a PPP is a way of 
%  generating a Poisson PDF).
%
% See: https://en.wikipedia.org/wiki/Poisson_point_process

% The Poisson process is defined by a rate, lambda, of events/sec
lambda = 1;

% We will consider events generated in a given fixed interval, in seconds.
deltaT = 10;

% Define an axis for computing and plotting a histogram of counts
xaxis = 0:20;

% Number of simulations
num_simulations= 1000;

% Loop through different numbers of time bins used to divide up the given
%  interval. Remember this is how we will show the transition from a 
%  binomial to a Poisson pdf describing the number of events in the
%  interval: as the number of bins gets larger, the simulation gets closer
%  to considering events occurring at any time and thus the distribution
%  gets closer to Poisson
for n = round(linspace(1,100,20))
   
   % Set up the plot
   cla reset; hold on;
   
   % Check for events in each bin
   %
   %  Scale p so that it is probability of events/bin, not events/sec -- 
   %     which can be at most =1.
   p = min(lambda * deltaT/n, 1);
   
   % Simulate outcomes as the number of events that occurred in the n bins
   %  ("tries"), given p and done num_simulations times.
   outcomes = binornd(n, p, num_simulations, 1);
   
   % Make a histogram of the outcomes, using the array of counts ("xaxis")
   %  we defined above. Note that we shift xaxis and add another interval
   %  to the end because histcounts operates on edges of intervals
   counts = histcounts(outcomes, [xaxis-0.5 xaxis(end)+0.5]);

   % Show a bar plot of the simulated PDF (i.e., the histogram divided
   %  by the sum of the counts to get probabilities)
   bar(xaxis, counts./sum(counts));

   % Plot the theoretical binomial pdf, for the values in xaxis and given
   %  n and p.
   binoY = binopdf(xaxis, n, p);
   
   % Show in RED
   plot(xaxis, binoY,  'ro-', 'LineWidth', 2, 'MarkerSize', 10);
      
   % Get the equivalent Poisson pdf using the rate computed for the full
   %  interval: lambda * deltaT
   poissY = poisspdf(xaxis, lambda*deltaT);
   
   % Show in BLUE
   plot(xaxis, poissY, 'bo-', 'LineWidth', 2, 'MarkerSize', 10);

   % Labels, etc
   axis([xaxis(1) xaxis(end) 0 max(poissY)+0.1])
   title(sprintf('p=%.1f, number bins=%d, number simulations=%d', ...
      p, n, num_simulations))
   xlabel('Number of successes');
   ylabel('Probability');
   legend('Simulated', 'Theoretical binomial', 'Theoretical Poisson')

   r = input('Press <return> to continue')
end

% An interesting property of a Poisson distributon is that var = mean
% Let's try it using simulations

% Set up simulations using various values of lambda
nLambdas = 10;
lambdas = linspace(1,10,nLambdas);
N = 10000; % number of simulations per condition

% Set up plot
cla reset; hold on;
axis([0 max(lambdas)+1 0 max(lambdas)+1]);

% Show main diagonal
plot([0 max(lambdas)+1], [0 max(lambdas)+1], 'k:');

% Show labels
xlabel('Mean of counts');
ylabel('Variance of counts');
title('Variance vs mean count from Poisson distribution, different rates')

% cycle through different values of lambda
for ll=1:nLambdas
   
   % Get the counts
   counts = poissrnd(lambdas(ll), N, 1);
   
   % Plot var vs mean, with grayscale to indicate lambda
   plot(mean(counts), var(counts), 'ko', ...
      'MarkerSize', 15, 'MarkerFaceColor', ones(1,3).*ll/nLambdas);
end

% Show legend for grayscale values = different rates (lambdas)
strs = cellstr(num2str(lambdas'));
legend('', strs{:});

%%%
%
% Let's go back to simulating a Poisson process as the limit of a sequence
% of Bernoulli trials as the interval size->0. 
deltaT = 1000;   % Assume the whole process takes this long
lambda = 1;    % Rate (events per sec)
nBinsPerSecond = 100;  % Number of bins in which to check for events
totalBins = round(nBinsPerSecond*deltaT);

% First convert lambda (overall rate) to probability/bin, using deltaT
%     events/time divided by bins/time = events/bin, as before
p = lambda * deltaT / totalBins;

% Now simulate checking one "outcome" per bin, using the given
% probability/bin
outcomes = binornd(1, p, totalBins, 1);

% Check that the nubmer of events is what we expect
disp([lambda*deltaT sum(outcomes==1)])

% Now for the next part -- instead of looking at the counts per interval,
%  which is what the Poisson distribution described, we are now going to
%  look at the same data but are considering the intervals between events.
%  As you will see below, these intervals are distributed as an
%  exponential.
%
% First look at the histogram of intervals between events
% Get intervals
intervalsBetweenEvents = diff(find(outcomes));

% Convert to seconds
intervalsBetweenEventsSec = intervalsBetweenEvents ./ nBinsPerSecond;

% Show the histogram -- it's an exponential distribution!
cla reset;
histogram(intervalsBetweenEventsSec, 50); 
title('Histogram of intervals between events in a Poisson process')
xlabel('Interval duration (sec)');
ylabel('Count')

%% Exponential distribution
%
%  Canvas: https://canvas.upenn.edu/courses/1358934/discussion_topics/5130869
%  Wikipedia: https://en.wikipedia.org/wiki/Exponential_distribution
%  Mathworks: http://mathworld.wolfram.com/ExponentialDistribution.html
%
% This distribution describes the frequency of occurrence of CONTINUOUS
%  events that decays exponentially with larger values.

% Start by comparing the simulated exponential from above to the formal pdf
% mu (mean) of the exponential pdf is the inverse of the Poisson rate
cla reset; hold on;

% Get the histogram
[N,X] = hist(intervalsBetweenEvents, 50);

% Here the interval is a continuous variable (note that the x-axis is 
%   binned in the histogram to visualize it, but the actual values can 
%   take on any continuous value because they represent the amount of 
%   time since the previous event), so to normalize the histogram to make a pdf we
%   can't just sum the values -- we have to sum the values multiplied by the
%   bin width (i.e., take the integral). We use matlab's "trapz" which
%   treats each bin as a trapezoid (because the heights before and after can
%   be slightly different) to compute the integral:
normalizedIntervals = N./trapz(X, N);
bar(X,normalizedIntervals);

% Plot the exponential pdf, with mean (mu) equal to 1/lambda
plot(X, exppdf(X, 1/lambda), 'ro-', 'MarkerSize', 10, 'LineWidth', 2);

% Labels, etc
title('Exponential probability distribution = distribution of intervals between events in a Poisson process')
xlabel('Interval duration (sec)');
ylabel('Probability')
legend('Simulated', 'Theoretical')

%%%
%
% Here's a better way to simulate a Poisson process: instead of
% approximating continuous time with small time bins, directly simulate the
% (continuous) time between events as an exponential
lambda = 2; % events/sec
M = 5000; % events/run
N = 1000; % number of runs

% The mean of the (exponential) distribution of intervals between events
%  generated by a Poisson process is equal to the inverse of the rate at 
%  which the events are generated (because time/event is the inverse of
%  events/time)
mu = 1/lambda; 

% Simulate a bunch of intervals picked from an exponential distribution
intervals = exprnd(mu, M, N);

% Sum them per run (columns) so the events correspond to timestamps
times = cumsum(intervals);

% A bit of a cheat -- find the run with the shortest time, then use that as
% the interval to test across runs
minTime = min(times(end,:));
fprintf('min_time = %.2f\n', minTime)

% Count the times less than the min interval per run
counts = sum(times<=minTime)';

% Check mean, var (for a simulated Posson process, the mean and var should
% be pretty close to each other -- where "pretty close" is going to depend
% on factors like N and M)
fprintf('lambda*deltaT = %.2f, mean = %.2f, var = %.2f\n', ...
   lambda*minTime, mean(counts), var(counts))

% Now let's consider the "Randomness" of this process in more detail.
% We say that it has a "flat hazard function": at any given point in time, 
%  there is an equal probabilty of the event occuring, given that it 
%  hasn't occurred yet. We can compute this function from the simulated 
%  intervals as the pdf/(1-cdf) [that is, the probability of a given 
%  interval, defined as the pdf, divided by 1 - the probablity that the
%  given interval occurred]:

% Compute over this range. See below for an explanation of what the upper
% range (here scaled by rangeScale) does to the calcluation.
rangeScale = 10;
xs = 0:0.01:mu*rangeScale;

% Compute separately per run, will store in this matrix
hazards = zeros(length(xs), N);

% Loop through the runs
for ii = 1:N
   
   % Get the histogram of intervals using bins defined by "xs"
   counts = hist(intervals(intervals(:,ii)<minTime, ii), xs);
   
   % Convert into a pdf, using trapz because the intervals are continuous
   pdf = counts./trapz(xs, counts);

   % Compute the cdf -- again using trapz 
   cdf = cumtrapz(xs, pdf);
   
   % Save the hazard
   hazards(:,ii) = pdf./(1-cdf);
end

% Show the mean hazard across runs. Notice that: 
%  1. it is roughly constant and equal to 2 --- which is the rate (lambda) 
%     that we started with above (and the inverse of the mean of the 
%     exponential distribution of intervals that we generated).
%  2. The mean is noisy, especially for long intervals (large values
%     along the x-axis) - this is because those intervals don't happen very
%     much (the long tail of the exponential distribution) so even with
%     large N those points are undesampled.
%  3. For very large intervals, the results are not just noisy, but biased
%     (the hazard rate starts to sweep upwards on the right of the figure).
%     This is because the true exponential has a tail that goes to
%     infinity, but here we stop it at some finite time. This procedure
%     implies that events that in a real Poisson process (with a real flat
%     hazard) would occur after a very long interval will be counted here as
%     bunching up in the longest bins we check -- so the probability of
%     occurrance in those bins will be slighly higher than expected for a
%     real exponential, making the hazard rate larger, too. You can make
%     this effect more pronounced by choosing a shorter range of xs, above.
cla reset;
plot(xs, mean(hazards,2))
xlabel('Time from prior event (sec)')
ylabel('Hazard rate of event occurring')

%% Normal (Gaussian) distribution
%
% Canvas: https://canvas.upenn.edu/courses/1358934/discussion_topics/5121851
% Wikipedia: https://en.wikipedia.org/wiki/Normal_distribution
% Mathworks: http://mathworld.wolfram.com/GaussianFunction.html
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
