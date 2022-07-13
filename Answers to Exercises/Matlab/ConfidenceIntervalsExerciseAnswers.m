% Confidence Intervals and Bootstrapping
%  Answers to Exercise found here:
%
%  https://github.com/PennNGG/Quantitative-Neuroscience/blob/master/Concepts/Python/Confidence%20Intervals%20and%20Bootstrapping.ipynb

% Exercise: Compute confidence/credible intervals for simulated data 
%  sampled from a population that is Gaussian distributed with mean mu=10 
%  and standard deviation sigma=2, for n=5, 10, 20, 40, 80 at a 
%  95% confidence level.
mu = 10;
sigma = 5;
alpha = 0.95;
NB = 1000; % number of bootstraps

% Loop through the n's
% Note that the different approaches converge on the same answer as n gets
% large
for n = [5 10 20 40 80 160 1000]
   
   % Simulate some data
   data = normrnd(mu, sigma, n, 1);
   
   % Save the mean
   sample_mean = mean(data);
   
   % Show the mean, n
   fprintf('n = %d, MEAN = %.2f\n', n, sample_mean)
   
   % Method 1: analytic solution assuming Gaussian
   %
   % Get the z-score for the given confidence level (make it negative
   %  so we can subtract it to make the lower interval)
   z = -norminv((1-alpha)/2);
   
   % 1a. Use the given sigma
   sem = sigma/sqrt(n);
   fprintf('1a: CI=[%.2f %.2f]\n', sample_mean-sem*z, sample_mean+sem*z)
      
   % 1b. Use the sample sigma
   % BEST IF n IS LARGE (>30)
   sem = std(data)./sqrt(n);   
   fprintf('1b: CI=[%.2f %.2f]\n', sample_mean-sem*z, sample_mean+sem*z)
   
   % Method 2: analytic solution assuming t-distribution
   % BEST IF n IS SMALL (<30) ... note that as n increases, the t
   % distribution approaches a Gaussian and methods 1 and 2 become more
   % and more similar

   % Get the cutoff using the t distribution, which is said to have n-1
   %  degrees of freedom
   t = -tinv((1-alpha)/2, n-1);   
   disp(t)
   sem = std(data)./sqrt(n);
   fprintf('2 : CI=[%.2f %.2f]\n', sample_mean-sem*t, sample_mean+sem*t)
   
   % Method 3: bootstrap!
   %
   % Resample the data with replacement to get new estimates of mu 
   % Note that here we do not make any assumptions about the nature of the
   % real distribution.
   mu_star = zeros(NB, 1);
   for ii = 1:NB
      mu_star(ii) = mean(datasample(data, n));
   end
   
   % Now report the CI directly from the bootstrapped distribution
   fprintf('3 : CI=[%.2f %.2f]\n', ...
      prctile(mu_star, 100*(1-alpha)/2), prctile(mu_star, 100*(alpha+(1-alpha)/2)))
   
   % Method 4: Credible interval
   % See the Canvas discussion -- under these assumptions (i.e., data
   % generated from a Gaussian distribution with known sigma), the answer
   % is exactly the same as with Method 1, above. Note that this
   % equivalence is NOT true in general, which means that frequentist
   % confidence intervals and Bayesian credible intervals can give
   % different answers for certain distributions.
   
   % Formatting
   disp(' ')
end
