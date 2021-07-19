function y = roundspec(x,dig)

fact = 10^dig;

y = round(x*fact)/fact;