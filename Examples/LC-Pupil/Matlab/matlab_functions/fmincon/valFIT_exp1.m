function val_ = valFIT_exp1(fits, data)
%
% fits are:
%   tau ... time constant
%   B0  ... offset
%   B1  ... scale
%
% data is:
%   x-value (session index)
val_ = fits(2) + fits(3)*exp(-data(:,1)/fits(1));
