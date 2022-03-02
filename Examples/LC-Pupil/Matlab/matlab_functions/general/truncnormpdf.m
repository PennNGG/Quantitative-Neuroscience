function [p,logp] = truncnormpdf(x,mu,sigma,x_min,x_max)
% function [p,logp] = truncnormpdf(x,mu,sigma,x_min,x_max)
% truncated normal pdf, which only differs from standard w.r.t.
% normalization

alpha = (x_min-mu)./sigma;
beta = (x_max-mu)./sigma;
eta = (x-mu)./sigma;
Z = normcdf(beta,0,1)-normcdf(alpha,0,1);

logp = -.5*(log(2*pi) + eta.^2) - log(sigma) - log(Z);

p = normpdf(eta,0,1)./(sigma.*Z);
