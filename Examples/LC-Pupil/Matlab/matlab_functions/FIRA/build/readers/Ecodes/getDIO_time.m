function time_ = getDIO_time(dio, port, bit, index)

% function time = getDIO_time(port, bit, index)
% Long Ding 10-11-2007
% 
% get timestamp of dio inputs
%     port: 
%     bit:
%     index: specifies which time to report when multiple instances are
%     found, default: 1

% default return
time_ = nan;

if nargin < 3 
    error('getDIO_time: bad arguments')
    return
end

if isempty(dio)
    return
end

if nargin < 4 || index < 1
    index = 1;
end
colport = dio(:,2);
colbit = dio(:,3);
tind = find(dio(:,2) == port & dio(:,3) == bit);
% check how many were found
if isempty(tind)
    return

elseif length(tind) == 1 || nargin < 4 || isempty(index)
    % return all
    time_ = dio(tind, 1);
    
else
    % return given ind
    index(index>length(tind)) = length(tind);    
    time_ = dio(tind(index), 1)';
end