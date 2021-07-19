% figSetup.m
%
% Example script for setting up a nice-looking figure

%% Set up Fig
% units should be in inches, from wysifig
num        = 1;   % figure number
wid        = 6.0; % total width
ht         = 1.2;
cols       = {3, [.3 .7]};
[axs,fig_] = getPLOT_axes(num, wid, ht, cols, [], [], [], 'Mulder et al');

axes(axs(1)); cla reset; hold on;
xax = (1:100)';
plot(xax, cos(xax), 'r-');
xlabel('Time (ms)');
ylabel('Value');

%% To save to a file, for printing or editing (we use Illustrator)
print -depsc -loose 'fig.eps'
