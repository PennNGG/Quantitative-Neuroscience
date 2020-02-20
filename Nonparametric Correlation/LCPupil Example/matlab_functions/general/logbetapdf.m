function logp = logbetapdf(x,alpha,beta)
% function logp = logbetapdf(x,alpha,beta)
% log of betapdf, faster than taking log of Matlab's betapdf output

logp = (alpha-1).*log(x) + (beta-1).*log(1-x) - betaln(alpha,beta);