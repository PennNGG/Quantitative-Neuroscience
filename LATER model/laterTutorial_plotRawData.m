% laterTutorial_plotRawData
%
% Tutorial for examining raw RT data from Kim et al, J Neuroscience (example from 
%  Figure 2) in reciprobit form
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

%% 1. Load the raw data
%
%
%   Each raw data file in data/data_mgl/F has the following vectors (in 
%    each case, columns are individual trials):
%     - decisionSum takes -1 if the decision was left side, and 1 if the 
%        decision was right side.
%     - labelSum takes 1 for trials after change point (TACP) 0, and 2 
%        for TACP 1, and 3 for TACP 2, and 4 for TACP 3, and 5 for TACP 4, 
%        and 0 for the rest. [NOTE FROM JIG: THIS IS HOW MY STUDENT TIM KIM
%        CODED THE DATA, SO I WANT TO KEEP IT IN THIS RAW FORMAT. HOWEVER, 
%        PLEASE NOTE THAT THIS CODING SCHEME SEEMS OVERLY CONFUSING; I
%        WOULD HAVE CODED IT AS 0 FOR TACP=0, 1 FOR TACP=1, ETC]
%     - numdirSum takes -1 if the sound was left side, and 1 if the sound 
%        was right side.
%     - percorrSum is 0 if the subject's answer was incorrect, and 1 
%        if the subject's answer was correct.
%     - syncSum is 1 if the current trial is a "pupil trial" and 0 if 
%        the current trial is "RT trial" [NOTE FROM JIG: IGNORED HERE]
%     - tRxnSum is RT measured by mglGetSecs, where the RT is defined 
%        as the time when the eyes leave the fixation window. 
%        The fixation window was defined as 30% of the height and width of 
%        the screen (32.31cm x 51.69cm).

% Use a particular subject tag
SUBJECT_TAG = 'JT';

% Load the data from that subject, given the base directory
load(fullfile(getLATER_baseDirectory, 'data', 'data_mgl', 'F', ...
   [SUBJECT_TAG '_RT.mat']));

%% Plot RT distribution
%
%
% Open a figure
figure

% Define selection criteria ("L" for "logical array"):
%  1. Correct trials only (basic LATER model doesn't account for errors)
%  2. Remove outlier RTs (need to check with Tim Kim about the conditions
%        that gave rise to super-long RTs of ~4 s)
Ltrials = percorrSum == 1 & tRxnSum < 1.2;

% Binning for RT and 1/RT plots
rtBins  = 0:0.02:1.2;
rrtBins = 0:0.2:10.0; % cutting off long tail of express saccades

% TOP: ALL SELECTED TRIALS
%  LEFT: RT distribution
%  Note that:
%  1. This distribution combines conditions that we expect to have 
%     an effect on RT, which we will explore below
%  2. Nonetheless, it still has the basic shape we expect: a small subset 
%     of very short ("express") RTs, corresponding to the values to the
%     left of the mode; and then overall a long tail to the right,
%     indicating quite a few longer RT trials
subplot(5,2,1); cla reset; hold on;
plotLATER_histogram(tRxnSum(Ltrials), rtBins, 'RT (sec)')

%  RIGHT: Inverse RT distribution
%  To see that the long tail on the right is roughly equivalent to an
%     inverse Gaussian, plot a histogram of the inverse RTs. Now the express
%     saccades are a long tail to the right, and otherwise the distribution
%     looks pretty close to Gaussian
subplot(5,2,2); cla reset; hold on;
plotLATER_histogram(1./tRxnSum(Ltrials), rrtBins, '1/RT (sec)')

% Now loop through and plot for subjets of trials corresponding to (see Fig. 2
%  in Kim et al):
%  C_L,0:  Left choices, change-point trials
%  C_L,1+: Left choices, non-change-point trials
%  C_R,0:  Right choices, change-point trials
%  C_R,1+: Right choices, non-change-point trials
labels = {'C_L_,_0', 'C_L_,_1_+', 'C_R_,_0', 'C_R_,_1_+'};
LtrialSubsets = [ ...
   Ltrials & numdirSum == -1 & labelSum == 1; ...
   Ltrials & numdirSum == -1 & labelSum ~= 1; ...
   Ltrials & numdirSum ==  1 & labelSum == 1; ...
   Ltrials & numdirSum ==  1 & labelSum ~= 1];

% Loop
for ii = 1:length(labels)
   
   % Plot RT distribution on the left
   subplot(5,2,3+(ii-1)*2); cla reset; hold on;
   plotLATER_histogram(tRxnSum(LtrialSubsets(ii,:)), rtBins, labels{ii});
   
   % Plot 1/RT distribution on the right
   subplot(5,2,4+(ii-1)*2); cla reset; hold on;
   plotLATER_histogram(1./tRxnSum(LtrialSubsets(ii,:)), rrtBins, labels{ii});   
end

% Add labels at bottom
subplot(5,2,9); 
ylabel('Count');
xlabel('RT (sec)');
subplot(5,2,10);
xlabel('1/RT (sec)');

%% Plot Reciprobit example
%
%
% Show how to build a reciprobit plot, in steps
% Open figure
figure

% Get and sort an example RT distribution
rts = tRxnSum(LtrialSubsets(1,:));
rtsSorted = sort(rts);

% Compute empirical cumulative RT probabilities
n = length(rts);
cumulativeProbabilities = (1:n)./n;

% Convert to probit scale
probitCumulativeProbabilities = norminv(cumulativeProbabilities,0,1);

% 1. Give intuition for probit scale
%
% 1. a. Show conversion of probablities (x-axis) into probit (y-axis) scale
%     (i.e., probabilities are converted to z-scores) for the EMPRICAL
%     distribution (i.e., the data)
%  Note that probit values of +/- 1 are 1 SD away from the mean
subplot(4,3,1); cla reset; hold on;
plot(cumulativeProbabilities, probitCumulativeProbabilities, 'k-', 'LineWidth', 2);
plot([0 1], [-1 -1], 'r-');
plot([0 1], [1 1], 'r-');
plot(0.5+[-0.34 0.34], [-1 1], 'gx', 'MarkerSize', 15) 
xlabel('Cum prob');
ylabel('Cum prob (probit)');

% 1. b. Show an ideal cumulative Gaussian on a probability scale
x = -5:0.01:5;
subplot(4,3,2); cla reset; hold on;
plot(x, normcdf(x, 0, 1), 'k-');
xlabel('Value');
ylabel('Cum prob');

% 1. c. Show an ideal cumulative Gaussian on a probit scale -- a straight line!
subplot(4,3,3); cla reset; hold on;
plot(x, norminv(normcdf(x, 0, 1), 0, 1), 'k-');
xlabel('Value');
ylabel('Cum prob (probit)');

% 2. Show empirical cumulative RT distribution
%
subplot(4,1,2); cla reset; hold on;
plot(rtsSorted, cumulativeProbabilities, 'ko-');
xlabel('RT (sec)');
ylabel('Cum prob');

% 3. Show empirical cumulative -1/RT distribution
%
% 	Use negative values of 1/RT so it's a true cumulative
%     function (monotonically increasing)
subplot(4,1,3); cla reset; hold on;
plot(-1./rtsSorted, cumulativeProbabilities, 'ko-');
xlabel('-1/RT (sec)');
ylabel('Cum prob');

% 4. Show empirical cumulative -1/RT distribution on probit scale 
%
subplot(4,1,4); cla reset; hold on; grid on;
plot(-1./rtsSorted, probitCumulativeProbabilities, 'ko');

% X-axis labels are the RTs assocaited with the values -1/RT
% Don't show all the express saccades
expressCutoff = 200;
XTickLabels = [100 expressCutoff 2500];
XTickValues = -1000./XTickLabels;

% Y-axis labels are probabilities associated with the z-scores
YTickLabels = [0.1 1 5 10 50 90 95 99 99.9];
YTickValues = norminv(YTickLabels./100,0,1);

set(gca, ...
    'YTick',        YTickValues,          ...    
    'YTickLabel',   YTickLabels,          ...
    'YLim',         YTickValues([1 end]), ...
    'XTick',        XTickValues,          ...
    'XTickLabel',   XTickLabels,          ...
    'XLim',         XTickValues([1 end]));
xlabel('RT (sec)');
ylabel('Cum prob');

%% Plot data using Reciprobit format
%
%
% For all four data sets from the above example
figure
cla reset; hold on; grid on;
colors = {'b' 'r' 'y' 'm'};

% Loop through all four data sets
plotHandles = nans(length(labels), 1);
for ii = 1:length(labels)
   
   % Do it by hand. Also could use utilities found here:
   % https://github.com/PennNGG/Statistics/tree/master/LATER%20model
   %
   % Get sorted rts
   rtsSorted = sort(tRxnSum(LtrialSubsets(ii,:)));

   % Compute empirical cumulative RT probabilities on probit scale
   n = length(rtsSorted);
   cumulativeProbabilities = (1:n)./n;
   probitCumulativeProbabilities = norminv(cumulativeProbabilities,0,1);

   % Plot it, using separate markers for express/non-express saccades
   Lexpress = rtsSorted < expressCutoff/1000;
   plot(-1./rtsSorted(Lexpress), ...
      probitCumulativeProbabilities(Lexpress), 'x', 'Color', colors{ii}, ...
      'MarkerSize', 10);
   plotHandles(ii) = plot(-1./rtsSorted(~Lexpress), ...
      probitCumulativeProbabilities(~Lexpress), 'o', 'Color', colors{ii}, ...
      'MarkerFaceColor', colors{ii}, 'MarkerSize', 5);
end

% Set the axes
set(gca, ...
    'YTick',        YTickValues,          ...    
    'YTickLabel',   YTickLabels,          ...
    'YLim',         YTickValues([1 end]), ...
    'XTick',        XTickValues,          ...
    'XTickLabel',   XTickLabels,          ...
    'XLim',         XTickValues([1 end]));
xlabel('RT (sec)');
ylabel('Cum prob');

% Add legend
legend(plotHandles, labels, 'Location', 'NorthWest')
