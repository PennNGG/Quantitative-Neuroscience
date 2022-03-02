function filename_ = FS_labMfilePath(varargin)
% function filename_ = FS_labMfilePath(varargin)
%
% parse filename for M-file on mac/unix system

[home_dir, lab_dir] = dirnames;
filename_ = fullfile(lab_dir, 'Matlab', 'mfiles_lab');

for i = 1:nargin
    filename_ = [filename_ filesep varargin{i}];
end
