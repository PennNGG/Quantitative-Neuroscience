function classes_ = getClassesWithMethod(method, class_list)
% function classes_ = getClassesWithMethod(method, class_list)
%
% Utility for finding which classes listsed in "class_list"
%   have the given method

% Copyright 2006 by Joshua I. Gold
%   University of Pennsylvania

classes_ = {};
for cls = class_list
    if ismethod(cls{:}, method)
        classes_ = cat(2, classes_, cls);
    end
end
