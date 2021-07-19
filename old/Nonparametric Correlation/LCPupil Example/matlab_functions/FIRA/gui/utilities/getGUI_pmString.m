function string_ = getGUI_pmString(menu_handle)
% string_ = getGUI_pmString(menu_handle)
%
% get the curretly selected string from a pop-up menu

string_array  = get(menu_handle, 'String');
string_       = string_array{get(menu_handle, 'Value')};