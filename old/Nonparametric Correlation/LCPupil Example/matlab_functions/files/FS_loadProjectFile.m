function dat_ = FS_loadProjectFile(project, mfile)
% function dat_ = FS_loadProjectFile(project, mfile)
%

% Created by jig 4/21/2008

if nargin < 1 || isempty(project)
    project = 'Default';
end

if nargin < 2 || isempty(mfile)
    mfile = 'Default';
end

% get lab dirname
[home_dir, lab_dir, local_dir] = dirnames;

% make full filename
fullname = fullfile(local_dir, 'Data', 'Projects', project, sprintf('%s.mat', mfile));

% check if data file exists
dat_ = [];
if exist(fullname, 'file') && ~isempty(whos('-file', fullname))
    S = load(fullname, 'fdat');
    if isfield(S, 'fdat')
        dat_ = S.fdat;
    end
end
