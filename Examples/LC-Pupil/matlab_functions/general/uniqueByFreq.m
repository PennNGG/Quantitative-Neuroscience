function [U_,N_] = uniqueByFreq(input)
% function [U_,N_] = uniqueByFreq(input)
%
% Get the unique values of input array, sorted
% by their relative frequencies (most frequent first)

U_ = [];
N_ = [];

if nargin < 1 || isempty(input)
    return
end
input  = input(isfinite(input(:)));
[N, X] = hist(input, unique(input));
[N_,I] = sort(N, 2, 'descend');
U_     = X(I);
