function y = loglognpdf(x,mu,sigma)
% function y = loglognpdf(x,mu,sigma)
% log of log-normal pdf

x(x <= 0) = Inf;

y = -0.5 * ((log(x) - mu)./sigma).^2 - log(x) - log(sqrt(2*pi)) - log(sigma);
