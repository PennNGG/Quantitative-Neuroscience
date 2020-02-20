function [p,logp,lognorm,logdata] = studentpdf(X,mu,sigma2,alpha)
% function [p,logp,lognorm,logdata] = studentpdf(X,mu,sigma2,alpha)
% univariate Student's t pdf

lognorm = gammaln(alpha+.5) - gammaln(alpha) - .5*(log(2*pi)+log(alpha)+log(sigma2));
logdata = -(alpha+.5).*log((1 + ((X - mu).^2)./(2*alpha.*sigma2)));

logp = lognorm + logdata;

p = exp(logp);
        