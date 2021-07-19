% Z Test example
%
%               Condition 1     Condition 2
% Outcome A         18              10
% Outcome B         6               15
%
% Copyright 2019 by Yale E. Cohen, University of Pennsylvania

A1 = 18;
A2 = 10;
B1 = 6;
B2 = 15;

n1 = A1 + B1;
n2 = A2 + B2;
p1_hat = A1/n1;
p2_hat = A2/n2;
p = (A1+A2)/(n1+n2);
q = (B1+B2)/(n1+n2);
z = (p1_hat-p2_hat)/sqrt(p*q*(1/n1+1/n2));
p = 2*normcdf(-abs(z));

fprintf('H0:equal proporttions: p=%.4f', p)
