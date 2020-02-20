function logp = lognormpdf(x,mu,sigma)
% function logp = lognormpdf(x,mu,sigma)
% log of univariate normal pdf, faster than taking log of Matlab's normpdf

logp = -log(sigma) - .5*log(2*pi) - ((x-mu).^2)./(2*(sigma.^2));