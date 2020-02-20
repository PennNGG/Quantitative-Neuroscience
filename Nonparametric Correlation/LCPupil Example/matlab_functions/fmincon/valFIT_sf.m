function val_ = valFIT_sf(fits, data)
% function val_ = valFIT_sf(fits, data)
%
% d'(x_t) = x_t^b / (a + (1 - a) * x_t ^ (b + w - 1)

val_ = data.^fits(2)./(fits(1) + (1 - fits(1)) .* data .^ (fits(2) + fits(3) - 1));