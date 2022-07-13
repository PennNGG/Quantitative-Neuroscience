% Frequentist versus Bayesian Statistics
%
% To use this tutorial, read the commands and execute the code line-by-line.
%
% The learning objective is to gain insights into thinking about inference
% from a "Frequentist" versus a "Bayesian" perspective. In brief, because a
% Frequentist does not consider the probability of an event or state of the
% world or hypothesis, only their frequency of occurrance, it is not possible 
% to ask questions of the form "what is the probabilty that hypothesis x is
% true?" Instead, one can only consider questions of the form, "what is the
% probabilty that I would have obtained my data, given that hypothesis x
% is true?" In contrast, Bayesians consider the probabilities of such
% things (often called the strength of belief), but doing so can require
% making assumptions that can be difficult to prove.
%
% For NGG students, this tutorial is meant to be used in tandem with this
% Discussion on the NGG Canvas site:
%
% https://canvas.upenn.edu/courses/1358934/discussion_topics/5440322
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania

%% Let's start with a simple example, taken from:
% https://en.wikipedia.org/wiki/Base_rate_fallacy#Example_1:_HIV

% "Imagine running an HIV test on" A SAMPLE "of 1000 persons ..."
N = 10000; % size of the SAMPLE

% "The test has a false positive rate of 5% (0.05)..."
% i.e., the probability that someone who takes the test gets a POSITIVE 
%  result despite the fact that the person does NOT have HIV
falsePositiveRate = 0.05; 

% "...and no false negative rate."
% i.e., The probability that someone who takes the test gets a NEGATIVE 
%  result despite the fact that the person DOES have HIV
falseNegativeRate = 0;

%% Question #1: If someone gets a positive test, is it "statistically
% significant"?

%% Question #2: What is the probability that if someone gets a positive
%  test, that person is infected?

% For answers, see <add link>

%% Following from Question #2, let's do the same thing, 
% but this time we will try different values for 
% the proportion of the population that is actually infected. What you
% should notice is that the PROPORTION INFECTED GIVEN A POSITIVE TEST
% depends (a lot!) on the OVERALL RATE OF INFECTION. Put another way, to
% determine the probabilty of a hypothesis, given your data 
% (e.g., proportion infected given a positive test), you have to know the
% probability that the hypothesis was true without any data.
%
% Why is this the case? It is a simple consequence of the definition of 
% a conditional probability, formulated as Bayes' Rule. Specifically,
% the joint probability of two events, call them A and B, is defined as:
% p(A and B) = p(A) * p(B | A)
% p(B and A) = p(B) * p(A | B)
%
% Now, calling A the Hypothesis and B the Data, then rearranging, we
% get:
% p(Hypothesis | Data) = p(Data | Hypothesis) * p(Hypothesis)
%                        ------------------------------------
%                                       p(Data)
%
% So you cannot calculate the probability of the hypothesis, given the
% data (i.e., the Bayesian posterior), without knowing the probability 
% of the hypothesis independent of any data (i.e., the prior)
infectedProportions = 0:0.1:1.0;
for ii = 1:length(infectedProportions)
   
   % Simulate # infections in the SAMPLE, given the POPULATION rate
   isInfected = logical(binornd(1,infectedProportions(ii),N,1));
   
   % Count the number infected
   nInfected = sum(isInfected);
   
   % Make array of positive tests, given that falseNegativeRate=0 ...
   isPositive = isInfected;
   
   % And falsePositiveRate > 0
   isPositive(~isInfected) = logical(binornd(1, falsePositiveRate, sum(~isInfected), 1));
   
   % The probability that someone with a positive test is infected
   pIsInfectedGivenIsPositiveTest = sum(isInfected&isPositive)./sum(isPositive);
   
   % We can compute the Bayesian Posterior as:
   % p(hypothesis | data) = (p(data | hypothesis) * p(hypothesis)) / p(data)
   % Note that we are using the true rate from the full POPULATION, 
   % so these predictions will differ slightly from the probability computed 
   % above (pIsInfectedGivenIsPositiveTest) from the SAMPLE
   pDataGivenHypothesis = 1 - falseNegativeRate;
   pHypothesis = infectedProportions(ii);
   pData = sum(isPositive)./length(isPositive);   
   pHypothesisGivenData = (pDataGivenHypothesis * pHypothesis) / pData;

   % Compute the theoretial posterior probability: 
   disp(sprintf('Infection rate=%.1f, proportion infected given a positive test=%.3f, Posterior=%.3f', ... 
      infectedProportions(ii), pIsInfectedGivenIsPositiveTest, pHypothesisGivenData))
end
