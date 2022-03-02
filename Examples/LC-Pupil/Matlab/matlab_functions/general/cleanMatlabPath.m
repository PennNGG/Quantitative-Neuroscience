function cleanMatlabPath
%   I hate that matlab adds hidden folders like .svn.  Remove them

p = path;
each = textscan(p, '%s', 'Delimiter', ':');
n = length(each{1});
betterPath = '';
for ii = 1:n
    if isempty(strfind(each{1}{ii}, '.svn')) && ...
            isempty(strfind(each{1}{ii}, '.git'))
        betterPath = sprintf('%s:%s', betterPath, each{1}{ii});
    end
end
path(betterPath)