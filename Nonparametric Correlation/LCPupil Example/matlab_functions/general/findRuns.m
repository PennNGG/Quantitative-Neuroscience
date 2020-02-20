function [inds_, lengths_, Llong_] = findRuns(simpleArray, cutoff)
% function [inds_, lengths_, Llong_] = findRuns(simpleArray, cutoff)
%
% simpleArray -- array of -1/1
% cutoff -- min size of "long" run

inds_ = find(diff(simpleArray))+1;
lengths_ = diff(inds_);
inds_ = inds_(1:end-1);

if nargin > 1 && ~isempty(cutoff) && nargout > 1
    Llong_ = false(size(simpleArray));
    for li = find(lengths_ > cutoff)'
        Llong_(inds_(li):inds_(li)+lengths_(li)-1) = true;
    end
end
