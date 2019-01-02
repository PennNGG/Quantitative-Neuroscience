%
% example to show how to to do McNemar's test
%
%
%
% 
%                 Probe 1 itch    Probe 1 no itch
% Probe 2 itch    11              6
% Probe 2 no itch 10              24

df=1;
f12=6;
f21=10;

ChiSquare=(abs(f12-f21)-1)^2/(f12+f21);

p=1-chi2cdf(ChiSquare,df);

disp(['H0:proportion of persons experiencing itch is the same with both probes: p=' num2str(p)]);