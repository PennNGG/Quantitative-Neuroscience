function checkGUI_editValue(h, min_val, max_val)
% function checkGUI_editValue(h, min_val, max_val)
%
% called when any value in an edit box is changed...
%

% check that the value is within range
val = sscanf(get(h, 'String'), '%lf');

if isempty(val)
    set(h, 'String', 0);
end

if nargin < 2
    min_val = -9999;
end
if val < min_val
    set(h, 'String', min_val);
end

if nargin < 3
    max_val = 9999;
end
if val > max_val
    set(h, 'String', max_val);
end
