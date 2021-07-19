% pick some ddm parameters, generate some fake data, try to recover the
% paramerers with a fit.

close all
clear all

% sensitivity
k = 25;
% facilitation
b = 1.1;
% bound height
A = .83;
% non-decision response time
tR = 0;
% lapse rate
l = .05;
% guess rate
g = 0.5;
% standard parameter set
Q = [k, b, A, l, g, tR]';

% coherence or whatever
x = (2.^(1:9))/1000;

% "true" performance
psycho = ddRT_psycho_val(Q, x);
chrono = ddRT_chrono_val(Q, x);

% fake dataset
nc = length(x);
tpc = 20;
data = zeros(nc*tpc, 3);
for ii = 1:nc

    trials = (1:tpc)+(ii-1)*tpc;

    % simuli used
    data(trials, 1) = x(ii);

    % binomial choice sequence
    data(trials, 2) = rand(1,tpc) <= psycho(ii);
    % mean fake responses
    Pc(ii) = mean(data(trials, 2));

    % gaussian response times with madeup variance
    %   this is not very good
    sig = chrono(ii)*.3;
    data(trials, 3) = tR + normrnd(chrono(ii), sig, 1, tpc);
end

% constraints on Weibull fitting
% guess, min, max
ddCon(:,1) = Q;
ddCon(:,2) = [1e-3  1e-3    1e-3    .001    .4, 0];
ddCon(:,3) = [1e3   1e3     1e3     .2      .6, 1e3];

opt = optimset( ...
    'LargeScale',   'off', ...
    'Display',      'off', ...
    'Diagnostics',  'off', ...
    'TolFun',       1e-3, ...
    'TolX',         1e-3, ...
    'MaxIter',      1e4, ...
    'MaxFunEvals',  1e4);

[Qfit, Qerr, errVal, exitFlag, outputInfo] = ddRT_fit(@ddRT_psycho_nll, @ddRT_chrono_nll_from_data, ...
    data, ddCon, opt);
disp([Q, Qfit])
psychoFit = ddRT_psycho_val(Qfit, x);
chronoFit = ddRT_chrono_val(Qfit, x);

% show "true" functions, fake data, fit functions
axP = subplot(2,1,1, 'XLim', x([1 end]), 'YLim', [0 1], ...
    'XScale', 'log');
ylabel(axP, 'P_c')

line(x, Pc, ...
    'Parent', axP, 'LineWidth', 1, 'Color', [0 0 0], ...
    'Marker', '.', 'LineStyle', 'none');

line(x, psycho, 'Parent', axP, 'LineWidth', 2, 'Color', [0 0 0]);
line(x, psychoFit, 'Parent', axP, 'LineWidth', 1.5, 'Color', [1 0 0]);


axT = subplot(2,1,2, 'XLim', x([1 end]), 'YLim', [0 max(chrono)+tR]*1.5, ...
    'XScale', 'log');
ylabel(axT, 't_R (sec)')
xlabel(axT, '(proportion coh)')

line(data(:, 1), data(:, 3), ...
    'Parent', axT, 'LineWidth', 1, 'Color', [0 0 0], ...
    'Marker', '.', 'LineStyle', 'none');

line(x, tR+chrono, 'Parent', axT, 'LineWidth', 2, 'Color', [0 0 0]);
line(x, chronoFit+tR, 'Parent', axT, 'LineWidth', 1.5, 'Color', [1 0 0]);