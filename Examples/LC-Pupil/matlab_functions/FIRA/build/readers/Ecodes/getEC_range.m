function ecode_ = getEC_range(ecodes, minv, maxv)
% function ecode_ = getEC_range(ecodes, minv, maxv)
%
% finds the first value in ecodes between minv and maxv
%

% created by jig 10/20/04

% default return
ecode_ = nan;

if nargin < 3 || isempty(ecodes)
    error('getEC_range: bad arguments')
    return
end

% find the first value between min and max, subtracting
%   out min
eind = find(ecodes(:,2) >= minv & ecodes(:,2) <= maxv);
if ~isempty(eind)
    ecode_ = ecodes(eind(1), 2) - minv;
end
