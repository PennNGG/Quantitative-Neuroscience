% Exact Bionmial Test
% Answers to exercises found here: 
%  https://canvas.upenn.edu/courses/1358934/discussion_topics/5012730
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania
%  Created 09/29/18

%% Exercise 2: 
%  5. 
% Set up plot to show them
cla reset; hold on;
X = 0:8;    % all possible values of k
n = 8;      % total trials
p = 0.5;    % the Null hypothesis
Y = binopdf(X,n,p)
plot(X, Y, 'ro-', 'MarkerSize', 16, 'LineWidth', 0.5);

%  To simulate it, use:
% For 10 simulations
R10 = binornd(n, p, 10, 1);
h = hist(R10, X);
s1 = h./sum(h) 
plot(X, s1, 'ko-', 'MarkerSize', 4, 'LineWidth', 0.5);

% For 100 simulations
R100 = binornd(n, 0.5, 100, 1);
h = hist(R100, 0:8);
s2 = h./sum(h)
plot(X, s2, 'ko-', 'MarkerSize', 8, 'LineWidth', 0.5);

% For 1000 simulations
R1000 = binornd(8, 0.5, 1000, 1);
h = hist(R1000, 0:8);
s3 = h./sum(h)
plot(X, s3, 'ko-', 'MarkerSize', 12, 'LineWidth', 0.5);

% For 10000 simulations
R10000 = binornd(8, 0.5, 10000, 1);
h = hist(R10000, 0:8);
s4 = h./sum(h)
plot(X, s4, 'ko-', 'MarkerSize', 16, 'LineWidth', 0.5);


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
