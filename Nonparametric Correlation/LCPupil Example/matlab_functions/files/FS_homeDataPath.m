function filename_ = FS_homeDataPath(varargin)
% function filename_ = FS_homeDataPath(varargin)
%
% parse filename for DATA file on different filesystems
    
[home_dir, server_dir] = dirnames;
filename_ = fullfile(home_dir, 'Data');

for i = 1:nargin
    filename_ = [filename_ filesep varargin{i}];
end