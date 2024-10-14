 % laterTutorial_dependenceOnModelParameters
%
% Script for examining LATER model parameters
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

%% Plot an example
%
%
figure

% The only two parameters in the later model are:
% 1. The mean value of the distribution of rise times (assume the standard
%     deviation=1 -- it turns out that if you change this, you can just
%     re-scale the other two parameters to get an equivalent model where
%     this value=1, so it can be just set to 1 by convention)
%
%     Pick a value that we happen to know will give us reasonable RT
%     predictions
muR = 4;
stdR = 1;

% 2. The distance from the starting point to the threshold
%
%     Again, pick a value that we happen to know will give us reasonable RT
%     predictions
deltaS = 1.2;

% Now we can simulate an RT distribution by picking from the rise-time
%  distribution a whole bunch of times:
N = 10000;
RT = deltaS./normrnd(muR, stdR, N, 1);

% Plot the histogram
subplot(3,1,1);
hist(RT, 0:0.01:2.0);
xlim([0 2.0]);
xlabel('RT (sec)');
ylabel('Count');

% Compute reciprobit values
xValues = -1./sort(RT);
yValues = norminv(((1:N)./N)',0,1);

% Plot it as a reciprobit, but don't relabel the axes
subplot(3,1,2); cla reset; hold on;
plot(xValues, yValues, 'k.');
xlm = get(gca, 'XLim');
ylm = get(gca, 'YLim');
axis([xlm ylm]);
xlabel('-1/RT (sec)')
ylabel('z score');

% Plot it as a reciprobit, and relabel the axes
subplot(3,1,3); cla reset; hold on;
plot(xValues, yValues, 'k.');
axis([xlm ylm]);

XTickLabels = [200 500 1000 2000];
XTickValues = -1000./XTickLabels;

% Y-axis labels are probabilities associated with the z-scores
YTickLabels = [0.1 10 50 90 99.9];
YTickValues = norminv(YTickLabels./100,0,1);

set(gca, ...
   'YTick',        YTickValues,          ...
   'YTickLabel',   YTickLabels,          ...
   'XTick',        XTickValues,          ...
   'XTickLabel',   XTickLabels);
xlabel('RT (sec)');
ylabel('Cum prob');

% Now instead of a simulation, use the analytic solution. Remember that:
%  1. The x-axis of the reciprobit plot is labeled as RT, so the numbers
%     are sensible, but what is really plotted is -1/RT
%  2. The y-axis is labeled as probability but really is z-score (note the
%     scaling)
%  3. And of course, the point of the LATER model is that:
%     RT = deltaS/riseRate
%     -1/RT = -riseRate/deltaS, where
%     -riseRate ~N(-muR, stdR), or, equivalently,
%     -1/RT ~N(-muR/deltaS, 1/deltaS)
%
%  Now let's visualize this better on each plot:
for xx = 1:2
   
   % For each plot
   subplot(3,1,xx+1);
   
   %  The y-axis is the z-score of a random variable (-1/RT)
   %     that is distributed as a Gausian with mean -muR/deltaS, and thus the
   %     z-score = 0 at its mean value, which we can see here:
   xIntercept = -muR/deltaS;
   plot([xlm(1) xIntercept], [0 0], 'r-')
   plot([xIntercept xIntercept], [ylm(1) 0], 'r-')
   plot(xIntercept, 0, 'ro');
   
   % And every increment in z-score on the y-axis is, by definition of
   %     z-score, an incrememnt of the std
   plot([xIntercept xIntercept+1/deltaS], [0 1], 'r-', 'LineWidth', 2)
   
   % In other words, on the reciprobit plot, the analytic solultion to the
   % LATER model is just a stright line, with:
   %  x-intercept = -muR/deltaS
   %  1/slope = 1/deltaS
   %
   % Or:
   %  y-intercept = muR
   %  slope = deltaS
   xRT = [0.1 1.0];
   reci_xRT = -1./xRT;
   plot(reci_xRT, reci_xRT.*deltaS + muR, 'g-');
end

%% Vary muR and deltaS and visualize the effects
%
%
figure

xRT      = [0.2 4.0];
reci_xRT = -1./xRT;
muRs     = 1:8;
deltaSs  = 0.5:0.1:2.0;

% Vary muR, fixed deltaS
subplot(2,1,1); cla reset; hold on;
for mm = 1:length(muRs)
   
   % These are shifted versions of each other
   plot(reci_xRT, reci_xRT.*deltaS + muRs(mm), 'k-');
end

% Vary deltaS, fixed muR
subplot(2,1,2); cla reset; hold on;
for dd = 1:length(deltaSs)
   
   % These are "swiveled" versions of each other, converging at the
   % y-intercept (equivalent to infinite RT)
   plot(reci_xRT, reci_xRT.*deltaSs(dd) + muR, 'k-');
end

% Label the axes
for xx = 1:2
   subplot(2,1,xx);
   
   XTickLabels = [200 500 1000 2000];
   XTickValues = -1000./XTickLabels;
   
   % Y-axis labels are probabilities associated with the z-scores
   YTickLabels = [.001 0.1 10 50 90 99.9 99.999];
   YTickValues = norminv(YTickLabels./100,0,1);
   
   set(gca, ...
      'YTick',        YTickValues,          ...
      'YTickLabel',   YTickLabels,          ...
      'XTick',        XTickValues,          ...
      'XTickLabel',   XTickLabels);
   xlabel('RT (sec)');
   ylabel('Cum prob');
end