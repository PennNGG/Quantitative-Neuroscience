function setPLOT_panelLabel(ax, label,x_offset,y_offset)
% function setPLOT_panelLabel(ax, label)

if nargin < 1 || isempty(ax)
    ax = gca;
end

if nargin < 2 || isempty(label)
    label = 'A';
elseif ~ischar(label)
    label = char(96+label);
end

axes(ax);
xl = get(ax, 'XLim');
yl = get(ax, 'YLim');

if nargin < 3 || isempty(x_offset)
    x_offset = 0.2;
    y_offset = 1.25;
end



if strcmp(get(ax, 'YScale'), 'linear')
    h=text(xl(1)-(xl(2)-xl(1))*x_offset,yl(1)+(yl(2)-yl(1))*y_offset, label);
else
    h=text(xl(1),10.^(log10(yl(2))+(log10(yl(2))-log10(yl(1))).*0.1), label);
end
set(h,'FontSize',14,'FontWeight','bold');
