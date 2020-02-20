function str_ = FS_txtToStruct(filename)
% load .txt file to struct
% 
% USAGE:
%   x = getML_txt(filename)
% 
%   INPUT:  filename is the file name of the file to be loaded.
%           The file has the following structure:    
%               1) a tab-delimited text file.
%               2) the first row of the file contains the name of the column
%               3) the second row of the file contains either 'f' or 's' (floating or string),
%                  which indicates the data type in the column.
%               4) the remaining file contains the data
%
%
%   OUTPUT: x is a struct that contains three fields: name, type and data.
%           'name' contains the name of the column
%           'type' contains the data type information (either floating or string)
%           'data' contains the data
%

% created by jcl on 2-2-05

delimiter = sprintf('\t');

if exist(filename, 'file')
    fid = fopen(filename);
    
    if fid == -1
        str_ = nan;
        fprintf('Cannot open file.\n')
        return
    end
else
    str_ = nan;
    fprintf('File does not exist\n')
    return
end    

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get data field names
% -assume that the first headerline contains the field name
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tmp = fgetl(fid);
lf = find(tmp == delimiter);

str_.name{1} = tmp(1:lf(1)-1);
for i = 1:length(lf)
    if i < length(lf)
        str_.name{i+1} = tmp(lf(i)+1:lf(i+1)-1);
    else
        str_.name{i+1} = tmp(lf(i)+1:end);
    end
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get data type (string or floating)
% -assume that the second headerline contains the data format
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
tmp  = fgetl(fid);
str_.type = {};
type = '';
ind = 1;
for i = 1:length(tmp)
    if tmp(i) ~= delimiter
        type(end+1) = '%';
        type(end+1) = tmp(i);
        type(end+1) = ' ';
        
        if tmp(i) == 'f'
            str_.type{ind} = 'f';
        elseif tmp(i) == 's'
            str_.type{ind} = 's';
        else
            str_.type{ind} = 'underfined';
        end
        ind = ind+1;
    end
end
type(end) = [];
fclose(fid);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Get data
% -skip the first two headerlines
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fid = fopen(filename);
str_.data = textscan(fid, type, 'headerlines', 2, 'delimiter', delimiter);
fclose(fid);
