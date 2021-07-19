function err_ = errFIT_exp1(fits, data)
%
% fits are:
%   tau ... time constant
%   b   ... upper asymptote
%   B0  ... offset term of coh dependence
%   B1  ... slope term of coh dependence
%
% data is:
%   session
%   thresh
%   err

%err_ = sum(abs(data(:,2)-valFIT_exp1(fits, data(:,1)))./data(:,3));
err_ = sum((data(:,2)-valFIT_exp1(fits, data(:,1))).^2./data(:,3));
