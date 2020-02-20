function value_ = getEC_tagged(ecodes, tag, base, minv, maxv, scale)
% function value_ = getEC_tagged(ecodes, tag, base, minv, maxv, scale)
%
% Gets the value of a "taggged" ecode from a list of ecodes
%   (typically from a single trial), of the form:
%
%  code1        time
%  ...
%  tag          time
%  base+value_  time
%  ...
%
% Note that the value of the parameter must be 
%   in the range min -> max
%
% Arguments:
%   ecodes  ... list of ecodes
%   tag     ... tag (ecode) to find
%   base    ... base value to subtract out
%   minv    ... min value of value_
%   maxv    ... max value of value_
%   scale   ... optional value to scale value_
% 

% updated by jig 10/20/04
% adapted from get7000cd by jig 10/2/00

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania

% default return
value_ = nan;

% check args
% if nargin < 4 || isempty(ecodes)
%    error('getEC_tagged: bad arguments')
%    return
% end

% find the tag
tind = find(ecodes(:,2) == tag, 1);
if isempty(tind)
    % disp(sprintf('getEC_tagged: could not find tag %f', tag))
    return
end

% make sure there are possible values following the tag
if tind == size(ecodes, 1)
    % disp(sprintf('getEC_tagged: found tag %f, but no values follow', tag))
    return
end

% find the first value between min and max
ec   = ecodes(tind+1:end, 2);
vind = find(ec>=minv & ec<=maxv, 1) + tind;
if isempty(vind)
    % disp(sprintf('getEC_tagged: found tag %f, but no value', tag));
    return
end
value_ = ecodes(vind, 2) - base;

if nargin > 5 && ~isempty(scale)
    value_ = value_ * scale;
end