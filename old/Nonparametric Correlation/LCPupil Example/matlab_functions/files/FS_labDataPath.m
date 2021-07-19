function filename_ = FS_labDataPath(varargin)
% function filename_ = FS_labDataPath(varargin)
%
% parse filename for DATA file on different filesystems
    
[home_dir, lab_dir] = dirnames;
filename_ = fullfile(lab_dir, 'Data');

for i = 1:nargin
    filename_ = [filename_ filesep varargin{i}];
end