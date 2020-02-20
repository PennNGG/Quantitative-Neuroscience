function logp = loginvnorm(x,mu,lambda)
% function logp = loginvnorm(x,mu,lambda)
% log of inverse normal pdf, where lambda is shape parameter and mu is mean

logp = .5*(log(lambda) - log(2*pi) - 3*log(x)) - lambda.*((x-mu).^2)./(2*x.*(mu.^2));