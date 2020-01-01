% Parametric Correlations
% Answers to exercises found here: 
%  https://canvas.upenn.edu/courses/1358934/discussion_topics/5600885
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
rBuiltIn    = corrcoef(WingLength, TailLength);

% Show that they are all the same
disp(sprintf('rXY=%.4f (computed), %.4f (built-in)', rXY, rBuiltIn(1,2)))
disp(sprintf('rYX=%.4f (computed), %.4f (built-in)', rYX, rBuiltIn(2,1)))

%% 3. Compute standard error/confidence intervals
%
sr   = sqrt((1-rXY^2)/(n-2));
z    = 0.5.*log((1+rXY)/(1-rXY));
sz   = sqrt(1/(n-3));
zs   = z+[1 -1].*norminv(0.025).*sz;
CI95 = (exp(2.*zs)-1)./(exp(2.*zs)+1);
disp(sprintf('sem=%.4f, 95 pct CI = [%.4f %.4f]', sr, CI95(1), CI95(2)))

%% 4. Compute p-value for H0:r=0
%
Tval = rXY/sr;           % Compute t statistic
prob = 1-tcdf(Tval,n-2); % Compute p, using n-2 degrees of freedom
disp(sprintf('p=%.4f for H0: r=0', prob))

%% 5. Is this r value different than r=0.75 
%
zme   = 0.5*log((1+rXY)/(1-rXY));
zyale = 0.5*log((1+0.75)/(1-0.75));
Z     = (zme-zyale)/sqrt(1/(n-3));
prob2 = 1-tcdf(Z/2,inf);
disp(sprintf('p=%.4f for H0: r=0.75', prob2))

%% 6. Estimate power: That is, p(reject H0|H1 is true)
%
v=n-2;
zm=0.5*log((1+rXY)/(1-rXY));

tcrit=tinv(1-0.05/2,n-2);
rcrit=sqrt(tcrit^2/(tcrit^2+(n-2)));
zr=0.5*log((1+rcrit)/(1-rcrit));

Zb=(zm-zr)*sqrt(n-3);
power=normcdf(Zb);
disp(['The power of the test of H0:r=0 is ' num2str(power)])

%calculate the n needed to ensure that H0 (r=0) is rejected 99% of the time
%when |r|>= 0.5 at a 0.05 level of significance
Often = 0.01; %we want to reject H0 (1-often)% of the time [here, 99%]
rho=0.5; % when r >=0.5
AlphaValue=0.05; % and the hypothesis is tested at AlphaValue of significance
Zb=tinv(1-Often,inf);
Za=tinv(1-AlphaValue/2,inf);
zeta=0.5*log((1+rho)/(1-rho));
SampleSize=round(((Zb+Za)/zeta)^2+3);
disp(['To reject H0:r=0 99% of the time, when r=0.5 and alpha=0.05, we need n>=' num2str(SampleSize)])

