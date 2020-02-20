function nll=normestW_ll(pars,x,e)
% calculate log likelihood for estimating mean and SD of a normal distribution when given measurements with errors
% J. Ditterich, 9/12/02

nll=0;
m=pars(1);
s=pars(2);

% This is the formula for the log likelihood:
%
%                         2
%                   (m-m )
%                       i                       2   2
% log(L) = sum ( - ---------- - log(sqrt(2*pi*(s +s  ))) )
%                      2   2                       i
%                  2*(s +s  )
%                         i
%
% m is the estimated mean of the distribution, s is the estimated SD,
% m  is measurement i, and s  is the uncertainty (SE) of measurement i
%  i                        i

for i=1:length(x)
    nll=nll+(m-x(i))^2/2/(s^2+e(i)^2)+log(sqrt(2*pi*(s^2+e(i)^2)));
end;
