% laterTutorial_fitModelToDataExerciseAnswers
%
% Script for fitting the LATER model to real data (includes answers to exercise)
%
% Recall that the idea behind the LATER (Linear Approach to Threshold
%  with Ergodic Rate) model is that a saccadic decision is made when a
%  "ballistic" decision variable rises from a starting value to an ending
%  value at a constant ("ergodic") rate that is fixed for a particular
%  saccadic decision but varies as a Gaussian across decisions reaches a
%  fixed threshold.
%
% Because the rate of rise is distributed as a Gaussian, and the distance
%  traveled by the decision variable is fixed, we know that the amount of
%  time, representing the reaction time (RT), is just:
%
%  RT = distance / rate
%
% And thus RT is distributed as 1/rate, or an inverse Gaussian -- which is
%  the primary empirical observation that the LATER model was developed to
%  explain.
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania

global reciprocalRTs

%% Get the data
%
%  We use the same example from the scriptLATER_rawData script,
%  corresponding to Fig. 2, Kim et al, J Neuroscience
[data, labels] = later_getData([], [], 0.2);

%% fmincon options
%
opts = optimoptions(@fmincon,    ... % "function minimization with constraints"
   'Algorithm',   'active-set',  ...
   'MaxIter',     300,          ...
   'MaxFunEvals', 300);

%% Preallocate matrix to save the fits
%
fits = nan(length(labels), 2);

%% Open and set up a figure
%   show it as a subplot
subplot(2,1,1); hold on;

% Use these colors for plotting the four conditions
colors = {'b' 'r' 'y' 'm'};

%% Loop through each data set
%
for ii = 1:length(labels)

   % Get the data, convert to reciprocal RT in column vector
   reciprocalRTs = 1./data{ii}';
   
   % Pick initial values, using empirical mean/std of reciprocal RTs
   muR0 = 10; %mean(reciprocalRTs);
   deltaS0 = 5; %1./std(reciprocalRTs);
   
   % We will be using GlobalSearch. The general
   %  advantage of this approach is to avoid local minima; for details, see:
   %  https://www.mathworks.com/help/gads/how-globalsearch-and-multistart-work.html
   %
   %  First define the objective function. This could be set up as Matlab
   %  function, as it is here:
   %  https://github.com/TheGoldLab/Lab_Matlab_Utilities/blob/master/reciprobit/reciprobit_err.m
   %
   %  But here we use an Anonymous Function, so you can see it
   %
   %  Arguments:
   %  fits is a 1x2 vector of the two free parameters:  [muR deltaS]
   %     As desribed in scriptLATER_modelParameters, the model assumes that:
   %        1/RT ~N(muR/deltaS, 1/deltaS)
   %  Also uses rRTs, the nx1 vector of per-trial reciprocal rts (in seconds)
   %        defined above
   %
   %  Returns the negative summed log-likelihood:
   %  a. Compute the likelihood as:
   %        p(data | model parameters) =
   %        p( 1/RT | muR, deltaS) =
   %        normpdf( 1/RT, muR/deltaS, 1/deltaS) =
   %        normpdf(rrts, fits(1)/fits(2), 1/fits(2))
   %  b. Take the logarithm of each likelihood
   %  c. Sum them all together
   %  d. Take the negative, because fmincon finds the minimum (thus
   %        corresponding to the maximum likelihood)
   laterErrFcn = @(fits) -sum(log(normpdf(reciprocalRTs, fits(1)./fits(2), 1./fits(2))));

   % Set up the optimization problem
   problem = createOptimProblem('fmincon',    ...
      'objective',   @laterErrFcn,      ... % Use the objective function
      'x0',          [muR0 deltaS0],   ... % Initial conditions
      'lb',          [0    0],    ... % Parameter lower bounds
      'ub',          [1000 1000],      ... % Parameter upper bounds
      'options',     opts);  % fitting options

   % Create a GlobalSearch object
   gs = GlobalSearch;

   % Run it, returning the best-fitting parameter values and the negative-
   % log-likelihood returned by the objective function
   tic
   [fits(ii,:), nllk] = run(gs,problem);
   toc
   % Plot using our utility function, which expects RT in msec
   later_plotReciprobit(1./reciprocalRTs, fits(ii,:), gca, [], colors{ii})
   
   % Compare fit values to sample statistics
   fprintf('SET 1:\nmu: fit=%.2f, ss=%.2f\nstd: fit=%.2f, ss=%.2f\n', ...
       fits(ii,1)./fits(ii,2), mean(reciprocalRTs), ...
       1./fits(ii,2), std(reciprocalRTs))
end

% Plot the fits
for xx = 1:2
   subplot(2,2,2+xx); cla reset; hold on;
   plot(fits(:,xx), 'ko-');
end
subplot(2,2,3);
axis([1 4 2 8]);
xlabel('Condition')
ylabel('mu-R');

subplot(2,2,4);
axis([1 4 0.5 2.5]);
xlabel('Condition')
ylabel('delta-S');

   


