function filename_ = FS_homeMfilePath(varargin)
% function filename_ = FS_homeMfilePath(varargin)
%
% parse filename for M-file on mac/unix system

[home_dir, lab_dir] = dirnames;
filename_ = fullfile(home_dir, 'Matlab', 'mfiles_jigold');

for i = 1:nargin
    filename_ = [filename_ filesep varargin{i}];
end
