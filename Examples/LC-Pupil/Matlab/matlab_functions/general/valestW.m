function [val,se]=valestW(x,e)
% [val,se]=valestW(x,e)
%
% estimate a value (and the associated SE) from a measurement vector with associated uncertainties
% model: all observations were attempts to measure the same value
% J. Ditterich, 9/02
%
% x is the measurement vector
% e is the vector of the associated errors/uncertainties (SE)
% val is the estimated value
% se is the associated SE

% This is the problem we are solving (likelihood function):
%
%                                           2
%                                  -(val-m )
%                  1                      i
% L = prod [ ------------- * exp ( ---------- ) ]
%            sqrt(2*pi)*s                2
%                        i           2*s
%                                       i
%
% val is the estimated value,
% m  is measurement i, and s  is the associated uncertainty (SE)
%  i                        i

%check
if length(x)~=length(e)
    error('Both input vectors need to be of equal length!');
end;

% eliminate zeros in e
ind=find(e==0);
e(ind)=1e-12; % SMALL

% maximum likelihood estimation
sum_1=0;
sum_2=0;

for i=1:length(x)
    sum_1=sum_1+x(i)/e(i)^2;
    sum_2=sum_2+1/e(i)^2;
end;

val=sum_1/sum_2;
se=sqrt(1/sum_2);
