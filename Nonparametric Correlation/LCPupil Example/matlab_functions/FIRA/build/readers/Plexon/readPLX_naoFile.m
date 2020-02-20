function error_ = readPLX_naoFile(filename)
% function error_ = readPLX_naoFile(filename)
% 
% Note: .nao files are nex files converted from Alpha-Omega (.mpx) files. 
% Reads raw data from a "nao" file created from Plexon
% putting the data into the global FIRA data structure, as follows:
%
%    FIRA.header.filename ... filename
%    FIRA.header.filetype ... 'nao'
%    FIRA.header.paradigm ... 'xxx'
%
%   raw data is put into appropriate field
%    FIRA.raw.(dataType)
%
% Arguments:
%   filename  ... typically includes the full path
%
% Returns:
%   error_    ... duh
%   also fills appropriate fields of the global FIRA
%

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
%
% history:
% modified from readPLX_nexFile, by Long Ding 09/04/2015, to read .nao files 

% parse arguments
if nargin < 1 || isempty(filename)
    error_ = 1;
    return
end

% try opening file with different suffices
ss  = {''; '.nao'; '.NAO'};
ind = 1;
fid = 0;
while ind < length(ss) && fid < 1
    fname = [filename ss{ind}];
    fid   = fopen(fname, 'r', 'l');
    ind   = ind + 1;
end
if fid < 1
    error_ = 2;
    return
end

% check the magic number
magic = fread(fid, 1, 'int32');
if magic ~= 827868494
    error_ = 3;
    return
end

%%%
% FILL IN FIRA HEADER INFO
%%%
global FIRA

error_ = 0;
FIRA.header.filename = {fname};
FIRA.header.filetype = 'nao';
FIRA.header.paradigm = 'xxx';

%%%
% DETERMINE WHAT KIND OF DATA TO SAVE
%%%
% "markers" are digital input events that
%   can, in principle, encode ecodes, matCmds 
%   and dio commands
keep_markers = isfield(FIRA.raw, 'ecodes') || ...
    isfield(FIRA.raw, 'matCmds') || isfield(FIRA.raw, 'dio');
keep_spikes = isfield(FIRA.raw, 'spikes');
keep_analog = double(isfield(FIRA.raw, 'analog'));
if ~isempty(FIRA.raw.ecodes)
    time_offset = FIRA.raw.ecodes(end, 1);
else
    time_offset = 0;
end

%%%
% read the rest of the NexFileHeader
%%%
version = fread(fid, 1, 'int32');
comment = fread(fid, 256, 'char');
freq    = fread(fid, 1, 'double');
tbeg    = fread(fid, 1, 'int32');
tend    = fread(fid, 1, 'int32');
nvar    = fread(fid, 1, 'int32');
fseek(fid, 260, 'cof');

%% show info
%disp(strcat('version = ', num2str(version)))
%disp(strcat('frequency = ', num2str(freq)))
%disp(strcat('duration (sec) = ', num2str((tend - tbeg)/freq)))
%disp(strcat('number of variables = ', num2str(nvar)))

%%%
% read the NexVarHeaders
%%%
types   = zeros(nvar, 1);
names   = zeros(nvar, 64);
offsets = zeros(nvar, 1);
counts  = zeros(nvar, 1);
sfs     = zeros(nvar, 1);
ADtoMVs = zeros(nvar, 1);
nPts    = zeros(nvar, 1);
nMarks  = zeros(nvar, 1);
markLs  = zeros(nvar, 1);

for i=1:nvar
    types(i)    = fread(fid, 1,      'int32');
    var_version = fread(fid, 1,      'int32');
    names(i, :) = fread(fid, [1 64], 'char');
    offsets(i)  = fread(fid, 1,      'int32');
    counts(i)   = fread(fid, 1,      'int32');
    dummy       = fread(fid, 32,     'char');
    sfs(i)      = fread(fid, 1,      'double');
    ADtoMVs(i)  = fread(fid, 1,      'double');
    nPts(i)     = fread(fid, 1,      'int32');
    nMarks(i)   = fread(fid, 1,      'int32');
    markLs(i)   = fread(fid, 1,      'int32');
    dummy       = fread(fid, 68,     'char');
end

names       = char(names);
ecodes      = [];
ends        = [];
tscale      = 1000/freq;
sf          = [];

% find & verify all the analog channels
ais = find(types==5);
if keep_analog && ~isempty(ais)

    % get channel names
    ch = nans(size(ais));
    for ii = 1:length(ais)
        temp = sscanf(names(ais(ii),:), 'AI_%f');
        if ~isempty(temp)
            ch(ii) = temp;
        end
    end
    ch = ch(~isnan(ch));
    % analog/verify does the hard work of checking the channels, etc
    Lgood = verify(FIRA.spm.analog, ch, sfs(ais));
    types(ais(~Lgood)) = -99;
else
    types(ais) = -99;
end

%%%
% read the data
%%%
% ivar = [1:6];
% for i=ivar
for i=1:nvar

    disp(sprintf('NEX: collecting %s', names(i,:)))

    if types(i) == 0 && keep_spikes
        %%%
        % SPIKES
        %%%
        %
        % first parse <channel> <unit> from
        % spike channel name (e.g., sig006a is channel 6, unit 1)
        % save <timestamp> <id>, where id = 1000*channel+unit
        sc = sscanf(names(i,:), 'sig%f%c')' - [0 96]; % a=1, etc
        [ver, id] = verify(FIRA.spm.spikes, [sc(1) sc(2)]);
        if ver
            fseek(fid, offsets(i), 'bof');
            FIRA.raw.spikes  = [FIRA.raw.spikes; ...
                [time_offset+fread(fid, [counts(i) 1], 'int32')*tscale ...
                id*ones(counts(i),1)]];
        end

    elseif types(i) == 1
        %%%
        % EVENT (start/stop)
        %%%
        %
        % for now do nothing

    elseif types(i) == 2
        %%%
        % INTERVAL
        %%%
        %
        % for now do nothing

    elseif types(i) == 3
        %%%
        % WAVEFORM
        %%%
        %
        % for now do nothing

    elseif types(i) == 4
        %%%
        % POPULATION VECTOR
        %%%
        %
        % for now do nothing

    elseif types(i) == 5 && keep_analog > 0
        %%%
        % ANALOG CHANNEL
        %%%
        % analog data comes in fragments ... first find each fragment
        fseek(fid, offsets(i), 'bof');
        ts = fread(fid, [counts(i) 1], 'int32')*tscale; % array of fragment timestamps (one timestamp per fragment, in ms)
        fn = fread(fid, [counts(i) 1], 'int32');        % fn - number of data points in each fragment
        fn(counts(i)+1) = nPts(i);
        fn = diff(fn);

        % Long Ding 2016-12-19
        % AO standard sampling rate is 2750 for analog. 
        % Plexon standard sampling rate is 1000 for analog.
        % Most analog signals we care about 1000 is sufficient. 
        % "Downsample" to 1000.
        t_orig = [0:1000/sfs(i):1000/sfs(i)*max(fn)];
        t_conv = [0:1000/sfs(i)*max(fn)];
        t_orig = t_orig(1:end-1);
        t_conv = t_conv(1:end-1);
        fn = length(t_conv);
        FIRA.analog.store_rate(keep_analog) = 1000;
        
        % first time through, set up time base
        if keep_analog == 1 %isempty(FIRA.raw.analog.data)
            
            % jig changed 10/25/2005 ... now there might be
            % data already in FIRA.raw.analog.data, even if we just
            % opened the file (for concatenating data from multiple files)
            start_ind = size(FIRA.raw.analog.data, 1) + 1;
            
            % if data matrix exists, append to the end; otherwise
            % create an nx1 array
            FIRA.raw.analog.data = [FIRA.raw.analog.data; ...
                zeros(sum(fn), max(1, size(FIRA.raw.analog.data, 2)))];

%             cs    = [0:1000/sfs(i):1000/sfs(i)*max(fn)];
            % Long Ding 2016-12-19
            % AO standard sampling rate is 2750 for analog. 
            % Plexon standard sampling rate is 1000 for analog.
            % Most analog signals we care about 1000 is sufficient. 
            % "Downsample" to 1000.
            cs = t_conv;
            
            ends  = zeros(length(fn), 1);
            ind   = start_ind;
            for j = 1:length(fn)
                FIRA.raw.analog.data(ind:ind+fn(j)-1) = time_offset+ts(j)+cs(1:fn(j));
                ends(j) = ts(j)+cs(fn(j));
                ind     = ind+fn(j);
            end

        elseif size(FIRA.raw.analog.data, 1)-start_ind+1 ~= sum(fn)
            error('... Bad format for FIRA.raw.analog.data')
        end

        % get scale, offset
%         FIRA.raw.analog.data(start_ind:end, keep_analog+1) = ...
%             fread(fid, [nPts(i) 1], 'int16').*ADtoMVs(i).*...
%             FIRA.analog.gain(keep_analog) + FIRA.analog.offset(keep_analog);
            % Long Ding 2016-12-19
            % AO standard sampling rate is 2750 for analog. 
            % Plexon standard sampling rate is 1000 for analog.
            % Most analog signals we care about 1000 is sufficient. 
            % "Downsample" to 1000.
            % Also there seems to be a gain of 100? 
        a_orig = fread(fid, [nPts(i) 1], 'int16').*ADtoMVs(i)/100.0;
        a_conv = interp1(t_orig, a_orig, t_conv);
        FIRA.raw.analog.data(start_ind:end, keep_analog+1) = ...
            a_conv.*...
            FIRA.analog.gain(keep_analog) + FIRA.analog.offset(keep_analog);

        % increment pointer so we only initialize once
        keep_analog = keep_analog + 1;

        % add the data ... array of a/d values (in millivolts, then scaled)
        % SCALE FOR GOLD LAB: *10.2
        % SCALE FOR SHADLEN LAB: /200
        %             % jig changed 9/1/05 to read in chunks. mmm. chunks.
        %             % For speed.
        %             if nPts(i) > 1000000
        %                 tic
        %                 FIRA.raw.analog.data(:, end+1) = 0;
        %                 ind = 1;
        %                 while nPts(i) > 0
        %                     if nPts(i) < 1000000
        %                         rp = nPts(i);
        %                     else
        %                         rp = 1000000;
        %                     end
        %                     FIRA.raw.analog.data(ind:ind+rp-1, end) = ...
        %                         fread(fid, [rp 1], 'int16').*ADtoMVs(i).*10.2;
        %                     ind = ind+rp+1;
        %                     nPts(i) = nPts(i) - rp;
        %                 end
        %                 toc
        %             else
        %             end

    elseif types(i) == 6 && keep_markers
        %%%
        % MARKER
        %%%
        %       
        %%%
        % MARKER
        %%%
        %       
% commented out, LD 02-21-2007
% in new dotsX system, nMarks could be >1. 
% The first chunk is for DIO, the other three for Bits 0-15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if nMarks(i) ~= 1 
%             error('bad number of markers in file')
%         end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % find data section
        fseek(fid, offsets(i), 'bof');
        
        % array of timestamps, in ms
        ts = time_offset + fread(fid, [counts(i) 1], 'int32')*tscale;
        
        % read the name -- for strobed data, should always be 'DIO'
        mname = fread(fid, [1 64], '*char');
        % original code for NEX files
        % if ~strncmp('DIO', mname, 3)
        %    error('unknown marker name')
        % end
        if ~strncmp('Value', mname, 5)
            error('unknown marker name')
        end
        
        % now collect the marker data... alas, they're stored as strings
        % new, fast way
        % m      = fscanf(fid, '%c', [markLs(i) counts(i)])'-48;
        m      = fread(fid, [markLs(i) counts(i)], 'uchar')'-48;
        ecodes = [ecodes; [ts m*[10.^[markLs(i)-2:-1:0] 0]']];
        %% old, slower way:
        %m = zeros(counts(i), markLs(i));
        %for p = 1:counts(i)
        %    m(p, :) = fread(fid, [1 markLs(i)], 'char');
        %end
        %% convert ascii to string back to nums
        %ecodes = [ecodes; [ts str2num(char(m(:,1:end-1)))]];
    end
end

% close the file
fclose(fid);

% store list of analog channels we kept
if keep_analog
    
    % set function to parse analog data
    FIRA.raw.analog.func = @parsePLX_aData;

    % set up an index and save the array size
    FIRA.raw.analog.params.aind = 1;
    FIRA.raw.analog.params.asz  = size(FIRA.raw.analog.data, 1);
end

% little kludgy for early problem with plexon files -- not storing allOff code
% (I toggled the file immediately before dropping the code)
lene = length(ends);
if ~any(ecodes(:,2)==4904) && sum(ecodes(:,2)==1005) == lene && lene > 0
    ecodes = [ecodes; [ends 4904*ones(lene,1)]];
    [I,Y] = sort(ecodes(:,1)); % JD: bring them in correct temporal order
    ecodes = ecodes(Y,:); % (index-based code selection in getDTF_trialByIndices fails otherwise)
end

% extract ecodes, dio commands, matlab commands, and matlab arguments
% from the list of "markers"
parseEC_rawCodes(ecodes);
