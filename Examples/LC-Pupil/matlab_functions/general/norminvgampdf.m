function [p,logp] = norminvgampdf(Mu,Sigma2,alpha,beta,mu0,lambda)
% [p,logp] = norminvgampdf(Mu,Sigma2,alpha,beta,mu0,lambda)
% Normal-inverse gamma pdf: conjugate prior to univariate normal pdf with unknown mean
% and variance
%
% parameters and formula base on https://en.wikipedia.org/wiki/Normal-inverse-gamma_distribution
%

Sigma = sqrt(Sigma2);

logp = .5*log(lambda) - log(Sigma) - .5*log(2) - .5*log(pi) + ...
    alpha.*log(beta) - gammaln(alpha) - (alpha+1).*log(Sigma2) + ...
    (-2*beta - lambda.*(Mu-mu0).^2)./(2*Sigma2);

p = exp(logp);