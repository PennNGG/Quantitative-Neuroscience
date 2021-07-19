function ns_ = nancells(m, n)
% function ns_ = nancells(m, n)
%
% makes an array of cells, each with just a 'nan'
% element

if nargin < 1
    m = 1;
end
if nargin < 2
    n = 2;
end

ns_ = cell(m, n);
for i = 1:m
    for j = 1:n
        ns_{i,j} = nan;
    end
end

