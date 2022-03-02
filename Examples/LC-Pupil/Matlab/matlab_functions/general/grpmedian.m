function [y,ysem,N,ylow,yhigh] = grpmedian(x,grp)
% function [y,ysem,N,ylow,yhigh] = grpmedian(x,grp)
% INPUTS: x = data, grp = grp to which x belongs
%
% OUTPUTS: 
% y = median of x by each unique value in grp, ysem
% ysem = bootstrapped standard error on y
%
% ylow = 25th percentile of bootstrapped samples (NOT bootstrapped 25th
% percentile)
% yhigh = 75th percentile of bootstrapped samples

[vals,indsU,indSamp] = unique(grp);

if iscell(grp)
    vals = [1:numel(vals)]';
    grp = indSamp;
end

y = zeros(length(vals),size(x,2));
N = zeros(length(vals),1);

for i = 1:length(vals)
    y(i,:) = median(x(grp==vals(i),:));
    N(i) = sum(grp==vals(i));
end

if nargout<=3 & nargout>1
   ysem = zeros(length(vals),size(x,2));
   
   for i = 1:length(vals)
       ysem(i,:) = std(bootstrp(1000,@median,x(grp==vals(i),:)));
   end
    
end


if nargout>3
   ysem = zeros(length(vals),size(x,2));
   ylow = zeros(length(vals),size(x,2));
   yhigh = zeros(length(vals),size(x,2));
   
   for i = 1:length(vals)
       samps = bootstrp(1000,@median,x(grp==vals(i),:));
       ysem(i,:) = std(samps);
       ylow(i,:) = prctile(samps,25);
       yhigh(i,:) = prctile(samps,75);
   end
    
end


