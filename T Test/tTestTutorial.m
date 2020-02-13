% t-test tutorial
%
% Copyright 2020 by Joshua I. Gold

%% One-sample t-test for H0:mean=0
%
% Define the population distribution
MU  = 1;
STD = 1;

% Get random samples
N = 10;
X = normrnd(MU, STD, N, 1);

% Compute the sample mean
Xbar = mean(X);

% Compute the sample std
S = sqrt((1./(N-1)).*sum((X-Xbar).^2)); % same as S = std(X);

% Compute the t-statistic 
t = Xbar*sqrt(N)/S;

% The p-value is the probabilty of obtaining the t-statistic under the
% null hypothesis; that is, 1 minus the cdf of the t-distribution, given
% n-1 degrees of freedom (multiplied by two because we are looking at two
% symmetric tails)
p = 2.*(1-tcdf(t, N-1));

% Compare to what we get from ttest
[~,P,~,STATS] = ttest(X);

disp(sprintf('t statistic = %.4f (computed) %.4f (from ttest)', t, STATS.tstat))
disp(sprintf('p           = %.4f (computed) %.4f (from ttest)', p, P))

%% Two-sample paired t-test for H0: equal means
%
%
% Define paired measurements in terms of a difference and then additive 
%  0-mean noise
MU1      = 1;
MUDIFF   = 1;
MUNOISE  = 0;
STDNOISE = 0.5;
STD      = 1;

% Get random samples
N = 10;
X1 = normrnd(MU1, sqrt(STD), N, 1);
X2 = X1 + MUDIFF + normrnd(MUNOISE, STDNOISE, N, 1);

% Compute the difference
D = X2 - X1;

% Compute the sample mean of the difference
Dbar = mean(D);

% Compute the sample std of the difference
SD = std(D);

% Note that X1 and X2 are highly correlated, so the variance (or std) of the
% difference needs to take into account the covariance
% var(X2 - X1) = cov(X2 - X1, X2 - X1)
%              = cov(X2, X2) + cov(X1, X1) - cov(X2, X1) - cov(X1, X2)
%              = var(X2) + var(X1) - cov(X2,X1) - cov(X1,X2)
plot(X1, X2, 'ko', 'MarkerFaceColor', 'k');
vals = cov(X1, X2);
disp(sprintf('variance of D=%.4f, computed as variance of sum=%.4f', ...
   var(D), vals(1,1) + vals(2,2) - vals(1,2) - vals(2,1)))

% Compute the t-statistic 
tD = Dbar*sqrt(N)/SD;

% The p-value is the probabilty of obtaining the t-statistic under the
% null hypothesis; that is, 1 minus the cdf of the t-distribution, given
% n-1 degrees of freedom (multiplied by two because we are looking at two
% symmetric tails)
pD = 2.*(1-tcdf(tD, N-1));

% Compare to what we get from ttest
[~,PD,~,STATSD] = ttest(D);

disp(sprintf('t statistic = %.4f (computed) %.4f (from ttest)', tD, STATSD.tstat))
disp(sprintf('p           = %.4f (computed) %.4f (from ttest)', pD, PD))

%% Two-sample unpaired t-test for H0: equal means
%
%
% Define unpaired measurements, same std
MU1 = 1;
MU2 = 2;
STD = 1;

% Get random samples, same n
N = 10;
X1 = normrnd(MU1, sqrt(STD), N, 1);
X2 = normrnd(MU2, sqrt(STD), N, 1);

% Compute test statistic
Sp = sqrt((var(X1) + var(X2))./2);
tU = (mean(X1)-mean(X2))./(Sp.*sqrt(2./N));

% The p-value is the probabilty of obtaining the t-statistic under the
% null hypothesis; that is, 1 minus the cdf of the t-distribution, given
% n-1 degrees of freedom (multiplied by two because we are looking at two
% symmetric tails)
pU = 2.*(1-tcdf(abs(tU), 2*N-2));

% Compare to what we get from ttest
[~,PU,~,STATSU] = ttest2(X1, X2);

disp(sprintf('t statistic = %.4f (computed) %.4f (from ttest)', tU, STATSU.tstat))
disp(sprintf('p           = %.4f (computed) %.4f (from ttest)', pU, PU))
