function laterTutorial_plotHistogram(data, bins, label)
% function laterTutorial_plotHistogram(data, bins, label)
% 
% Utility for plotting RT (or 1/RT) distributions) in a common format
%  into the current axes
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania

hist(data, bins); % Last argument defines the bins, for visualization
%ylabel('Count')
%xlabel(label)

% Show the median/IQR values
vals = prctile(data, [25 50 75]); % Compute percentiles
title(sprintf('%s: Med [IQR] = %.2f [%.2f %.2f]', label, vals(2), vals(1), vals(3)));
ylm = get(gca, 'YLim'); % to show lines
plot(vals([2 2]), ylm, 'r-', 'LineWidth', 2);
plot(vals([1 1; 3 3])', [ylm; ylm]', 'r--'); % Note transpose trick to draw two separate lines

% Scale x axis
xlim(bins([1 end]))