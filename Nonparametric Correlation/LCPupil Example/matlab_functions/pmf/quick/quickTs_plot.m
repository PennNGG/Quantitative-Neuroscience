function quickTs_plot(data, fits, sems, afun, bfun, tbins, ...
    diraxes, alphaaxis, betaaxis, tflag, lflag, mt)
% function quickTs_plot(data, fits, sems, afun, bfun, tbins, ...
%    dir1axis, dir2axis, alphaaxis, betaaxis, tflag, lflag, mt)
%
% Convenience routine for plotting data & quick fits

if nargin < 5 || isempty(data)
    return
end

if nargin < 6 || isempty(tbins)
    tbins = [min(data(:,2)) max(data(:,2))+.001];
end
num_tbins = size(tbins, 1);

if nargin < 7
    diraxes = axes;
end

if nargin < 8
    alphaaxis = [];
end

if nargin < 9
    betaaxis = [];
end

if nargin < 10 || isempty(tflag)
    tflag = false;
end

if nargin < 11 || isempty(lflag)
    lflag = false;
end

if nargin < 12 || isempty(mt)
    mt = '.';
end

% time axis for data, fits
if size(tbins, 2) == 2
    tdatax = tbins(:,1) + diff(tbins, [], 2)./2;
    tfitx = linspace(min(tbins(:, 1)), max(tbins(:, 2)), 50)';
else
    tdatax = tbins;
    tfitx  = linspace(min(tbins), max(tbins), 50)';
end

% plot alpha, beta vs. time
if ~isempty(fits)

    % call quickTs_alpha & *_beta to get inline functions
    [alpha, a0, aT] = quickTs_alpha(afun);
    [beta,  b0, bT] = quickTs_beta(bfun);

    %%%
    % plot alpha vs. time
    %%%
    if ~isempty(alphaaxis)

        % make axis current
        axes(alphaaxis); cla; hold on;

        % fit is time dependent
        if aT

            % get fits, sems of first (probably only) set
            afits = fits(1:size(a0, 1), 1);
            asems = sems(1:size(a0, 1), 1);

            % plot main fit
            plot(tfitx, feval(alpha, tfitx, afits), 'k-', 'LineWidth', 2);

            % plot error rangs
            plot(tfitx, feval(alpha, tfitx, afits+asems), 'k-', 'LineWidth', 1);
            plot(tfitx, feval(alpha, tfitx, afits-asems), 'k-', 'LineWidth', 1);

        elseif size(fits, 2) == 1

            % plot constant value versus time with CIs
            % plot main fit
            plot(tfitx, fits(1, 1)*ones(size(tfitx)), ...
                'k-', 'LineWidth', 2);

            % plot CIs
            plot(tfitx, (fits(1, 1)+sems(1, 1))* ...
                ones(size(tfitx)), 'k-', 'LineWidth', 1);
            plot(tfitx, (fits(1, 1)-sems(1, 1))* ...
                ones(size(tfitx)), 'k-', 'LineWidth', 1);

        elseif size(fits, 2) == size(tbins, 1)

            adata = nans(size(fits, 2), 3);

            for ff = 1:size(fits, 2)

                % get fits, sems of current set
                afits = fits(1:size(a0, 1), ff);
                asems = sems(1:size(a0, 1), ff);

                adata(ff, :) = [ ...
                    feval(alpha, afits), ...
                    feval(alpha, afits+asems), ...
                    feval(alpha, afits-asems)];
            end

            errorbar(tdatax, adata(:,1), adata(:,1)-adata(:,2), ...
                adata(:,1)-adata(:,3), 'k.-');
        end

        % set axis, labels
        axis([0 1 5 100]);
        title('Threshold, Shape Vs. Time');
        set(alphaaxis, 'YScale', 'log');

        if lflag
            set(alphaaxis, 'XScale',  'log');
        else
            set(alphaaxis, 'XScale',  'linear');
        end

        if isempty(betaaxis)
            xlabel('Viewing time (fraction total)');
        else
            set(alphaaxis, 'XTickLabel', []);
            xlabel('');
        end
    end

    %%%
    % plot beta vs. time
    %%%
    if ~isempty(betaaxis)
        
        % make axis current
        axes(betaaxis); cla; hold on;

        % fit is time dependent
        if bT

            % get fits, sems of first (probably only) set
            bfits = fits(size(a0, 1)+[1:size(b0, 1)], 1);
            bsems = sems(size(a0, 1)+[1:size(b0, 1)], 1);

            % plot main fit
            plot(tfitx, feval(beta, tfitx, bfits), 'k-', 'LineWidth', 2);

            % plot CIs
            plot(tfitx, feval(beta, tfitx, bfits+bsems), 'k-', 'LineWidth', 1);
            plot(tfitx, feval(beta, tfitx, bfits-bsems), 'k-', 'LineWidth', 1);

        elseif size(fits, 2) == 1

            % plot constant value versus time with CIs
            % plot main fit
            plot(tfitx, fits(size(a0, 1)+1, 1)*ones(size(tfitx)), ...
                'k-', 'LineWidth', 2);

            % plot CIs
            plot(tfitx, (fits(size(a0, 1)+1, 1)+sems(size(a0, 1)+1, 1))* ...
                ones(size(tfitx)), 'k-', 'LineWidth', 1);
            plot(tfitx, (fits(size(a0, 1)+1, 1)-sems(size(a0, 1)+1, 1))* ...
                ones(size(tfitx)), 'k-', 'LineWidth', 1);

        elseif size(fits, 2) == size(tbins, 1)

            bdata = nans(size(fits, 2), 3);

            for ff = 1:size(fits, 2)

                % get fits, sems of current set
                bfits = fits(size(a0, 1)+[1:size(b0, 1)], ff);
                bsems = sems(size(a0, 1)+[1:size(b0, 1)], ff);

                bdata(ff, :) = [ ...
                    feval(beta, bfits), ...
                    feval(beta, bfits+bsems), ...
                    feval(beta, bfits-bsems)];
            end

            errorbar(tdatax, bdata(:,1), bdata(:,1) - bdata(:,2), ...
                bdata(:,1) - bdata(:,3), 'k.-');
        end

        % set axis, labels
        axis([0 1 0 4]);
        xlabel('Viewing time (fraction total)');

        if lflag
            set(betaaxis, 'XScale',  'log');
        else
            set(betaaxis, 'XScale',  'linear');
        end
    end    
end

%%%
% collect data per coh, time bin
%%%
cohs     = unique(data(:,1));
num_cohs = length(cohs);
dirs     = unique(data(:,3));
num_dirs = length(dirs);
pcts     = nans(num_cohs, num_tbins, num_dirs);

if size(data, 2) < 5 || sum(data(:, 5)) == size(data, 2)
    
    % count instances
    for dd = 1:num_dirs
        for tt = 1:num_tbins
            for cc = 1:num_cohs
                Ltr = data(:, 2) >= tbins(tt,1) & data(:, 2)< tbins(tt,2) & ...
                    data(:, 1) == cohs(cc) & data(:, 3) == dirs(dd);
                if sum(Ltr) > 0
                    pcts(cc,tt,dd) = sum(data(Ltr, 4)==1)./sum(Ltr);
                end
            end
        end
    end    
else
    
    % collect probabilities
    for dd = 1:num_dirs
        for tt = 1:num_tbins
            for cc = 1:num_cohs
                Ltr = data(:, 2) == tbins(tt) & ...
                    data(:, 1) == cohs(cc) & data(:, 3) == dirs(dd);
                if sum(Ltr) == 1
                    pcts(cc,tt,dd) = data(Ltr, 4);
                elseif sum(Ltr) > 1
                    cohs(cc)
                    tbins(tt,:)
                    error('Multiple data representations!')
                end                    
            end
        end
    end
end

if tflag

    % plot vs view time
    xlab  = 'Viewing time';
    pcts  = permute(pcts, [2 1 3]);
    xax   = tdatax;

else
    
    % plot vs coh
    xlab  = 'Motion strength (% coh)';
    xax   = cohs;
    xax(xax==0) = 1.0;

end

%%%
% set up pseudo-data matrix for generating fits
%%%
if ~isempty(fits)

    if tflag
        if size(fits, 2) == 1
            fax = tfitx;
        else
            fax = tdatax;
        end
        find  = 1;
        fbins = cohs;
    else

        fax   = linspace(min(xax), max(cohs), 50)';
        find  = 2;
        fbins = tdatax;
    end
    fdata = repmat(fax, 1, 3);

    % make matrix of fits, one per bin
    num_bins = size(fbins, 1);
    if num_bins > 1 && size(fits, 2) == 1
        fits = repmat(fits, 1, num_bins);
    end
end

% plot colors
co = {'k' 'r' 'g' 'b' 'c' 'm' 'y'};

%%%
% plot data, fits separately for each dir
%%%
for dd = 1:num_dirs

    % set fits data
    fdata(:, 3) = dirs(dd);
    
    % set axes
    axes(diraxes(dd)); cla; hold on;
    
    % loop through the plot bins
    for bb = 1:size(pcts, 2)

        % plot data
        plot(xax, pcts(:, end-bb+1, dd), mt, 'Color', ...
            co{mod(bb-1, length(co))+1}, 'MarkerSize', 20, ...
            'LineWidth', 2);
       
        % plot fits
        if ~isempty(fits)
            fdata(:, find) = fbins(end-bb+1);
            plot(fax, quickTs_val(fdata, alpha, fits(1:size(a0,1), end-bb+1), ...
                aT, beta, fits(size(a0,1)+[1:size(b0,1)], end-bb+1), bT, ...
                fits(end-1, end-bb+1), fits(end, end-bb+1)), '-', 'Color', ...
                co{mod(bb-1, length(co))+1});
        end
    end
    
    % plot lapse, guess
    if ~isempty(fits)
        minx = min(fax);
        maxx = max(fax);
        plot([minx maxx], [0.5 0.5], 'k:');
        plot([minx maxx], 1.0-[fits(end, 1) fits(end, 1)], 'k--');
        plot([minx maxx], 0.5+dirs(dd)*[fits(end-1, 1) fits(end-1, 1)], 'k--');
    else
        minx = min(xax);
        maxx = max(xax);
        plot([minx maxx], [0.5 0.5], 'k:');        
    end
    
    % set axis, labels, etc
    if num_dirs == 1 || dd == 2
        xlabel(xlab);
    end    
    ylabel(sprintf('Fraction correct, dir = %d', dirs(dd)));
    axis([minx maxx 0.3 1.0]);
    
    if (lflag && tflag) || ~tflag
        set(diraxes(dd), 'XScale',  'log');
    else
        set(diraxes(dd), 'XScale',  'linear');
    end
    
    if dd == 1
        if isempty(fits)
            title('No fits');
        else
            title(['fits: ' sprintf('%.2f, ', fits(:,1))]);
        end
    end
end

if length(diraxes) == 2
    set(diraxes(1), 'XTickLabel', []);
end

