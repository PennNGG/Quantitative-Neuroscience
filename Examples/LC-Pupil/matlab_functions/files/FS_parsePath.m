function filename_ = FS_parsePath(varargin)
% function filename_ = FS_parsePath(varargin)
%
% parse filename for MATLAB file on mac/unix system

if ~nargin
    filename_ = [];
    return;
end

filename_ = varargin{1};

for i = 2:nargin
    filename_ = [filename_ filesep varargin{i}];
end