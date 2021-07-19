%% Bernoulli distribution
%
% Colab: https://colab.research.google.com/drive/1h5EoxuqTrJGylVdRNCo0MzRPkr2JE_cH?usp=sharing
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