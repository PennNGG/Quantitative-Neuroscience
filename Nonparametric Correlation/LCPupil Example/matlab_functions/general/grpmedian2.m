function [y,ysem,N] = grpmedian2(x,grp1,grp2)
% function [y,ysem,N] = grpmedian2(x,grp1,grp2)
% 2D version of grpmedian.m

vals1 = unique(grp1);
vals2 = unique(grp2);

y = zeros(length(vals1),length(vals2));
N = y;

for i = 1:length(vals1)
    for j = 1:length(vals2)
        y(i,j) = median(x(grp1==vals1(i) & grp2==vals2(j)));
        N(i,j) = sum(grp1==vals1(i) & grp2==vals2(j));
    end
end

if nargout>1
    ysem = zeros(length(vals1),length(vals2));
    
    for i = 1:length(vals1)
        for j = 1:length(vals2)
            ysem(i,j) = std(bootstrp(200,@median,x(grp1==vals1(i) & grp2==vals2(j))));
        end
    end
    
end
