% Parametric Correlations
%
% Answers to exercises found here: 
%  https://colab.research.google.com/drive/11kgk7FpLgbSlA4pjS4cCH1B5mYDUgj5b?usp=sharing
%
% Copyright 2019 by Yale E. Cohen, University of Pennsylvania
%  Updated 01/01/20 by jig

%% Get the data
WingLength = [10.4 10.8 11.1 10.2 10.3 10.2 10.7 10.5 10.8 11.2 10.6 11.4];
TailLength = [7.4 7.6 7.9 7.2 7.4 7.1 7.4 7.2 7.8 7.7 7.8 8.3];

%% 1. Plot the data
%
figure
plot(TailLength, WingLength, 'ko');
xlabel('Tail Length (cm)');
ylabel('Wing Length (cm)');

%% 2. Compute r
%
% Compute by hand
n           = length(WingLength); %alternatively, you can calculate n=length(TailLength)
sampleMeanX = sum(WingLength)./n;
sampleMeanY = sum(TailLength)./n;
SSEX        = sum((WingLength - sampleMeanX).^2);
SSEY        = sum((TailLength - sampleMeanY).^2);
SCOVXY      = sum((WingLength - sampleMeanX).*(TailLength - sampleMeanY));
rXY         = SCOVXY/(sqrt(SSEX)*sqrt(SSEY));
rYX         = SCOVXY/(sqrt(SSEY)*sqrt(SSEX));

% Use corrcoef
rBuiltIn = corrcoef(WingLength, TailLength);

% Show that they are all the same
fprintf('rXY=%.4f (computed), %.4f (built-in)\n', rXY, rBuiltIn(1,2))
fprintf('rYX=%.4f (computed), %.4f (built-in)\n', rYX, rBuiltIn(2,1))

%% 3. Compute standard error/confidence intervals
%
% Use formulas in the Canvas discussion

% Compute standard error directly 
standard_error_r = sqrt((1-rXY^2)/(n-2));

% Compute confidence intervals *of the full distribution* by: 
% 1. using Fisher's z-tranformation to make a variable that is normally
% distributed
z = 0.5.*log((1+rXY)/(1-rXY));

% 2. Compute the standard deviation of z
z_std = sqrt(1/(n-3));

% 3. Get the 95% CIs of the transformed variable from the std
z_95CIs = z+[1 -1].*norminv(0.025).*z_std;

% 4. Convert back to r (inverse z-transformation)
CI95 = (exp(2.*z_95CIs)-1)./(exp(2.*z_95CIs)+1);

% Show it
fprintf('r=%.2f, sem=%.2f, 95 pct CI = [%.4f %.4f]\n', rXY, standard_error_r, CI95(1), CI95(2))

%% 4. Compute p-value for H0:r=0
% Two-tailed test
% Remember that the *mean* of r follows a Student's t distribution 
%  with two degrees of freedom

% First compute the t-statistic, which is the sample r divided by the 
%  sample standard error
tVal = rXY/standard_error_r;

% Now compute the p-value. We want the probabily of getting a value of
%  the test statistic that is *at least as large* as the one that we
%  actually measured from our sample (i.e., tVal), given the null
%  distribution. Here we define the null distribution as the t distribution 
%  with n-2 degrees of freedom (recall that the t-distribution for a 
%  "regular" t-test has n-1 degrees of freedom... here it's n-2 because 
%  we have two samples, X and Y). Because we are using a two-tailed test, 
%  this p-value is equal to twice the area under the null t distribution 
%  that is greater than tVal. The cumulative distribution is the area that
%  is less than a particular value, so we want 1-cdf
prob = 2*(1-tcdf(tVal,n-2));

% Print it nicely
fprintf('p=%.4f for H0: r=0\n', prob)

%% 5. Is this r value different than r=0.75 
% Here we use a z-test on the z-transformed values, as described in the
%  Canvas discussion

% z-transform the new referent
zYale  = 0.5*log((1+0.75)/(1-0.75));

% Compute the text statistic as the difference in z-transformed values,
%  divided by the sample standard deviation
lambda = (z-zYale)/z_std;

% Get a p-value from a two-tailed test
prob2 = 2*(1-normcdf(lambda));
fprintf('p=%.4f for H0: r=0.75\n', prob2)

%% 6. Estimate power: That is, p(reject H0|H1 is true)
%
% Compute the test statistic as above
rRef   = 0.5;  
zRef   = 0.5*log((1+rRef)/(1-rRef));
lambda = (z-zRef)/sqrt(1/(n-3));

% Set a criterion based on alpha
alpha = 0.05;
zCriterion = norminv(1-alpha/2);

% Power is proportion of expected sample distribution to the right of the
% criterion
power = 1-normcdf(zCriterion-lambda)

% Can also calculate using sampsizepwr... note that we use n=1 because lambda is
% alerady in z units for the SEM
power = sampsizepwr('z', [0 1], lambda, [], 1)

% Calculate the n needed to ensure that H0 (r=0) is rejected 99% of the time
%  when |r|>= 0.5 at a 0.05 level of significance
%
% Derivation:
%  power = 1-normcdf(zCriterion-lambda)
%  1 - power = normcdf(zCriterion-lambda)
%  zCriterion-lambda = norminv(1 - power)
%  lambda  = zCriterion - norminv(1 - power)
%  (z-zRef)/sqrt(1/(n-3)) = zCriterion - norminv(1 - power)
%  sqrt(1/(n-3)) = (z-zRef) / (zCriterion - norminv(1 - power))
%  n = 1/((z-zRef) / (zCriterion - norminv(1 - power)))^2+3
desiredPower = 0.99;
predictedN = ceil(1/((z-zRef) / (zCriterion - norminv(1-desiredPower)))^2+3)