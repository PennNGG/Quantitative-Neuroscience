function FS_saveProjectFile(project, fname, fdat)
% function FS_saveProjectFile(project, fname, fdat)
%

if nargin < 3 || isempty(fname) || isempty(fdat)
    return
end

if isempty(project)
    fname = 'Default';
end

% get lab dirname
[home_dir, lab_dir, local_dir] = dirnames;

% make full filename
dirname = fullfile(local_dir, 'Data', 'Projects', project);

if ~exist(dirname, 'dir')
    mkdir(dirname);
end

% make full filename
fullname  = fullfile(dirname, sprintf('%s.mat', fname));

% save it
save(fullname, 'fdat');
