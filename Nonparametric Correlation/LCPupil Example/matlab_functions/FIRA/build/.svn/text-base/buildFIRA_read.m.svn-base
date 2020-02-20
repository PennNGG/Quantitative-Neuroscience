function buildFIRA_read(filename, filetype)
% function buildFIRA_read(filename, filetype)
%
% Reads file and fills FIRA.raw.(dataTypes)
%       with raw data
%
%  Arguments:
%   filename    ... name of data file, including path
%                       or 'connect' for a connection to plexon
%   filetype    ... chooses the "file reader" to read the data file
%                      'rex'             for Rex
%                      'nex'             for Nex
%                      'plx' or 'plexon' for Plexon
%                       'connect'        for connection to plexon
%                       (case insensitive)

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

% of course
global FIRA

% check args
if nargin < 1 || isempty(filename)
    return
end

if nargin < 2
    filetype = [];
end

% check for compressed file
if isSuffix(filename, '.gz')
    [path,name] = fileparts(filename);    
    gunzip(filename, path);
    filename = filename(1:end-3);
end

% Open the file(s) using the appropriate converter.
% This should fill in the following fields of FIRA:
%
%    FIRA.header.filename ... actual filename used
%    FIRA.header.filetype ... file type
%    FIRA.header.paradigm ... paradigm number
%
%    FIRA.raw.(dataTypes)

% REGISTRY OF READERS
%
%  FUNCTION             FILE TYPE    FILE SUFFIX
%  --------             ---------    -----------
readers = {...
    @readPLX_nexFile    'nex'         {'.nex'};     ... % NEX (Neural EXplorer) FILES
    @readREX_files      'rex'         {'A' 'E'};    ... % REX FILES
    @connectPLX         'connectPLX'  {'connect'};  ... % PLEXON CONNECTION
    @readPLX_plxFile    'plexon'      {'.plx'};     ... % PLEXON FILES
    @readTDL_logFile    'topsFile'    {'.mat'};     ... % TOPS DATA LOG FILE
};

% To decide which "reader" to use on the data file(s):
% 1) Use the suffix of the data file, if given
% 2) use the file_type argument, if given
% 3) try all
fti = 1:size(readers, 1);
for i = fti
    if strncmpi(filetype, readers{i, 2}, 2)
        fti = i;
        break
    end
    for j = 1:length(readers{i, 3})
        fstr = max(strfind(filename, readers{i,3}{j}));
        if ~isempty(fstr) && fstr == length(filename) - length(readers{i,3}{j}) + 1
            fti = i;
        end
    end
end

% now read the data file(s)
while ~isempty(fti) && feval(readers{fti(1), 1}, filename) > 0
    fti = fti(2:end);
end

% Check that we got something
if isempty(FIRA.header.filename)
    error(sprintf('Could not build FIRA from <%s>', filename))
end
