function ecode_ = getEC_fromList(ecodes, list)
% function ecode_ = getEC_fromList(ecodes, list)
%
% finds the first member of list that is in the array
% of ecodes
%
% created by jig from getEC_tagged, 10/20/04

% default return
ecode_ = nan;

if nargin < 2 || isempty(ecodes)
    error('getEC_fromList: bad arguments')
    return
end

%varargin

% use ismember to find all instances of the elements of
% list in ecodes
eind = find(ismember(ecodes(:,2), list));

% return the first
if ~isempty(eind)
    ecode_ = ecodes(eind(1),2);
end
