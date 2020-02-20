function ecodes_ = readREX_eFile(filename, file_type)
% function ecodes_ = readREX_eFile(filename, file_type)
%
% Opens and reads data from the 'E' (ecode) file saved by REX
% File is of the form:
%  <byte1 byte2>             = unsigned short, event #
%  <byte3 byte4>             = signed short, event code
%  <byte5 byte6 byte7 byte8> = signed long, event time
%
% Arguments:
%  filename    ... should include 'E' suffix
%  file_type   ... 'l' is little endian, which is for "raw" files that 
%                       have not been pcr2s'd;
%                     'b' is big endian, which is what pcr2s generates
%                    If none given, try both
%
% Returns:
%   ecodes_  ... nx2 matrix of ecodes, columns are <timestamp> <code> 
%
% 1/24/02 created by jig from openEfile
%

% check args
if nargin < 1 || isempty(filename)
    return;
end

if nargin < 2 || isempty(file_type)
    file_type = {'l' 'b'};  % try both file types
else
    file_type = {file_type};
end

% return vals if we find nothing
ecodes_ = [];

% try each file type
for ft = 1:length(file_type)
    
    % open the file
    fid = fopen(filename, 'r', file_type{ft});
    if fid > 0
        
        % IGNORE FIRST TWO BYTES (EVENT NUMBER)
        % 1: EVENT NUMBER
        %[q,count]     = fread(fid,[512 1],'uchar'); % skip 1st 512 bytes
        %[e1,count]    = fread(fid,[4,inf],'uint16');% count is unsigned short (16 bit)
        %e1(2:4,:)     = [];
        %frewind(fid);
        
        % 1: EVENT CODE ... cycle all the way through
        [q,count]     = fread(fid,[512 1],'uchar'); % skip 1st 512 bytes
        [e1,count]    = fread(fid,[4,inf],'int16'); % code is signed short (16 bit)
        e1([1 3 4],:) = [];
        
        % 2: EVENT TIME ... cycle through again
        frewind(fid);
        [q,count]     = fread(fid,[512 1],'uchar'); % skip 1st 512 bytes
        [e2,count]    = fread(fid,[2,inf],'uint32');% time is unsigned long (32 bit)
        e2(1,:)       = [];
        
        % close the file
        fclose(fid);
        
        % ecodes_ matrix is <timestamp> <code>
        % do a dumb check to make sure values are reasonable:
        % check that at least every 1000 codes is STARTCD
        if length(find(e1==1005))>length(e1)/1000
            ecodes_ = [e2' e1'];
            return
        end
    end
end
