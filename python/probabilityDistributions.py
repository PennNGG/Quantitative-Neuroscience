"""
Probability distributions

To use this tutorial, read the commands and execute the code line-by-line.

The learning objectives are to gain insights into:
 - how to pseudo-randomly sample from probability distributions in Python
    (typically *rnd commands; e.g., normrnd for a normal distribution)
 - how to generate theoretical distributions in Python
    (typically *pdf commands; e.g., normpdf for a normal distribution)
 - characteristics of several specific distribuions:
    Bernoulli
    binomial
    Poisson
    exponential
    normal (Gaussian)
 - comparing probability distribution functions (pdfs) and 
    cumulative distribution functions (cdfs)

Copyright 2019 by Joshua I. Gold, University of Pennsylvania

Created on Sun Jan  3 22:30:39 2021
@author: arevell
"""

import random #python package to generate pseudo-random numbers. https://docs.python.org/3.8/library/random.html
import numpy as np #python package numpy. Widely used for scientific computing in Python and abbreviated as "np". https://numpy.org/doc/stable/user/whatisnumpy.html
import seaborn as sns #python package for plotting beautiful plots. Relies on matplotlib
#%%Bernoulli Distribution

"""
Resources

Canvas Discussion: https://canvas.upenn.edu/courses/1358934/discussion_topics/5121835
Wikipedia: https://en.wikipedia.org/wiki/Bernoulli_distribution
Mathworld: http://mathworld.wolfram.com/BernoulliDistribution.html
"""

"""
Introduction

The Bernoulli Distribution is a DISCRETE distribution because by definition it only takes on
specific, discrete values (in this case either 0 or 1)

We can use random.uniform(), which produces a random variable on the interval (0,1).
This means that all values are greater than 0 and less than 1

A single Bernoulli trial: 
outcome = 1 with probabilty p
outcome = 0 with probabilty 1-p


"""
# Choose value for p
p = 0.7 
# Uniformly pick a random number between 0 and 1. Compare that value to p, and store the boolean in variable "outcome".
outcome = (random.uniform(0, 1) <= p) 


"""
Equivalently, use np.random.binomial(n, p) 
This function samples from a BINOMIAL Distribution. But if n=1, then it is a BERNOULLI Distribution. 

Note that a Bernoulli Distribution is a special case of a binomial distribution. Specifically,
when n=1 the binomial distribution becomes a Bernoulli Distribution.
https://math.stackexchange.com/questions/838107/what-is-the-difference-and-relationship-between-the-binomial-and-bernoulli-distr#:~:text=A%20Bernoulli%20random%20variable%20has,identically%20distributed%20Bernoulli%20random%20variables.&text=The%20random%20variable%20that%20represents,is%20a%20Bernoulli%20random%20variable.
"""

# Special case of a Binomial Distribution where n=1
n = 1
outcome = (np.random.binomial(n, p) == 1)


"""
Experiment:
    
Check that we are generating the probability correctly by generating a
lot of trials and testing if the outcome is as expected
"""

trials = 10000; # Generate a lot of trials
outcomes = np.zeros(shape = (trials, 1)); # pre-allocate a big array
for i in range(trials): # loop through the trials
   outcomes[i,0] = np.random.binomial(n, p)


# Print out the results using f strings. https://realpython.com/python-f-strings/
number_of_zeros = sum(outcomes==0)[0]
number_of_ones = sum(outcomes==1)[0]
print(f"Number of Zeros: {number_of_zeros:0.0f}\n"
      f"Number of Ones:  {number_of_ones:0.0f}\n"
      f"Number of trials: {trials}\n"
      f"Empirical p: {number_of_ones/trials:0.2f}\n"
      f"Simulated p: {p:0.2f}"
      )


#%%Binomial Distribution

"""
Resources
Canvas Discussion: https://canvas.upenn.edu/courses/1358934/discussion_topics/5002068
Wikipedia: https://en.wikipedia.org/wiki/Binomial_distribution
Mathworld: http://mathworld.wolfram.com/BinomialDistribution.html
"""

"""
Introduction

A Binomial Distribution is the distribution of the number of successful 
outcomes for a given number of Bernoulli trials, defined by two parameters:
p = probability of success on each trial (constant across trials)
n = number of trials

This is also a DISCRETE distribution because by definition it only 
takes on specific, discrete values (in this case non-negative integers 
corresponding to the number of successes in n tries; thus, values 0:n).
"""

# Set parameters
p = 0.7
n = 1000

# Generate random picks. Note that this is as if we did the Bernoulli
# trials as above, but then just counted the successes
outcome =  np.random.binomial(n, p);

# Print out the results
print(f"Successes: {outcome}\n"
      f"Number of trials: {n}\n"
      f"Empirical p: {outcome/n:0.2f}\n"
      f"Simulated p: {p:0.2f}"
      )



"""
The full probability distribution describes the probabilty of obtaining
each possible number of successes (k), given n and p. If we set n=10,
the the possible values of k are 0, 1, ..., 10. Now we use np.random.binomial(n, p) 
to simulate many different picks to get a full distribution
"""
p = 0.7
n = 10   # number of "trials" 
N = 1000 # number of "simulations" (or "experiments")
outcomes = np.random.binomial(n, p, N ) 


sns.histplot(outcomes)











