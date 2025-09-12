
%% Binomial distribution
% 
%  Answers to exercises found here:
%
%  https://github.com/PennNGG/Quantitative-Neuroscience/blob/master/Probability%20Distributions/Python/Binomial.ipynb
%
%  Created 09/21/18
%  Updated 12/31/19

%% Exercise 1
% Note that omitting the semicolon at the end of a line causes the output
% to be shown in the Command Window.
n = 10;                       % Number of available quanta
pRelease = 0.2;               % Release probabilty 
k = 0:10;                     % Possible values of k (measured events)
probs = binopdf(k,n,pRelease) % Array of probabilities of obtaining those values of k, given n and prelease

%% Exercise 2
n = 14;                       % Number of available quanta
k = 8;                        % Measured number of released quanta
prob1  = binopdf(k,n,0.1)     % Probabilty of obtaining k if release p = 0.1
prob2  = binopdf(k,n,0.2)     % Probabilty of obtaining k if release p = 0.2
prob3  = binopdf(k,n,0.3)     % Probabilty of obtaining k if release p = 0.3
prob4  = binopdf(k,n,0.4)     % Probabilty of obtaining k if release p = 0.4
prob5  = binopdf(k,n,0.5)     % Probabilty of obtaining k if release p = 0.5
prob6  = binopdf(k,n,0.6)     % Probabilty of obtaining k if release p = 0.6 ** MOST LIKELY
prob7  = binopdf(k,n,0.7)     % Probabilty of obtaining k if release p = 0.7
prob8  = binopdf(k,n,0.8)     % Probabilty of obtaining k if release p = 0.8
prob9  = binopdf(k,n,0.9)     % Probabilty of obtaining k if release p = 0.9
prob10 = binopdf(k,n,1.0)     % Probabilty of obtaining k if release p = 1.0

%% Exercise 3
% Likelihood and log-likelihood for sample size = 2, assumed pRelease=0.1
n1 = 14;                      % Number of available quanta, experiment 1
n2 = 14;                      % Number of available quanta, experiment 2
k1 = 8;                       % Measured number of released experiment 1
k2 = 5;                       % Measured number of released experiment 2
pRelease = 0.1;               % Assumed probability of release
prob1 = binopdf(k1,n1,pRelease) % Probabilty of obtaining data 1 (k1) given n1, prelease
prob2 = binopdf(k2,n2,pRelease) % Probabilty of obtaining data 2 (k2) given n2, prelease
totalProb = prob1 * prob2     % Assume independence and compute product
totalLogProb = log(prob1) + log(prob2) % Assume independence and compute sum

% likelihood and log-likelihood functions for sample size = 2
ps = (0:0.01:1.0)';           % Array of possible release probabilities -- compute
                              % at a resolution of 0.01
nps = length(ps);             % Get length of array of values of p

probs = binopdf( ....         % Get value of the binomial distribution for each
   repmat([k1 k2], nps, 1), ...  % combination of k, n, p. The output is a matrix
   repmat([n1 n2], nps, 1), ...  % with two columns: 1) n1, k1  2) n2, k2
   repmat(ps, 1, 2));            % rows are different values of p

% The likelihood function is the product of likelihoods (assuming
% independence)
subplot(2,1,1); cla reset; hold on;
ylabel('Likelihood');
likelihoodFcn = prod(probs,2);   % Compute the product for each row 
plot(ps, likelihoodFcn);         % Plot it
maxLikelihood = max(likelihoodFcn); % Get the maximum likelihood
plot(ps(likelihoodFcn==maxLikelihood), maxLikelihood, 'ko');

% The log-likelihood function is the sum of log-likelihoods (assuming
% independence)
subplot(2,1,2); cla reset; hold on;
ylabel('Log-likelihood');
logLikelihoodFcn = sum(log(probs),2); % Compute the sum for each row
plot(ps, logLikelihoodFcn);      % Plot it
maxLogLikelihood = max(logLikelihoodFcn); % Get the maximum likelihood
plot(ps(logLikelihoodFcn==maxLogLikelihood), maxLogLikelihood, 'ko');

% Likelihood and log-likelihood functions for different sample sizes.
%
% The code below will produce three plots that will update automatically 
%  for different sample sizes. You should see that as sample size increases, 
%  the ability to estimate the true value of the probability of release 
%  increases. You will also see an advantage of using log-likelihood over 
%  likelihood: as the number of samples increases, the total likelihood 
%  (the product of the likeilihoods associated with each measurement in 
%  the sample) eventually disappears, because Matlab can't handle the 
%  really small numbers (note that as the sample size increases, the 
%  number of all possible experimental outcomes you could measure gets 
%  really, really big, so the total likelihood of any GIVEN outcome gets 
%  really, really small). The three plots are:
%
%  TOP: normalized histogram of simulated experimental outcomes (i.e.,
%  simulated values of k for the given release probability and sample
%  size), along with the theoretical binomial distribution
%
%  MIDDLE: likelihood function, p(simulated data | pRelease)
%  Also shown are the maximum likelihood (peak of the likelihood function)
%  determined directly from the plotted likelihood function plus the value
%  (and 95% confidence intervals) computed using Matlab's "binofit" function
%  fit to the simulated data, plus the value of pRelease used in the
%  simulations.
% 
%  BOTTOM: Same as in the middle panel, but using the log-likelihood
%  function
%
n = 14;                       % number of available quanta
pRelease = 0.3;               % assumed probability of release
ks = 0:n;                     % possible values of k
ps = 0:0.01:1.0;              % possible release probabilities
pdat = zeros(length(ps), 2);  % pre-allocate matrix to hold likelihoods per p
TINY = 0.0001;                % to avoid multiplying/taking logs of really small numbers
for sampleSize = round(logspace(0,3,30))  % try different sample sizes
   
   % Simulate experiments -- get simulated counts for the given n,
   % pRelease, and number of experiments
   sCounts = binornd(n,pRelease,sampleSize,1);
   
   % Plot experiment, theoretical binomial pdf
   subplot(3,1,1); cla reset; hold on;
   title(sprintf('Sample size = %d', sampleSize))
   ylabel('Probability');
   xlabel('Release count');
   xlim([ks(1) ks(end)]);
   
   % Plot normalized histogram of simulated counts
   sCountHistogram = hist(sCounts, ks);
   bar(ks, sCountHistogram./sum(sCountHistogram));
   
   % Plot theoretical pdf
   plot(ks, binopdf(ks, n, pRelease), 'ro-');
   
   % Now compute the (log) likelihoods, which are just the probability of
   % obtaining the (simulated) data (i.e., counts) under different
   % "hypotheses" corresponding to the different release probabilities
   % Therefore, we loop through each possible value of release probability
   for pp = 1:length(ps)
      
      % Compute the probabilities of obtaining the data, given the assumed
      % release probabilty
      probs = binopdf(sCounts, n, ps(pp));
      
      % Avoid really small numbers
      probs(probs<TINY) = TINY;
      
      % Save product of likelihoods and sum of log likelihoods
      pdat(pp,:) = [prod(probs), sum(log(probs))];
   end
   
   % Use binofit to estimate p from the simulated data. This uses a trick
   % that assumes all of the measurements are independent and lumps them
   % together as if they were one big experiment.
   [phat, pci] = binofit(sum(sCounts),sampleSize*n);
   
   % Plot product of likelihoods
   %
   subplot(3,1,2); cla reset; hold on;
   ylabel('likelihood');

   % Plot the likelihood function (product of likelihoods)
   plot(ps, pdat(:,1));
   
   % Find the maximum
   maxp = max(pdat(:,1));
   
   % Show the actual pRelease value as a dashed line
   plot(pRelease.*[1 1], [0 maxp], 'r--');
   
   % Show the values obtained from binofit + CI
   plot(pci, maxp.*[1 1], 'm-', 'LineWidth', 2);
   plot(phat, maxp, 'm*');
   
   % Show the maximum value of our computed likelihood function
   plot(ps(pdat(:,1)==maxp), maxp, 'ko', 'MarkerSize', 12); 
   
   % plot sum of log-likelihoods
   %
   subplot(3,1,3); cla reset; hold on;
   ylabel('log likelihood');
   xlabel('Release probability');
   axis([0 1 log(TINY)*1000 0]);

   % Plot the likelihood function (sum of log-likelihoods)
   plot(ps, pdat(:,2));
   
   % Find the maximum
   maxp = max(pdat(:,2));
   
   % Show the actual pRelease value as a dashed line
   plot(pRelease.*[1 1], [0 min(pdat(:,2))], 'r--');
   
   % Show the values obtained from binofit + CI
   plot(pci, maxp.*[1 1], 'm-', 'LineWidth', 2);
   plot(phat, maxp, 'm*');

   % Show the maximum value of our computed likelihood function
   plot(ps(pdat(:,2)==maxp), maxp, 'g*'); 
   
   % Wait
   pause(0.1);
end

%% Exercise 4
%
% Note that like good Matlab programmers, we'll do this without loops
counts = [0	0 3 7 10 19 26 16 16 5 5 0 0 0 0]; % The experimental outcomes
n = length(counts)-1;   % Number of available quanta in each experiment
ks = 0:n;               % Possible values of k, as a row vector
nks = length(ks);       % Length of k
ps = (0:0.01:1.0)';     % Possible values of release probability, as a column vector
nps = length(ps);       % Length of p

% Compute the value of the binomial distribution for each possible value of 
%  k, n, p. Make a matrix in which:
%     - rows correspond to different values of p
%     - columns correspond to different values of k
probs = binopdf( ...
   repmat(ks, nps, 1), ...    % Repeat ks-row vector for each p
   n, ...                     % Always assuming the same 'n'
   repmat(ps, 1, nks));       % Repeat ps-column vector for each k

% Make a matrix of outcomes (in columns) that are repeated along the rows so we can
% use them to compute likelihoods for each possible value of release probability (p)
countsMatrix = repmat(counts, nps, 1);

% Compute likelihood function, which takes the product of all likelihoods
% associated with each measured outcome. 
likelihoodFcn = prod(probs.^countsMatrix,2);
pHat_fromLiklihood = ps(likelihoodFcn==max(likelihoodFcn))

% Compute log-likelihood function, which takes the sum of all log-likelihoods
% associated with each measured outcome. 
logLikelihoodFcn = sum(log(probs).*countsMatrix,2);
pHat_fromLogLikelihood = ps(logLikelihoodFcn==max(logLikelihoodFcn))

% Compare to empirical value
pHat = sum(counts.*ks)/(sum(counts)*n)

%% Exercise 5
n = 14;                       % Number of available quanta
k = 7;                        % Measured number of released quanta
pHat = binofit(k,n)           % Compute maximum-likelihood value of p
pNull = 0.3;                  % Null hypothesis p

% Get p-value for one-sided test that you would have gotten k or more 
% successes in n trials for the given null hypothesis p
% NOTE: use k-1 because the cdf gives the probability of getting up to and 
%   including that number of successes; we want 1-cdf, which is the
%   probability that we got that many or greater
% The result is p>0.05, so cannot rule out that we would have gotten 
%  this measurement by chance under the null hypothesis
1 - binocdf(k-1, n, pNull) 

%% Bonus exercise
% The data table
data = [ ...
   4.0 615 206 33 2 0 0; ...
   3.5 604 339 94 11 2 0; ...
   0.0 332 126 21 1 0 0; ...
   2.0 573 443 154 28 2 0; ...
   6.5 172 176 89 12 1 0; ...
   3.0 80 224 200 32 4 0];

xs = 0:5; % x-axis

% For each session
num_sessions = size(data, 1);
for ii = 1:num_sessions 
   
   % Compute relevant variables
   nx = data(ii,2:end); % the count data
   N  = sum(nx); % the total number of trials
   m  = sum(nx(2:end).*xs(2:end))/N;  % mean
   v  = sum((xs-m).^2.*nx)/N;  % variance
   p  = 1 - (v/m); % release probabilty
   n  = m/p; % available quanta per trial

   % Set up the plot
   subplot(1, num_sessions, ii); cla reset; hold on;
   bar(xs+0.5, nx./N, 'FaceColor', 'k');

   % Compute the binomial probabilities according to the equations at the
   % top of p. 762
   binomialCounts = zeros(size(xs));
   binomialCounts(1) = sum(nx).*(1-p).^n;   
   for jj = 2:length(binomialCounts)
       binomialCounts(jj) = binomialCounts(jj-1).*(m-p.*(jj-2))/((jj-1).*(1-p));
   end
   binomialCounts = round(binomialCounts);

   % Normalize for pdf and plot
   plot(xs+0.5, binomialCounts./sum(binomialCounts), 'ro-', 'MarkerFaceColor', 'r', 'LineWidth', 2);

   % If you want to compute Chi-2 goodness-of-fit,  k-1 degrees of freedom
   % A little bit of a cheat -- assume all bins contribute even when
   % binomialCounts=0 (because nx is always zero then, too)
   pb = 1-chi2cdf(nansum((nx-binomialCounts).^2./binomialCounts), length(binomialCounts)-1);   

   % Get Possion pdf
   pps = poisspdf(xs, m);
   plot(xs+0.5, pps, 'bo-', 'MarkerFaceColor', 'b', 'LineWidth', 2);

   % If you want to compute Chi-2 goodness-of-fit, k-1 degrees of freedom
   poissonCounts = round(pps.*N);
   pp = 1-chi2cdf(nansum((nx-poissonCounts).^2./poissonCounts), length(poissonCounts)-1);
   fprintf('row=%d, goodness-of-fits, binomial p=%.3f, Poisson p=%.3f\n', ii, pb, pp)

   % Show titles,labels, legend
   axis([0 5 0 1]);
   set(gca, 'FontSize', 12);
   h=title({sprintf('Temp=%.1f', data(ii,1)); sprintf('p=%.2f', p)});
   set(h, 'FontWeight', 'normal');
   if ii == 1
      xlabel('Number of Events')
      ylabel('Probability')
      legend('data', 'binomial', 'poisson');
   else
      set(gca, 'YTickLabel', '');
   end
end
