% Frequentist versus Bayesian Statistics
%
% Answers to exercises from:
%   https://github.com/PennNGG/Quantitative-Neuroscience/blob/master/Concepts/Matlab/FrequentistVsBayesian.m   
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania

%% Question #1: If someone gets a positive test, is it "statistically
% significant"?
%
% Answer: Statistical significance from the Frequentist perspective is 
%  typically measured by comparing p to a threshold value; e.g., p<0.05.
%  In this case, "p" is shorthand for "the probabilty of obtaining the 
%  data under the Null Hypothesis", so we are checking for:
%     p(data | Null Hypothesis) < 0.05. 
%  Here we take the Null Hypothesis as "not infected", and the data are 
%  just the single positive test. 
%
%  Therefore, the relvant p-value is simply the false-positive rate: 
%  p=0.05, which is typically considered "not significant." However, 
%  you can also see that it is not particularly informative.
p = falsePositiveRate;

%% Question #2: What is the probability that if someone gets a positive
%  test, that person is infected?
%
% Answer: Here we are asking for a different probability:
%  p(infected | positive test) = p(hypothesis | data) = the "posterior
%  probability" of the hypothesis, given the data.
%
% Let's work our way backwards to figure out what information we need to 
%  solve this problem.
%
% We can compute the probability that someone with a positive test is 
%  infected from a particular population as:
% pIsInfectedGivenIsPositiveTest = sum(isInfected&isPositive)./sum(isPositive);
%
% (I am keeping this commented out right now because the variables on
%  the right-hand side of the equation are not defined yet, so Matlab would
%  give an error if we try to evaluate that expression.)
%
% It should be obvious that to compute this quantity, we need to know the
%  number of people in the population who are actually infected (i.e., we
%  need to compute the number of people corresponding to isInfected ==
%  true), in addition to knowing the number of people who had a positive
%  test.
%
% So let's start by definining how many in the population are actually
%  infected. We'll start by assuming that that *real* rate of infection is
%  0.5 (i.e., half the POPULATION is infected), and then do a quick 
%  simulation to find out how many in our SAMPLE of N people are infected.
%  We can do this simulation by by getting N picks from a 
%  binomial distribution, where each pick determines "isInfected" for a
%  single person according to the assumed rate of infection:
isInfected = logical(binornd(1,0.5,N,1));

% Now we can count the number infected
nInfected = sum(isInfected);

% Now we need to count the number of people who got a positive test in this
%  example. There is no false negative rate, which implies that everyone
%  who is infected got a positive test:
isPositive = isInfected;

% But there is a non-zero false-positive rate, which implies that some of 
%  the people who are not infected will also have a positive test. We
%  can use binornd again to generate random picks from a binomial 
%  distribtuion according to the false-positive rate:
isPositive(~isInfected) = logical(binornd(1, falsePositiveRate, sum(~isInfected), 1));

% Now we can compute the probability that someone with a positive test is
%  infected:
pIsInfectedGivenIsPositiveTest = sum(isInfected&isPositive)./sum(isPositive);