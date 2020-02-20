function err_ = errFIT_sf(fits, data)
% function err_ = errFIT_sf(fits, data)

err_ = sum((data(:,2) - valFIT_sf(fits, data(:,1))).^2);
