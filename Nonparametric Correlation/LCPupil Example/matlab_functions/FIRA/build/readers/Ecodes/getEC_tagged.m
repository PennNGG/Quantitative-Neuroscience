function value_ = getEC_tagged(ecodes, tag, base, minv, maxv, scale, varargin)
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
%   varargin{1}     ... flag,   0: default, use only the first instance
%                               1: get all instances of one tag

% modified by Long Ding 3/28/2016 to for situations where there are multiple instances of one tag. 
% updated by jig 10/20/04
% adapted from get7000cd by jig 10/2/00

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania

% default return
value_ = nan;

flagOne = 1;
if nargin > 6 
    if ~isempty(varargin{1})
        if isinf(varargin{1})
            flagOne = 0;
        end
    end
end

% check args
% if nargin < 4 || isempty(ecodes)
%    error('getEC_tagged: bad arguments')
%    return
% end
if flagOne
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
else
    tind_all = find(ecodes(:,2) == tag);
    if isempty(tind_all)
        % disp(sprintf('getEC_tagged: could not find tag %f', tag))
        return
    end
    n_ind = length(tind_all);
    for i=1:n_ind
        tind = tind_all(i);
        % make sure there are possible values following the tag
        if tind == size(ecodes, 1)
            value_(i) = NaN;
        end
        
        % find the first value between min and max
        ec   = ecodes(tind+1:end, 2);
        vind = find(ec>=minv & ec<=maxv, 1) + tind;
        if isempty(vind)
            value_(i) = NaN;
        end
        value_(i) = ecodes(vind, 2) - base;
    end
end

if nargin > 5 && ~isempty(scale)
    value_ = value_ * scale;
end
