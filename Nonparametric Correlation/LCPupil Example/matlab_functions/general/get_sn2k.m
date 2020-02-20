function sn2k_ = get_sn2k(n)
% function sn2k_ = get_sn2k(n)
%
% Get Stirling Number of the Second Kind
%   for n elements;
%
% S(n,m) is the number of ways of partitioning
%   a set of n elements into m nonempty sets


sn2k_ = nans(1, n);

for kk = 1:n
    sum = 0;
    for ii = 0:kk
        sum = sum + (-1)^ii.*nchoosek(kk,ii).*(kk-ii).^n;
    end
    sn2k_(kk) = 1./factorial(kk).*sum;
end
