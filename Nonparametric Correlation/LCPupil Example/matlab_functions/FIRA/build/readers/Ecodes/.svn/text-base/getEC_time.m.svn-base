function time_ = getEC_time(ecodes, timecd, index, offset)
% function time_ = getEC_time(ecodes, timecd, index, offset)
%
% looks in an array of ecodes for the time of occurrance
% of the given ecode (timecd)
%
% Arguments:
%   ecodes  ... list of ecodes
%   timecd  ... code to find
%   index   ... optional argument
%               specifying which time to return if more than one is found

% written by jig 10/20/04 from getDTF_timecd

% default return
time_ = nan;

if nargin < 2 || isempty(ecodes)
    error('getEC_time: bad arguments')
    return
end

% find the first instance of the code
tind = find(ecodes(:,2) == timecd);

% check how many were found
if isempty(tind)
    return

elseif length(tind) == 1 || nargin < 3 || isempty(index)
    % return all
    time_ = ecodes(tind, 1);
    
else
    % return given ind
    index(index>length(tind)) = length(tind);    
    time_ = ecodes(tind(index), 1)';
end

if nargin >= 4 && offset
    
    time_ = time_ + offset;
end
