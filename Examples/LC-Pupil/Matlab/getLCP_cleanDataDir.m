function [dir_, fnames_] = getLCP_cleanDataDir(monkey, site)

dir_ = fullfile('/Users', 'jigold', 'Box', 'GoldLab', 'Data', 'Physiology', ...
    'PD_Fixation', 'Recording', monkey, site, 'clean');

if nargout > 1
    D = dir(fullfile(dir_, '*.mat'));
    fnames_ = {D.name};
end