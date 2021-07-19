function y = loggampdf(x,a,b)
% function y = loggampdf(x,a,b)
% log of gampdf, faster than taking log of Matlab's gampdf output

y = -gammaln(a) - a.*log(b) + (a-1).*log(x) - x./b;
