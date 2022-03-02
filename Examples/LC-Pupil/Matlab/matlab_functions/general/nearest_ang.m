function nears_ = nearest_ang(data, categories)
% nears_ = nearest_ang(data, categories)
% 
% returns array of values from "categories" that are
% nearest to the given data. Assumes data are
% angles (in degrees)
a = repmat(mod(categories(:)',360), length(data), 1);
b = repmat(mod(data(:),360), 1, length(categories));
[y,I] = max(cos((a-b)*pi/180)*180/pi,[],2);
nears_ = categories(I)';
nears_(isnan(y)) = nan;
