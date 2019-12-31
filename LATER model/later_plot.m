function later_plot(rts, fits, ax, xlm, color)
% function later_plot(rts, fits, ax, xlm, color)
%
% fits are muR, deltaS
% rts are in SECONDS
%
% Reciprobit is reciprocal latency vs cumulative z-score (probit)
%   see Carpenter & Williams 1995
%       Reddi & Carpenter, 2000, 2003
%       http://www.cudos.ac.uk/later.html
%
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania

if nargin < 1 || isempty(rts)
   return
end

if nargin < 3 || isempty(ax)
   %figure
   ax = gca;
else
   axes(ax);
end

if nargin < 4 || isempty(xlm)
   xlm = [0.1 1];
end

if nargin < 5 || isempty(color)
   color = 'k';
end

% get transformed data
[xs,ys] = reciprobit_xys(rts);

% plot raw data, make axes real purdy
plot(-xs, ys, '.', 'Color', color);

% Label axes with RT (x) and probability (y) values that make sense, but
% corresond to actual -1/RT (x) and probit (y) values that are plotted
XTICK  = 10.^(linspace(log10(xlm(1)), log10(xlm(2)), 4));
YTICK  = [.1 1 5 10 50 90 95 99 99.9];
YTICKi = norminv(YTICK./100,0,1);

set(gca, ...
   'FontSize',     14,                 ...
   'YTick',        YTICKi,             ...
   'YTickLabel',   YTICK,              ...
   'YLim',         YTICKi([1 end]),    ...
   'XTick',        -1./XTICK,          ...
   'XTickLabel',   XTICK,              ...
   'XLim',         -1./XTICK([1 end]));
xlabel('RT (sec)');
ylabel('Probability');

% possibly show fits
if nargin > 1 && ~isempty(fits)
   fxs = -1./xlm;
   plot(fxs, (fxs+fits(1)/fits(2)).*fits(2), '-', 'Color', color);
end