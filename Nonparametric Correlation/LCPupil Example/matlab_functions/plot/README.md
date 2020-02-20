Utilities for making nice-looking plots in Matlab

Example to set up figure with multiple panels:

%% Set up figure
wid     = 11.6;    % total width of figure
cols    = {1,1,1}; % cell array, entries are number of columns per row
hts     = repmat(2.5, 1, length(cols)); % all the same height
psh     = 0.8; % panel separation height
psw     = 0.5; % panel separation width
[axs,~] = getPLOT_axes(num, wid, hts, cols, psh, psw, [], 'Blah Blah Blah', true);
set(axs,'Units','normalized');
