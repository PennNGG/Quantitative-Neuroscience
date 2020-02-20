function x_ = nans(varargin)
% makes an array of nans, analogous to the matlab functions ones and zeros.
% this just saves typing of nan* ones(...)

% 12/2/08 jig fixed it
% 5/9/97 mns wrote it

if nargin < 1
  error('nans requires an argument')
end

x_ = nan*ones(varargin{:});
