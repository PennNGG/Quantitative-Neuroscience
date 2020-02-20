% Here is a demo for using the functions called ddRT_*.  The are for fitting
% the drift-diffusion model simultaneously for choice and reaction time
% data.  Most of the math comes from one paper:
%   Palmer, Huk, and Shadlen, "The effect of stimulus strength on the
%   speed and accuracy of a perceptual decision." Journal of Vision, 2005,
%   5, 376-404.
%
% The code will fit up to 6 parameters, though in practice most of them
% proibably need to be fixed.  You probably need *a lot* of data to really
% fit 6 free parameters.  They are:
%   k, the coefficient of stimulus strength
%   b, the exponent of stimulus strength
%   A', the normalized bound height for accumulation
%   l, the lapse rate for the psychometric function
%   g, the guess rate for the psychometric function
%   tR, the resitual, or non-decision, time for each response.
%
% All the ddRT_* functions expect as the first argument a vector containing
% values for these parameter.  I call the vector Q, and
%   Q = [k, b, A', l, g, tR].

% 2008 by Benjamin Heasly at the University of Pennsylvania
%   benjamin.heasly@gmail.com
clear all
close all

% First, let's make a fake dataset.  We'll need some "true" parameter
% values:
Q_true = [.05; 1; 1; .01; .5; .5];

% Given these parameters, we can make the "true" psychometric and
% chronometric functions for an imaginary subject.
coherence_axis = linspace(1,100,500);
Psych_true = ddRT_psycho_val(Q_true, coherence_axis);
Chrono_true = ddRT_chrono_val(Q_true, coherence_axis);

% Let's look at the functions over log coherence
axP = subplot(2,1,1, 'XScale', 'log');
line(coherence_axis, Psych_true, 'Color', [0 0 0], 'Parent', axP);

axC = subplot(2,1,2, 'XScale', 'log');
line(coherence_axis, Chrono_true, 'Color', [0 0 0], 'Parent', axC);

% Now let's make some fake trial data:

% pick some "test" coherences
cohs = [3.2; 6.4; 12.8; 25.6; 51.2; 99];
trials_per_coh = 20;
trial_coh = repmat(cohs, trials_per_coh, 1);

% for each trial:
%   get a random choice from the "true" psychometric function
%   get a random response time near the "true" chronometric function
num_trials = length(trial_coh);
choice = zeros(num_trials, 1);
RT = zeros(num_trials, 1);
for ii = 1:num_trials

    % choices are 1 for correct and 0 for incorrect
    choice(ii) = ddRT_psycho_val(Q_true, trial_coh(ii)) > rand;

    % pick gamma-distributed, skewed reaction times
    k = 6;
    theta = ddRT_chrono_val(Q_true, trial_coh(ii));
    RT(ii) = gamrnd(k, theta/k);
end

% Let's make a summary of these data
nc = length(cohs);
Pc = zeros(1, nc);
RTmean = zeros(1, nc);
RT5 = zeros(2, nc);
for ii = 1:nc

    % pick a subset of trials
    coh_select = trial_coh == cohs(ii);

    % percent correct at each coherence
    Pc(ii) = mean(choice(coh_select));

    % reaction time mean
    RTmean(:,ii) = mean(RT(coh_select));

    % reaction time 5-percentiles at each coherence
    RT5(:,ii) = prctile(RT(coh_select), [5 95]);

    % plot the summary data over the "true" functions
    line(cohs(ii), Pc(ii), 'Marker', 'o', 'Parent', axP);
    line(cohs(ii), RTmean(:,ii), 'Marker', 'o', 'Parent', axC);
    line([1,1]*cohs(ii), RT5(:,ii), 'Marker', '+', 'Parent', axC);
end

% optionally futz with the coherence values to make each one unique
%   this doesn't work very well
% trial_coh = trial_coh + linspace(0, .1, num_trials)';

% Now we can recover our the "true" parameters from the random data

% Package fake data in the expected form
fitData = [trial_coh, choice, RT];

% The fit function needs inital guesses and constraints for the 6 model
% parameters.

% ddRT_initial_params calculates reasonable starting values, given the
%   dataset.
Q_guess = ddRT_initial_params(fitData);

% ddRT_bound_params gives some reasonable upper and lower bounds for each
%   of the parameters.
%   You might wish to change these.
%   For now, they only allow k, A', and tR to vary.  b, l, and g are fixed.
Q_bounds = ddRT_bound_params;

% The fitting function, fmincon, needs a few settings
opt = optimset( ...
    'LargeScale',   'off', ...
    'Display',      'off', ...
    'Diagnostics',  'off', ...
    'MaxIter',      1e3, ...
    'MaxFunEvals',  1e4);

% Do maximum likelihood fit the 6 parameters, using choice and RT data
% simultaneously.
%   @ddRT_psycho_nll gives the negative log likelihood of the choices in
%   fitData, given a set of parameters, Q.
%   @ddRT_chrono_nll_from_pred gives the negative log likelihood of the
%   mean reaction times at each coherence.  It predicts the variance of
%   reaction times, from the drift-diffusion model, rather than using the
%   variance of the observed RTs.
Q_fit = ddRT_fit( ...
    @ddRT_psycho_nll, ...
    @ddRT_chrono_nll_from_pred, ...
    fitData, [Q_guess, Q_bounds], opt);

% Finally, let's compare the "true" model parameters with the parameters
% recovered by the fit procedure.

% One-by-one...
disp(sprintf('\ttrue\tfit'))
name = {'k', 'b', 'A''', 'l', 'g', 'tR'};
for ii = 1:6
    disp(sprintf('%s\t%.3f\t%.3f', name{ii}, Q_true(ii), Q_fit(ii)));
end

% ...and all together, graphically
Psych_fit = ddRT_psycho_val(Q_fit, coherence_axis);
Chrono_fit = ddRT_chrono_val(Q_fit, coherence_axis);
line(coherence_axis, Psych_fit, 'Color', [1 0 0], 'Parent', axP);
line(coherence_axis, Chrono_fit, 'Color', [1 0 0], 'Parent', axC);

text(50, .55, 'true', 'Color', [0 0 0], 'Parent', axP);
text(50, .60, 'fit', 'Color', [1 0 0], 'Parent', axP);