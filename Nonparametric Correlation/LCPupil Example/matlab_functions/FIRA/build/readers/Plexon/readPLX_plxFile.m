function error_ = readPLX_plxFile(filename)
% function error_ = readPLX_plxFile(filename)
%
% Reads raw data from a "plx" file created from Plexon
% putting the data into the global
%  FIRA data structure, as follows:
%
%    FIRA.header.filename ... filename
%    FIRA.header.filetype ... 'plx'
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

% Long Ding 2009-05-05, modified from readPLX_nexFile(filename)
%   University of Pennsylvania
%
% Long Ding 2014-03-17, modified to run with Plexon SDK bundle Aug 29 2013



% parse arguments
if nargin < 1 || isempty(filename)
    error_ = 1;
    return
end

% try opening file with different suffices
ss  = {''; '.plx'; '.PLX'};
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

% % check the magic number
% magic = fread(fid, 1, 'int32');
% if magic ~= 827868494
%     error_ = 3;
%     return
% end

%%%
% FILL IN FIRA HEADER INFO
%%%
global FIRA

error_ = 0;
FIRA.header.filename = {fname};
FIRA.header.filetype = 'plx';
FIRA.header.paradigm = 'xxx';

[OpenedFileName, version, freq, comment, Trodalness, NPW, PreThresh, ...
   SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = ...
   plx_information(fname);

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
% if ~isempty(FIRA.raw.ecodes)
%     time_offset = FIRA.raw.ecodes(end, 1);
% else
%     time_offset = 0;
% end


% not sure if these two lines are useful
% nvar    = fread(fid, 1, 'int32');
% fseek(fid, 260, 'cof');

% % %% show info
% % %disp(strcat('version = ', num2str(version)))
% % %disp(strcat('frequency = ', num2str(freq)))
% % %disp(strcat('duration (sec) = ', num2str((tend - tbeg)/freq)))
% % %disp(strcat('number of variables = ', num2str(nvar)))
% % 
% % %%%
% % % read the NexVarHeaders
% % %%%
% % types   = zeros(nvar, 1);
% % names   = zeros(nvar, 64);
% % offsets = zeros(nvar, 1);
% % counts  = zeros(nvar, 1);
% % sfs     = zeros(nvar, 1);
% % ADtoMVs = zeros(nvar, 1);
% % nPts    = zeros(nvar, 1);
% % nMarks  = zeros(nvar, 1);
% % markLs  = zeros(nvar, 1);
% % 
% % for i=1:nvar
% %     types(i)    = fread(fid, 1,      'int32');
% %     var_version = fread(fid, 1,      'int32');
% %     names(i, :) = fread(fid, [1 64], 'char');
% %     offsets(i)  = fread(fid, 1,      'int32');
% %     counts(i)   = fread(fid, 1,      'int32');
% %     dummy       = fread(fid, 32,     'char');
% %     sfs(i)      = fread(fid, 1,      'double');
% %     ADtoMVs(i)  = fread(fid, 1,      'double');
% %     nPts(i)     = fread(fid, 1,      'int32');
% %     nMarks(i)   = fread(fid, 1,      'int32');
% %     markLs(i)   = fread(fid, 1,      'int32');
% %     dummy       = fread(fid, 68,     'char');
% % end
% % 
% % names       = char(names);
% % ecodes      = [];
% % ends        = [];
% % tscale      = 1000/freq;
% % sf          = [];
% % 
% % % find & verify all the analog channels
% % ais = find(types==5);
% % if keep_analog && ~isempty(ais)
% % 
% %     % get channel names
% %     ch = nans(size(ais));
% %     for ii = 1:length(ais)
% %         ch(ii) = sscanf(names(ais(ii),:), 'AD%f');
% %     end
% % 
% %     % analog/verify does the hard work of checking the channels, etc
% %     Lgood = verify(FIRA.spm.analog, ch, sfs(ais));
% %     types(ais(~Lgood)) = -99;
% % else
% %     types(ais) = -99;
% % end

%%%
% read the data
%%%
[tscounts, wfcounts, evcounts, adcounts] = plx_info(OpenedFileName,1);

%% read spikes
if keep_spikes
%     [tscounts, wfcounts, evcounts] = plx_info(OpenedFileName,1);
    [iunit, ich] = find(tscounts>0);
    n_units = length(iunit);
    % verify spikes
    if n_units>0
        for i=1:n_units
            ver = verify(FIRA.spm.spikes, [ich(i)-1 iunit(i)-1]);
            [nt, tt] = plx_ts(OpenedFileName, ich(i)-1 , iunit(i)-1 );
 %         % save <timestamp (ms)> <id>, where id = 1000*channel+unit
           id = ones(nt,1)*(1000*(ich(i)-1) + iunit(i)-1);
           splist = [tt*1000 id];
           FIRA.raw.spikes = [FIRA.raw.spikes; splist];
        end
    end
end

%% read analog data
if keep_analog>0
%     FIRA.spm.analog;
    % find analog channels that have signals, use evcounts(301:316) for the
    % 16 analog channels
    % <timestamp (ms)> <ch1 (mV)> <ch2 (mV)>...
    % adcounts = evcounts(300:315);
    ind_ads = find(adcounts>0);
    [nad,adgains] = plx_adchan_gains(OpenedFileName);
    [nad,adnames] = plx_adchan_names(OpenedFileName);
    [n,adfreq] = plx_adchan_freqs(OpenedFileName);

    % find & verify all the analog channels
    Lgood = verify(FIRA.spm.analog, ind_ads', adfreq);
    ind_ads = ind_ads(Lgood);

    if ~isempty(ind_ads)
        n_ch = length(ind_ads);
        allad = cell(n_ch,1);
        adfreq = zeros(n_ch,1); nad = adfreq; 
        for i=1:length(ind_ads)
            [adfreq(i), nad(i), tsad, fnad, allad{i}] = plx_ad_v(OpenedFileName, ind_ads(i)-1);
        end
 
        if length(unique(adfreq))==1
            t = zeros(nad(1),1);
            k = 1;
            timestep = 1.0/adfreq(1);
            for j = 1:length(tsad)
                t(k:k+fnad(j)-1) = [0:1:fnad(j)-1]*timestep + tsad(j);
                k = k+fnad(j);
            end
            FIRA.raw.analog.data = t*1000;
            for i=1:n_ch
                FIRA.raw.analog.data = [FIRA.raw.analog.data allad{i}/adgains(ind_ads(i))];%*FIRA.analog.gain(i)*1000]; 
            end
        else
            disp('multiple sampling rates, not supported by current version of readPLX_plxFile.m');
            return
        end
        
        % Save aquire rates
        FIRA.analog.acquire_rate = adfreq(:);
        FIRA.analog.store_rate   = adfreq(:);
    end
end

%% read events 
% per readPLX_nexFile format, save to ecodes
% <timestamp (ms)> <ecode>
% if evcounts(257) == 0
%     disp('no Strobed event');
%     return
% else
%     [nevs, tsevs, svStrobed] = plx_event_ts(OpenedFileName, 257);
% end

[nevs, tsevs, svStrobed] = plx_event_ts(OpenedFileName, 257);
ecodes = [tsevs*1000 svStrobed];

%% close file
plx_close(OpenedFileName);

% store list of analog channels we kept
if keep_analog
    
    % set function to parse analog data
    FIRA.raw.analog.func = @parsePLX_aData;

    % set up an index and save the array size
    FIRA.raw.analog.params.aind = 1;
    FIRA.raw.analog.params.asz  = size(FIRA.raw.analog.data, 1);
end
parseEC_rawCodes(ecodes);

