function addTrial(ec, data, names, types)
% function addTrial(ec, data, names, types)
%
% addTrial method for class ecodes
%
% Input:
%   ec    ... the ecodes object
%   data  ... double array ecodes data
%   names ... cell array of string names of columns of data
%   types ... cell array of string types of data ('id', 'value', or 'time')
%
% Output:
%   nada, but fills FIRA.ecodes.data(end,:) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check trial number ...
if isempty(FIRA.ecodes.data) && FIRA.header.numTrials == 1

    % default nans which MIGHT be replaced below
    FIRA.ecodes.data = nan(size(FIRA.ecodes.name));

elseif size(FIRA.ecodes.data, 1) < FIRA.header.numTrials

    % nans for new trial, which probably will be replaced below
    FIRA.ecodes.data(end+1:FIRA.header.numTrials, :) = nan;

end

sizdat = size(data, 2);
N = size(FIRA.ecodes.name,2);

if nargin < 4 || isempty(types) || sizdat ~= size(types, 2)

    % if not enough types passed in, use default type
    types = repmat(cellstr('value'),1,sizdat);
end

if nargin < 3 || isempty(names) || sizdat ~= size(names,2)

    % if not enough names passed in, fake up some new names
    for n = 1:sizdat
        names{n} = sprintf('ch%i',n+N);
    end
end

% Need indices into <names> of any new name strings.
% setdiff could proivide, but it's slow.
% strcmp and a loop are faster
news = [];
for ii = 1:length(names)

    % index into names of any new name strings
    news(ii) = any(strcmp(FIRA.ecodes.name,names{ii}));

end

% news used as selection matrix
news = ~logical(news);

% Add any new name strings to the end of FIRA.ecodes.name
% Add corresponding type strings to the end of FIRA.ecodes.type
% Add corresponding nan columns to end of FIRA.ecodes.data
if any(news)
    FIRA.ecodes.name = cat(2,FIRA.ecodes.name, names(news));
    FIRA.ecodes.type = cat(2,FIRA.ecodes.type, types(news));
    FIRA.ecodes.data(:, N+1:N+sum(news)) = nan;
end

% For each name string in names, look for the cooresponding element of
% FIRA.ecodes.name.  If found, fill in corresponding column of
% FIRA.ecodes.data with new data.  If not found, fill in with nans.
memberi = [];
for ii = 1:length(names)   
    % index of FIRA.ecodes.name matching <names>, if any
    memberi = [memberi, find(strcmp(FIRA.ecodes.name,names{ii}), 1)];
end
rows = (1:size(data,1)) + size(FIRA.ecodes.data, 1) - 1;
FIRA.ecodes.data(rows,memberi) = data;

% remove any unused (default) columns
columnSelector = any(~isnan(FIRA.ecodes.data),1);
if any(columnSelector == 0)
    FIRA.ecodes.data = FIRA.ecodes.data(:,columnSelector);
    FIRA.ecodes.name = FIRA.ecodes.name(:,columnSelector);
    FIRA.ecodes.type = FIRA.ecodes.type(:,columnSelector);
end