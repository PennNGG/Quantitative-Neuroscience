%% Poisson distribution
%
% Colab: https://colab.research.google.com/drive/1kaJC9Xw6fPqiZYwMbA484F7PDwsFQenX?usp=sharing
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

% Make an animation comparing binomial and Poisson distributions
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