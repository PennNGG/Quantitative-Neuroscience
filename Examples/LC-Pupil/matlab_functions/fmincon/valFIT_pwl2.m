function val_ = valFIT_pwl2(fits, data)
%
% fits are:
% data is:
%   x-value (session index)
mf  = max(data(:,1))*fits(1);
val_      = data(:,1).*fits(2) + fits(3);
val_(data(:,1)>mf) = mf*fits(2)+fits(3);
