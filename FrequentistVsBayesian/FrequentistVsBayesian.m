% Frequentist versus Bayesian Statistics
%
% To use this tutorial, read the commands and
%  execute the code line-by-line.
%
% The learning objective is to gain insights into:
%
% Copywrite 2019 by Joshua I. Gold, University of Pennsylvania


% Let's start with a simple example, taken from:
% https://en.wikipedia.org/wiki/Base_rate_fallacy#Example_1:_HIV

% "Imagine running an HIV test on population .. of 1000 persons ...
%  The test has a false positive rate of 5% (0.05) and no false negative rate."

N = 10000; % size of the population
falsePositiveRate = 0.05;
falseNegativeRate = 0;

% Question #1: If someone gets a positive test, is it "statistically
% significant"?
%
% Answer: statistical significance from frequentist perspective is 
%  typically measured as "p<0.05", or in other words we want 
%  the "likelihood" = p(data | Null Hypothesis) < 0.05. In this case, the Null 
%  Hypothesis is "not infected", and the data are just the single positive test. 
%  Therefore, the relvant p-value is simply the false-positive rate: 
%  p=0.05, which is typically considered "not significant." However, 
%  you can also see that it is not particularly informative.
p = falsePositiveRate;

% Question #2: What is the probability that if someone gets a positive
%  test, that person is infected?
%
% Answer: Here we are asking for a different probability:
%  p(infected | positive test) = p(hypothesis | data) = the "posterior
%  probability" of the hypothesis, given the data.

% Let's start by definining how many in the population are actually
% infected. We'll start by assuming it's ~50%:
isInfected = logical(binornd(1,0.5,N,1));

% Count the number infected
nInfected = sum(isInfected);

% Make array of positive tests, given the falsePositiveRate and falseNegativeRate
isPositive = false(N, 1);
% All of the infected individuals have a positive test
isPositive(isInfected) = true; 
% Some of the non-infected indivdiuals have a positive test
isPositive(~isInfected) = logical(binornd(1, falsePositiveRate, sum(~isInfected), 1));

% The probability that someone with a positive test is infected
pIsInfectedGivenIsPositiveTest = sum(isInfected&isPositive)./sum(isPositive);

% Now let's do the same thing, but try different values for the proportion
%  of the population that is actually infected.
infectedProportions = 0:0.1:1.0;
for ii = 1:length(infectedProportions)
   
   isInfected = logical(binornd(1,infectedProportions(ii),N,1));
   
   % Count the number infected
   nInfected = sum(isInfected);
   
   % Make array of positive tests, given the falsePositiveRate and falseNegativeRate
   isPositive = false(N, 1);
   % All of the infected individuals have a positive test
   isPositive(isInfected) = true;
   % Some of the non-infected indivdiuals have a positive test
   isPositive(~isInfected) = logical(binornd(1, falsePositiveRate, sum(~isInfected), 1));
   
   % The probability that someone with a positive test is infected
   pIsInfectedGivenIsPositiveTest = sum(isInfected&isPositive)./sum(isPositive);
   
   disp(sprintf('Proportion infected=%.1f, Posterior probabilty of infection, given a positive test=%.3f', ...
      infectedProportions(ii), pIsInfectedGivenIsPositiveTest))
end

