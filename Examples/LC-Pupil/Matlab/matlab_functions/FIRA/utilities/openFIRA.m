function openFIRA(filename, include_list, exclude_list)
% function openFIRA(filename, include_list, exclude_list)
%
% Convenience routine for opening a 'mat' file
% containing a FIRA data structure
%
% optional arguments specify which fields to include/exclude
%

% check that we can open the file
% also try with '.mat' extension
if isempty(strfind(filename, '.mat'))
    filename = [filename '.mat'];
end
fid = fopen(filename);
if fid == -1
    disp(sprintf('No file <%s>', filename))
    return
end
fclose(fid);

global FIRA

% lookfor the appropriate variable in the file
s = who('-file', filename, 'FIRA', 'data*');
if ismember('FIRA', s)
    load(filename, 'FIRA');
elseif ismember('data_', s)
    load(filename, 'data_');
    FIRA = data_;
    clear data_;
elseif ismember('data', s)
    load(filename, 'data');
    FIRA = data;
    clear data;
else
    FIRA = [];
    disp(sprintf('could not find FIRA in file <%s>', fname))
    return
end

% if it's "old style" (i.e., a 3x1 cell array), then we have to convert it
if iscell(FIRA)
    convertFIRA;
end

% check fields to include/exclude
if nargin > 1 && ~isempty(include_list)
    FIRA = rmfield(FIRA, setdiff(fieldnames(FIRA), include_list));
end
if nargin > 2 && ~isempty(exclude_list)
    FIRA = rmfield(FIRA, intersect(fieldnames(FIRA), exclude_list));
end


% TEMPORARY!!!!
FIRA.ecodes.type = cat(2, FIRA.ecodes.type, {'time', 'time'});
FIRA.ecodes.name = cat(2, FIRA.ecodes.name, {'stim_sac' 'vol_sac'});

FIRA.ecodes.data(:,end+1) = FIRA.ecodes.data(:,10)+...
    FIRA.ecodes.data(:,35)+FIRA.ecodes.data(:,36)+5;

FIRA.ecodes.data(:,end+1)   = FIRA.ecodes.data(:,10)+...
    FIRA.ecodes.data(:,29)+FIRA.ecodes.data(:,30)+5;