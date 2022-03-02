function indices_ = find_first_code_indices(all_codes, start_codes, code)
% function indices_ = find_first_code_indices(all_codes, start_codes, code)
% 
% returns array of indices corresponding to the first instances
% of "code" in "all_codes" subsequent to each instance of 
% "start_codes"

all_codes = all_codes(:)';
start_codes 
categories = categories(:)';
data       = data(:);

a = repmat(categories, length(data), 1);
b = repmat(data, 1, length(categories));
d = b - a;
d(d<=0)=999;
[y,I] = min(d,[],2);
nears_ = categories(I)';
