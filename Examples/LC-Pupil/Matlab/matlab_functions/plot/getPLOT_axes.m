function [axs_,fig_,cap_] = getPLOT_axes(num, wid, hts, cols, psh, psw, fs, al, cap)
% function [axs_,fig_,cap_] = getPLOT_axes(num, wid, hts, cols, psh, psw, fs, al, cap)
%
% panel separation height,width
%
% JNeurosci columns:
%   1   = 8.5 cm
%   1.5 = 11.6 cm
%   2   = 17.6 cm
%
% cap_ is optinal caption

% Figure number
if nargin < 1 || isempty(num)
    num = 1;
end

% total width -- default 1.5 columns
if nargin < 2 || isempty(wid)
    wid = 11.6;
end

% heights of each column
if nargin < 3 || isempty(hts)
    hts = 3.0;
end

% number of columns in each row
if nargin < 4 || isempty(cols)
    cols = {1};
end

% panel separation height
if nargin < 5 || isempty(psh)
    psh = 1.5;
end

% panel separation width
if nargin < 6 || isempty(psw)
    psw = 1.5;
end

% font size
if nargin < 7 || isempty(fs)
    fs = 12;
end

% get figure
fig_ = figure;
wysifig(fig_);
set(fig_, 'Color', [1 1 1]);
pos = get(fig_, 'Position');
% ax  = axes('Units', 'centimeters', 'position', [0 0 pos(3:4)]);
% plot([0 1 1 0 0], [0 0 1 1 0], 'w-')
% set(ax,'Box','off','XTick', [], 'YTick', [],'YColor','w','XColor','w', ...
%     'XLim', [0 1], 'YLim', [0 1])

% conditionally add label
% ax = axes('Units', 'inches', 'position', [7 10 .2 .2]);
% set(ax,'Visible','off');
% h=[text(0,1,al), text(0,0,sprintf('Figure %d',num))];
% set(h,'FontSize',14);
if nargin >= 8 && ~isempty(al)
    if num > 0
        h=[text(0.7,0.93,al), text(0.7,0.91,sprintf('Figure %d',num))];
    else
        h=text(0.7,0.93,al);
    end
    set(h,'FontSize',14);
    set(gca,'Visible', 'off')
end

% add possible caption
if nargin > 8 && ~isempty(cap)
    cap_ = text(0.1,0.1,sprintf('Figure %d:', num));
end

% useful variables
if length(hts) > 1
    nrow = length(hts);
elseif length(cols) > 1
    nrow = length(cols);
    hts  = hts*ones(1,nrow);
else
    nrow = 1;
end


% lt   = (8.5*2.54 - wid)/2;
% bot  = (11.0 - sum(hts) - psh*(nrow-1))/2;
lt   = (pos(3) - wid)/2;
bot  = (pos(4) - sum(hts) - psh*(nrow-1))/2;
bts  = cumsum([bot flipdim(hts,2)+psh]);
bts  = bts(end-1:-1:1);

axi   = 1;
axs_  = [];

% loop through the rows
for rr = 1:nrow

    % if cols{rr} is a scalar, make that many equally
    %   spaced columns
    if isscalar(cols{rr}) && cols{rr} >= 1
        cols{rr} = 1/cols{rr}.*ones(1,cols{rr});
    end

    % compute width, left position per panel (column)
    ncol = length(cols{rr});
    if ncol >= 1
        wids = cols{rr}*(wid-psw*(ncol-1));
        lts  = lt+cumsum([0 psw+wids(1:end-1)]);
    end

    % loop through the columns
    for cc = 1:length(cols{rr})
        axs_(axi) = axes('Units', 'centimeters', 'position', ...
            [lts(cc), bts(rr), wids(cc), hts(rr)]);
        axi = axi+1;
    end
end

set(axs_, 'FontSize', fs);
