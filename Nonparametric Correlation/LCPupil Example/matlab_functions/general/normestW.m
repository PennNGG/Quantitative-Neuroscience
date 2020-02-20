function [m,s,m_se,s_se,p_s]=normestW(x,e)
% [m,s,m_se,s_se,p_s]=normestW(x,e)
%
% estimate mean and SD of a normal distribution from a measurement vector with associated uncertainties
% model: all measurements are based on picks from the same normal distribution
% J. Ditterich, 9/12/02
%
% x is the measurement vector
% e is the vector of the associated errors/uncertainties (SE)
% m is the estimated mean
% s is the estimated SD
% m_se is the standard error of the estimated mean
% s_se is the standard error of the estimated SD
% p_s is the p value for the estimated SD being significantly different from 0 (based on a t-test)

% This is the problem we are solving (likelihood function):
%
%                                                                                 2
%            inf                               2                           -(x-m )
%                        1               -(x-m)            1                    i
% L = prod { int  [ ------------ * exp ( ------- ) * ------------- * exp ( -------- ) ] dx }
%                   sqrt(2*pi)*s             2       sqrt(2*pi)*s               2
%            -inf                         2*s                    i          2*s
%                                                                              i
%
% m is the estimated mean, s the estimated SD,
% m  is measurement i, and s  is the associated uncertainty (SE)
%  i                        i

%check
if length(x)~=length(e)
    error('Both input vectors need to be of equal length!');
end;

% maximum likelihood estimation
pars=fminsearch('normestW_ll',[mean(x) std(x)],[],x,e);
m=pars(1);
s=pars(2);

% standard errors
dmm=0;
dms=0;
dss=0;

% The elements of the Hessian are:
%
%  2
% d LL             1
% ---- = - sum ( ------ )
%   2             2   2
% dm             s +s
%                    i
%
%  2                  m-m                
% d LL                   i
% ----- = 2*s*sum ( --------- )
% dm ds               2   2 2
%                   (s +s  )
%                        i
%
%                           2                   2
%  2                  (m-m )              (m-m )
% d LL       2            i                   i           2           1                 1
% ---- = -4*s *sum ( --------- ) + sum ( --------- ) + 2*s *sum ( --------- ) - sum ( ------ )
%   2                  2   2 3             2   2 2                  2   2 2            2   2
% ds                 (s +s  )            (s +s  )                 (s +s  )            s +s
%                         i                   i                        i                  i

for i=1:length(x)
    dmm=dmm-1/(s^2+e(i)^2);
    dms=dms+2*s*(m-x(i))/(s^2+e(i)^2)^2;
    dss=dss-4*s^2*(m-x(i))^2/(s^2+e(i)^2)^3+(m-x(i))^2/(s^2+e(i)^2)^2+2*s^2/(s^2+e(i)^2)^2-1/(s^2+e(i)^2);
end;

h=[dmm dms;dms dss];
h_inv=-h^-1;
m_se=sqrt(h_inv(1,1));
s_se=sqrt(h_inv(2,2));

% t-test
p_s=1-2*(tcdf(abs(s)/s_se,length(x)-2)-.5);
