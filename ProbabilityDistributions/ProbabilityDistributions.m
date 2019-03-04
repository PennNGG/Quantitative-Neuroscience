% Probability distributions
%
% Copywrite 2019 by Joshua I. Gold, University of Pennsylvania

% open a figure that we will use to plot stuff
figure

%% Bernoulli distribution
%
% A single Bernoulli trial: 
%  outcome = 1 with probabilty p
%  outcome = 0 with probabilty 1-p

% Can use rand, which produces random variable on interval (0,1)
p = 0.7; % choose value for p
outcome = rand() <= p; % create logical variable from single pick

% Or, equivalently, use binornd -- a random pick from a binomial
%  distribution with n=1 (i.e., a Bernoulli distribution is a special
%  case of a binomial distribution with n=1)
p = 0.7; % choose value for p
n = 1;   % special case of just onea trial
outcome = binornd(n,p);

% Check that we are generating the probability correctly by generating a
% lot of trials and testing if the outcome is as expected.
N = 100000; % Generate a lot of trials
outcomes = zeros(N,1); % pre-allocate a big array
for ii = 1:N % loop through the trials
   outcomes(ii) = binornd(n,p);
end

% Print out the results
disp(sprintf('%d zeros, %d ones, empirical p = %.2f', ...
   sum(outcomes==0), sum(outcomes==1), sum(outcomes==1)/N))

%% Binomial distribution
%
% Distribution of the number of successes for a given number of Bernoulli
%  trials, defined by two parameters:
%  p = probability of success on each trial (constant across trials)
%  n = number of trials

% Choose some values
p = 0.7;
n = 100000;

% Generate random picks. Note that this is as if we did the Bernoulli
% trials as above, but then just counted the successes
outcome = binornd(n,p);

% Print out the results
disp(sprintf('%d successes, empirical p = %.2f', outcome, outcome/n))

% The full probability distribution describes the probabilty of obtaining
%  each possible number of successes (k), given n and p. If we set n=10,
%  the the possible values of k are 0, 1, ..., 10. Now we use binornd
%  to simulate many different picks to get a full distribution
p = 0.7;
n = 10;        % number of "trials" 
N = 10000;     % number of "simulations"
outcomes = binornd(n,p,N,1);

% Make histogram of all possible outcomes. We want bins centered on whole
% numbers so we offset the edges
edges = -0.5:10.5;
counts = histcounts(outcomes, edges);

% Show a bar plot
clf;
xs = edges(1:end-1)+diff(edges)/2;
bar(xs, counts);

% Normalize it to make it a pdf. Here counts (the x-axis of the histogram)
%  is a DISCRETE variable, so we just have to add up the values
bar(xs, counts./sum(counts));

% Compare it to the real binomial distribution, which we find using binopdf
Y = binopdf(xs,n,p);
hold on;
plot(xs,Y,'ro-', 'LineWidth', 2, 'MarkerSize', 10);

% Fun animation showing different values of p and N. Note that, of course,
% the more picks you make of the random variable (hihger N), the more
% closely the outcomes (the "samples") match the true distribution.
for p = 0.1:0.1:0.9
   for N = round(logspace(1,4,10))
      
      % Get the pdf
      Y = binopdf(xs,n,p);
      
      % Get the random picks
      outcomes = binornd(n,p,N,1);
      counts = histcounts(outcomes, edges);
      
      % Set up the plot
      cla reset; hold on;
      title(sprintf('p=%.1f, n=10, N=%d', p, N))
      axis([0 10 0 0.45])
      
      % Show both
      bar(xs, counts./sum(counts));
      plot(xs,Y,'ro-', 'LineWidth', 2, 'MarkerSize', 10);
      
      % Wait
      pause(0.1);
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
clf;
xs = edges(1:end-1)+diff(edges)/2;
bar(xs, cumsum(counts./sum(counts)));

% Compare it to the real binomial cumulative distribution, 
%  which we find using binocdf
Y = binocdf(xs,n,p);
hold on;
plot(xs,Y,'ro-', 'LineWidth', 2, 'MarkerSize', 10);

%% Poisson distribution
%
% The Poisson distribution is closely related to the binomial distribution.
% In both cases, they measure the number of "successes" (or binary events)
%  within a given interval. For the binomial distribution, these events
%  occur within discrete "attempts" (that is, within individaul Bernoulli
%  trials). For the Poisson distribution, these events can occur at any
%  time in the interval. Thus, the Poisson distribution describes the case
%  in which the intervals between Bernoulli trials -> zero (and p is
%  realtively small).

% Let's examine the relationship between the Poisson pdf and binomial pdf 
%  by introducing the concept of a Poisson point process (PPP). A PPP is 
%  a process that generates binary events at a constant rate lambda. The 
%  number of events that the PPP generates in a given interval is a random 
%  variable that is distributed as a Poisson pdf.

% The Poisson process is defined by a rate, lambda, of events/sec
lambda = 1;

% Consider a fixed interval
deltaT = 10; % in seconds

% Axis for histogram of counts
xaxis = 0:20;

% Loop through different numbers of bins
for n = round(linspace(1,100,10))
   
   % Use the binomial distribution to make random picks, as above
   %  Use a large N to get a meaningful sample size
   %  Scale p so that it is probability of events/bin, not events/sec   
   p = lambda * deltaT/n;
   outcomes = binornd(n, min(p,1), 10000, 1);
   [counts,edges] = histcounts(outcomes, [xaxis-0.5 xaxis(end)+0.5]); % use n+1 bins

   % Get the binomial pdf
   binoY = binopdf(xaxis, n, p);
      
   % Get the equivalent Poisson pdf using the rate computed for the full
   %  interval: lambda * deltaT
   poissY = poisspdf(xaxis, lambda*deltaT);
   
   % Set up the plot
   cla reset; hold on;
   title(sprintf('n=%d', n))
   axis([xaxis(1) xaxis(end) 0 max(poissY)+0.1])
   
   % Show both
   bar(xaxis, counts./sum(counts));
   plot(xaxis, binoY,  'ro-', 'LineWidth', 2, 'MarkerSize', 10);
   plot(xaxis, poissY, 'bo-', 'LineWidth', 2, 'MarkerSize', 10);

   pause(0.3);
end

% An interesting property of a Poisson distributon is that var = mean
% Let's try it using simulations

% Set up simulations using various values of lambda
nLambdas = 10;
lambdas = linspace(1,10,nLambdas);
N = 10000; % number of simulations per condition

% Set up plot, show main diagonal
cla reset; hold on;
axis([0 max(lambdas)+1 0 max(lambdas)+1]);
plot([0 0 max(lambdas)+1], [0 0 max(lambdas)+1], 'k:');

% cycle through different values of lambda
for ll=1:nLambdas
   
   % Get the counts
   counts = poissrnd(lambdas(ll), N, 1);
   
   % Plot var vs mean, with grayscale to indicate lambda
   plot(mean(counts), var(counts), 'ko', ...
      'MarkerSize', 15, 'MarkerFaceColor', ones(1,3).*ll/nLambdas);
end

% Let's go back to simulating a Poisson process as the limit of a sequence
% of Bernoulli trials as the interval->0. 
deltaT = 1000;   % Assume the whole process takes this long
lambda = 1;    % Rate (events per sec)
nBinsPerSecond = 100;  % Number of bins in which to check for events
totalBins = round(nBinsPerSecond*deltaT);

% Now simulate a different way... make an array of nBins filled with zeros,
% the loop through and in each bin check if the event happened or not
outcomes = zeros(totalBins, 1);

% Again convert lambda (overall rate) to probability/bin, using deltaT
%     events/time / bins/time = events/bin
p = lambda * deltaT / totalBins;

% Loop through the bins
for ii = 1:totalBins
   
   % Did it happen?
   outcomes(ii) = binornd(1,p);
end

% Check that the nubmer of events is what we expect
disp([lambda*deltaT sum(outcomes==1)])

% Now look at the histogram of intervals between events -- it's an
% exponential!

% Get intervals
intervalsBetweenEvents = diff(find(outcomes));

% Convert to seconds
intervalsBetweenEvents = intervalsBetweenEvents ./ nBinsPerSecond;

% Show the histogram
cla reset;
histogram(intervalsBetweenEvents, 50); 

%% Exponential distribution
%
% Compare the simulated exponential from above to the formal pdf
% mu (mean) of the pdf is the inverse rate
cla reset; hold on;

% Get the histogram
[N,X] = hist(intervalsBetweenEvents, 50);

% Here interval (the x-axis of the histogram) is a 
%  CONTINUOUS variable, so to normalize the histogram to make a pdf we
%  can't just sum the values -- we have to sum the values multiplied by the
%  bin width (i.e., take the integral). We use matlab's "trapz" which
%  treats each bin as a trapezoid (because the heights before and after can
%  be slightly different) to compute the integral
normalizedIntervals = N./trapz(X, N);
bar(X,normalizedIntervals);

% Plot the exponential pdf, with mean (mu) equal to 1/lambda
plot(X, exppdf(X, 1/lambda), 'ro-', 'MarkerSize', 10, 'LineWidth', 2);

% So here's a better way to simulate a Poisson process: instead of
% approximating continuous time with small time bins, directly simulate the
% time between events as an exponential
lambda = 2; % events/sec
mu = 1/lambda; 
M = 50000; % events/run
N = 1000; % number of runs

% Simulate a bunch of intervals picked from an exponential distribution
intervals = exprnd(mu, M, N);

% Sum them per run (columns) so the events correspond to timestamps
times = cumsum(intervals);

% A bit of a cheat -- find the run with the shortest time, then use that as
% the interval to test across runs
minTime = min(times(end,:));

% Count the times less than the min interval per run
counts = sum(times<=minTime)';

% Check mean, var
disp(sprintf('lambda*deltaT = %.2f, mean = %.2f, var = %.2f', ...
   lambda*minTime, mean(counts), var(counts)))

% Now let's consider the "Randomness" of this process in more detail.
% We say that it has a "flat hazard funtion": at any given point in time, 
%  there is an equal probabilty of the event occuring, given that it 
%  hasn't occurred yet. We can compute this from the simulated intervals 
%  as the pdf/(1-cdf):
xs = 0:0.01:mu*5;
hazards = zeros(size(intervals));
for ii = 1:N
   N = hist(intervals(intervals(:,N)<minTime, N), xs);
   cdf = cumtrapz(xs,N);
   hazards(1:length(cdf), N) = N./(1-cdf./max(cdf));
end

   
[N,EDGES] = histcounts(eventTimes, range);
cdf = cumtrapz(range(1:end-1)+diff(range)./2, N);
cdf = cdf./max(cdf);
hazard = N./(1-cdf);
