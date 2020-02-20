function PLOT_scatter(xs, ys, Lsb, mstyle, lstyle, ax, opt_arg)
%
% plots a value from one column of data versus another.
%
% Arguments:
%   xs      ... x data
%   ys      ... y data
%   Lsb     ... matrix of sort vectors, one per color
%   mstyle  ... marker style (e.g., '.')
%   lstyle  ... line style. Can be standard style from MATLAB's
%                  plot command (e.g., '-', '--', etc), or
%                  'runmean' or 'polyfit' or 'means' 
%   ax      ... the axis
%   opt_arg ... optional arg to be used by certain line styles

% check args
if nargin < 2
    return
end
if nargin < 3 | isempty(Lsb)
    Lsb = logical(ones(max(length(xs), length(ys)), 1));
end
if nargin < 4 | isempty(mstyle)
    mstyle = '.';
end
if nargin < 5 | isempty(lstyle)
    lstyle = 'none'
end
if nargin < 6 | isempty(ax)
    axes;
else
    axes(ax);
end

% clear the axes
cla; hold on;

% make sure there's data
if isempty(xs) & isempty(ys)
    return
end

% check to make sure we have enough colors for Lsb ...
colors  = {'k' 'r' 'g' 'b' 'c' 'm' 'y' .5*[1 1 1] .25*[1 1 1] .75*[1 1 1]};
lenc    = length(colors);
if size(Lsb, 2) > lenc
    Lsb = [Lsb(:, 1:lenc-1) any(Lsb(:, lenc:end), 2)];
end
num_colors = size(Lsb, 2);

% check line style ...
lsi = 0;
if strncmp(lstyle, 'runmean', 7)
    lsi    = 1;
    lstyle = 'none';
    if nargin < 7 | isempty(opt_arg)
        opt_arg = 5;
    end
elseif strncmp(lstyle, 'polyfit', 7)
    lsi    = 2;
    lstyle = 'none';
    if nargin < 8 | isempty(opt_arg)
        opt_arg = 1;
    end
elseif strcmp(lstyle, 'means')
    lsi    = 3;
    lstyle = 'none';
end

% plot it with dummy data, for speed
hs = plot(0, 1:num_colors, 'Marker', 'none');

% now do the plot with the appropriate sorting
for c = 1:num_colors

    % thaxese sorting array
    Larray = Lsb(:,c);
    if sum(Larray)
        
        % get the data.. remember this can be univariate, in
        % which case we'll explicitly get the indices which
        % we may want to use in fitting, below
        if ~isempty(xs)
            this_x = xs(Larray);
        else
            this_x = [1:sum(Larray)]';
        end
        if ~isempty(ys)
            this_y = ys(Larray);
        else
            this_y = [1:sum(Larray)]';
        end

        % plot the data
        set(hs(c), 'XData', this_x, 'YData', this_y, ...
            'Color', colors{c}, 'Marker', mstyle, 'LineStyle', lstyle);
        
        % runmean has a window size stored in opt_arg
        if lsi == 1
            [Xsort, Isort] = sort(this_x);
            plot(Xsort, nanrunmean(this_y(Isort), opt_arg), ...
                '-', 'Color', colors{c});
            
        % polyfit has a degree stored in opt_arg    
        elseif lsi == 2
            xax = min(this_x):max(this_x);
            plot(xax, polyval(polyfit(this_x, this_y, opt_arg), xax), ...
                '-', 'Color', colors{c});
            
        % plot means for each unique x value
        elseif lsi == 3
            [Xunique, dummy, Iunique] = unique(this_x);
            Yunique = [];
            for i=1:length(Xunique)
                Yunique(i)=nanmean(this_y(find(Iunique==i))); % calculate the mean of the Ys belonging to a particular Xunique
            end
            plot(Xunique, Yunique, '-', 'Color', colo);
        end
    end
end