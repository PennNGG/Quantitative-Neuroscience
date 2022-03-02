function [p,logp] = mvstudentpdf(X,mu,Sigma,alpha)
% function [p,logp] = mvstudentpdf(X,mu,Sigma,alpha)
% Multivariate Student's t-distribution pdf
% X = data, mu = mean, Sigma = covariance matrix, alpha = df

X = X(:);
mu = mu(:);

d = length(X);

logp = gammaln(alpha + .5*d) - gammaln(alpha) + ...
    (-d/2)*log(2*pi*alpha) -.5*log(det(Sigma)) + ...
    (-(alpha+d)/2)*log(1 + (1/alpha)*(X - mu)'*inv(Sigma)*(X - mu));

p = exp(logp);
