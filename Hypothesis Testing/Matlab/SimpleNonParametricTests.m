% Simple Non-Parametric Tests
%
%
% Copyright 2021 by Joshua I. Gold, University of Pennsylvania

%% Sign test
%
% Make some paired data
a = [3,10,4,20,4,7,50,3,5,5,7];
b = [5,9,10,15,6,5,43,6,2,1,0];
fprintf('p = %.2f\n', signtest(b-a))

%% Wilcocon signed-rank test
%
samples = randi(50, 200, 1);
null_hypothesis_median = 24;
fprintf('p = %.2f\n', signrank(samples, null_hypothesis_median))

%% Mann-Whitney test
% 
X = randi(50, 200, 1);
Y = 2 + randi(50, 200, 1);
fprintf('p = %.2f\n', ranksum(X, Y))
