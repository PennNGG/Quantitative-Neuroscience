function [ainfo_, adata_, file_type_] = readREX_aFile(filename)
%function [ainfo_, adata_, file_type_] = readREX_aFile(filename)
%
%  Opens and reads data from the 'A' (Analog) REX file
%
% Arguments:
%   filename  ... full file name (including 'A' suffix) with path
%
% Returns:
%   ainfo_     ... info about the analog data (see below)
%   adata_     ... the analog data
%   file_type_ ... 'l' is little endian, which is for "raw" files that 
%                     have not been pcr2s'd;
%                  'b' is big endian, which is what pcr2s generates
%

% 1/23/01 created by jig from openAfile and openEfile
%

% in case we have to bail
ainfo_     = [];
adata_     = [];
file_type_ = [];
if nargin < 1 || isempty(filename) 
  return
end

fid = fopen(filename, 'r', 'l');
if fid < 1
  return
end
  
% found the file, so store the file type
file_type_ = 'l';

% use magic number in Afile to determine file format:
%   'l' is little endian, which is for "raw" files that 
%        have not been pcr2s'd;
%   'b' is big endian, which is what pcr2s generates
magicn = 1210832817;
mag    = 0;

% first try little endian
% this is the raw (NOT pcr2s'd) version
% read in 32-bit words, looking for the magic number
[a, count] = fread(fid, inf, 'int32');
if ~isempty(a)
  mag = length(find(a==magicn));
  off = -1;
end
% if it didn't work, try big endian
if mag ~= 1
  % close the little endian, open the big endian
  % this is the pcr2s'ed version
  fclose(fid);
  fid = fopen(filename, 'r', 'b');
  % read in 32-bit words, looking for the magic number
  [a, count] = fread(fid, inf, 'int32');
  if ~isempty(a)
	 mag        = length(find(a==magicn));
	 off        = 0;
	 file_type_ = 'b';
  end
end

if mag == 1
  % rewind the file
  fseek(fid, 0, -1);
  % read 16-bit words, looking for trial-marker magic numbers
  adata_ = fread(fid, inf, 'int16');
  % rewind the file to read in the sampheader
  fseek(fid, 0, -1);
  % find the location of the first magic number
  % "off" is vital because of byte-flipping in 
  % different versions of the raw file
  magics = find(adata_==18475) + off;
end

% did we find all the magic numbers?
if mag ~= 1 | isempty(magics)
  adata_   = [];
  return;
end

% if we read a non-pcr2s'd version, then
% we need to flip the 32-bit fields
% (because the rest of the code is set up
% to read the pcr2s'd version)
if file_type_ == 'l'
  for i = [0 4 6]
	 m1s                = adata_(magics+i);
	 adata_(magics+i)   = adata_(magics+i+1);
	 adata_(magics+i+1) = m1s;
  end
end
	 
% we're good, read the data
sampoff = (magics(1)-1)*2;

% format the sample header struct:
ainfo_ = struct('signum',0,'maxrate',0,'minrate',0,'subfr_num',0,'mfr_num',0,...
						'mfr_dur',0,'fr_sa_cnt',0,'mfr_sa_cnt',0,'gvname',[],'title',[],...
						'store_rate',[],'store_order',[]);

% the purpose of the next part of openAfile is to generate Asamp.store_order,
% which will tell the various subsidiary parts of ComposeAnalog4trial how to
% distribute the record data among signals. 

% for instance, if there are 
% signal 1, 125hz,
% signal 2, 1000hz,
% signal 3, 500hz, then the store_order would look like:
% [1 2 3 2 2 3 2 2 3 2 2 3 2]

% Thus, the store order array is used as the collation filter through
% which ComposeAnalog4trial will distribute analog data.

% the size of the store_order array will be checked against fr_sa_cnt
fseek(fid,sampoff,-1);

% reading in the record header
magic  = fread(fid,1,'int32'); % garbage in non-pcr2s'd files
recnum = fread(fid,1,'int16');
ecodeA = fread(fid,1,'int16');
ectim  = fread(fid,1,'int32'); % garbage in non-pcr2s'd files
ucode  = fread(fid,1,'int32'); % garbage in non-pcr2s'd files
cont   = fread(fid,1,'int16');
nbytz  = fread(fid,1,'int16');

% reading in the sample header
% note: the vast majority of the data in the sample header is currently
% useless, but is stored for potential future compatibility
maxsig              = fread(fid,1,'int16'); % max. number of signals
fr_arr_size         = fread(fid,1,'int16'); % frame array size
maxcal              = fread(fid,1,'int16'); % max # of calibrations
lname               = fread(fid,1,'int16'); % length of string names

ainfo_.signum       = fread(fid,1,'int16'); % actual number of signals
ainfo_.maxrate      = fread(fid,1,'int16'); % maximum sample rate
ainfo_.minrate      = fread(fid,1,'int16'); % minimum sample rate
ainfo_.subfr_num    = fread(fid,1,'int16'); % number of subframes per frame
ainfo_.mfr_num      = fread(fid,1,'int16'); % number of frames per master frame
ainfo_.mfr_dur      = fread(fid,1,'int16'); % msec duration of master frame
ainfo_.fr_sa_cnt    = fread(fid,1,'int16'); % number of stored samples in a frame
ainfo_.mfr_sa_cnt   = fread(fid,1,'int16'); % same but for master frame

ad_channels         = fread(fid,1,'int16');  % # of channels on a/d converter
ad_res              = fread(fid,1,'int16');  % a/d resolution in bits: 12/16
ad_rcomp            = fread(fid,1,'int16');  % radix compensation
ad_ov_gain          = fread(fid,1,'int16');  % 
datumsz             = fread(fid,1,'int16');  % size of sample datum in bytes

% offsets of sample data
ad_rate_bo          = fread(fid,1,'int16');  
store_rate_bo       = fread(fid,1,'int16');
ad_calib_bo         = fread(fid,1,'int16');
shift_bo            = fread(fid,1,'int16');
gain_bo             = fread(fid,1,'int16');
ad_delay_bo         = fread(fid,1,'int16');
ad_chan_bo          = fread(fid,1,'int16');
frame_bo            = fread(fid,1,'int16');
gvname_bo           = fread(fid,1,'int16');
title_bo            = fread(fid,1,'int16');
calibst_bo          = fread(fid,1,'int16');
var_data_begin      = fread(fid,1,'int16');

% sample data
ad_rate             = fread(fid,[maxsig 1],'int16');    % acquisition rates
ainfo_.store_rate   = fread(fid,[maxsig 1],'int16');    % storage rates
ad_calib            = fread(fid,[maxsig 1],'int16');    % calibration numbers
shift               = fread(fid,[maxsig 1],'int16');    % shift factors
gain                = fread(fid,[maxsig 1],'int16'); 
ad_delay            = fread(fid,[maxsig 1],'int16');    % filter delays
ad_chan             = fread(fid,[maxsig 1],'int16');    % a/d channel for each a/d signal
frame               = fread(fid,[fr_arr_size],'int16'); % the frame array
ainfo_.gvname       = fscanf(fid,'%c',[lname maxsig]);  % signal glob var names
ainfo_.title        = fscanf(fid,'%c',[lname maxsig]);  % signal titles
calibst             = fscanf(fid,'%c',[lname maxsig]);  % calibration factor ascii strings

% pad the string arrays
if size(ainfo_.title,2)<maxsig
  for i = size(ainfo_.title,2)+1:maxsig
	 concat([ainfo_.title]','.',' ');
  end
end

if size(ainfo_.gvname,2)<maxsig
  for j = size(ainfo_.gvname,2)+1:maxsig
	 concat([ainfo_.gvname]','.',' ');
  end
end

% close the Afile
fclose(fid);

% now the construction of store_order []
% Within the frame array, each subframe goes like this:
% #_of stored samples, samp_spec, samp_spec,... -1
% Within a given subframe, not all samp_specs correspond to stored samples;
% this is why there is a test to see if bit 15 is flagged - if so, the
% sample was acquired for the frame but not stored. 
%
% Also, within the frame array, -1 indicates the end of a subframe, and -2
% indicates the end of the frame array.
%
% Since the low byte of a stored sample indicates the channel, store_order
% is constructed simply by adding the channels of stored samples to the
% array until the frame pointer equals -2, at which point the loop ends. 
%
% Gratis to Art Hays for inspiration and advice.
%
% 1/27/02 jig changed to more efficient matrix ops

fs  = frame(1:min(find(frame==-2))-1);  % get until end of frame
fs  = fs(~bitget(abs(fs),15));          % get rid of bit-15 numbers
sfs = [0 find(fs==-1)'];                % get indices of subframes
for i = 1:length(sfs)-1
	if fs(sfs(i)+1) > 0 % first is # of stored samples
		ainfo_.store_order = [ainfo_.store_order ...
		  double(uint8(fs(sfs(i)+2:sfs(i+1)-1)))'+1];
	end
end
