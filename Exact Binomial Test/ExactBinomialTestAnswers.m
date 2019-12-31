% Exact Bionmial Test
% Answers to exercises
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania
%  Created 09/29/18

%% Exercise 2: 
%  5. 
X = 0:8;    % all possible values of k
n = 8;      % total trials
p = 0.5;    % the Null hypothesis
Y = binopdf(X,n,p)
%
%  This code returns:
%  
%     Y = [0.0039 0.0313 0.1094 0.2188 0.2734 0.2188 0.1094 0.0313 0.0039]
%
%  To simulate it, use:
R10 = binornd(8, 0.5, 10, 1);
h = hist(R10, 0:8);
h./sum(h) % returns: 0 0 0 0.4000 0.2000 0.4000 0 0 0

R100 = binornd(8, 0.5, 100, 1);
h = hist(R100, 0:8);
h./sum(h) % returns: 0.0100 0.0600 0.1200 0.2100 0.2500 0.2100 0.0900 0.0400 0.0100

R1000 = binornd(8, 0.5, 1000, 1);
h = hist(R1000, 0:8);
h./sum(h) % returns: 0.0040 0.0270 0.1260 0.2070 0.2620 0.2260 0.1120 0.0320 0.0040

R10000 = binornd(8, 0.5, 10000, 1);
h = hist(R10000, 0:8);
h./sum(h) % returns: 0.0035 0.0280 0.1134 0.2164 0.2761 0.2156 0.1105 0.0325 0.0040

%% Exercise 3
%
% 3. p = 0.0313
sum(binopdf([0 6], 6, 0.5))

% 4. p = 1 - (no extreme in first comparison) * (no extreme in second comparison)
%      = 0.0388
p1 = sum(binopdf([0 8], 8, 0.5));
p2 = sum(binopdf([0 6], 6, 0.5));
p  = 1 - (1-p1)*(1-p2)

% 5. p = 1 - prod(no extreme in each comparison)
%      = 0.0832
ns = [8 6 7 7 7];
p = 1 - prod(1-binopdf(0, ns, 0.5).*2);

% 6. p = 0.2820
ns = [14 14 12 14 13 11 10 8 6 3];
p = 1 - prod(1-binopdf(0, ns, 0.5).*2);
