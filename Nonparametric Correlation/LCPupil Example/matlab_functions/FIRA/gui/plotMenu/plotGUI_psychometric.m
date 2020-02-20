function varargout = plotGUI_psychometric(varargin)
% plotGUI_neurometricROC Application M-file for plotGUI_psychometric.fig
%
% Usage:
%    FIG = plotGUI_psychometric({<deleteFcn>})
%       launch plotGUI_psychometric GUI.
%
%    plotGUI_psychometric('callback_name', ...) invoke the named callback.
%

if nargin == 0 | ~ischar(varargin{1}) % LAUNCH GUI

    % open the figure
    fig = openfig(mfilename,'new');

    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    % the (optional) argument is the fig that created this, which
    % is used for the destroy callback
    if nargin > 0
        set(fig, 'DeleteFcn', varargin{1}{:});
    end

    % call the setup subfunction to setup the menus, etc.
    setup(guihandles(fig));

    if nargout > 0
        varargout{1} = fig;
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end

end

% --------------------------------------------------------------------
%
% SUBROUTINE: setup
%
%  Usually called as setup(guidata(fig))
%
%  Called whenever creating the figure, or
%   when a new FIRA is present
%
function setup(handles)

% default weibull

% id selection menus
gsGUI_selectByUniqueID('setf', handles.cohmenu,     'dot_coh');
gsGUI_selectByUniqueID('setf', handles.dirmenu,     'dot_dir');
gsGUI_selectByUniqueID('setf', handles.outcomemenu, 'correct');

% set dir boxes
modes = nanmode(getFIRA_ecodesByName('dot_dir', 'id'));
if length(modes) > 1
    set(handles.d1edit, 'String', num2str(modes(1)));
    set(handles.d2edit, 'String', num2str(modes(2)));
end

% set the dot on/off menus
gsGUI_ecodeTimesByName('setf', handles.dotonmenu,  {'dot_on', 'ins_on'});
gsGUI_ecodeTimesByName('setf', handles.dotoffmenu, {'dot_off', 'ins_off'});

% set fits
set(handles.fitmenu, 'Value', 1, 'String', { ...
    'none',         ...
    'Weibull',      ...
    'Logistic',     ...
    'Logistic(t)'});

% set time bin menus
set(handles.binmenu, 'Value', 1, 'String', ...
    {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' '14' '15'});
set(handles.binshowmenu, 'Value', 1, 'String', ...
    {'all' '1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' '14' '15'});

% set check boxes
set(handles.cb1, 'Value', 0);
set(handles.cb2, 'Value', 1);
set(handles.cb3, 'Value', 1);
set(handles.cb4, 'Value', 0);
set(handles.cb5, 'Value', 0);
set(handles.cb6, 'Value', 0);

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_psychometric);

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'psychometric', ...
    {...
    'menu',     'cohmenu';     ...
    'menu',     'outcomemenu'; ...
    'menu',     'dirmenu';     ...
    'menu',     'dotonmenu';   ...
    'menu',     'dotoffmenu';  ...
    'menu',     'fitmenu';     ...
    'menu',     'binmenu';     ...
    'menu',     'binshowmenu'; ...
    'edit',     'mintedit';    ...
    'edit',     'maxtedit';    ...
    'edit',     'd1edit';      ...
    'edit',     'd2edit';      ...
    'check',    'cb1';         ...
    'check',    'cb2';         ...
    'check',    'cb3';         ...
    'check',    'cb4';         ...
    'check',    'cb5';         ...
    'check',    'cb6';         ...
    'slider',   'curslider';   ...
    'slider',   'prevslider';  ...
    'value',    'select'});

% store data in the figure's application data
guidata(handles.figure1, handles);

% update it, which includes setting up the axes
set_axes_cb(handles);

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GcbO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
%
% CALLBACK: set_axes_cb
%
% set up axes, then call update_cb
function set_axes_cb(handles)

show_pmf     = get(handles.cb2, 'Value');
show_summary = get(handles.cb3, 'Value');

if show_pmf && show_summary

    % show both axes
    set(handles.pmfaxis, ...
        'Units', 'normalized', 'Position', [0.365 0.295 0.625 0.575], ...
        'XTickMode', 'manual', ...
        'XTick',     [], ...
        'Visible',   'on');

    set(handles.summaryaxis, ...
        'Units', 'normalized', 'Position', [0.365 0.075 0.625 0.22], ...
        'Visible', 'on');

elseif show_pmf

    % show pmf axis
    set(handles.pmfaxis, ...
        'Units', 'normalized', 'Position', [0.365 0.075 0.625 0.795], ...
        'XTickMode', 'auto', ...
        'Visible',   'on');

    set(handles.summaryaxis, 'Visible', 'off');
    cla(handles.summaryaxis);

elseif show_summary

    % show summary axis
    set(handles.pmfaxis, 'Visible', 'off');
    cla(handles.pmfaxis);

    set(handles.summaryaxis, ...
        'Units', 'normalized', 'Position', [0.365 0.075 0.625 0.795], ...
        'Visible', 'on');

else

    % show neither axis
    set(handles.pmfaxis,     'Visible', 'off');
    cla(handles.pmfaxis);

    set(handles.summaryaxis, 'Visible', 'off');
    cla(handles.summaryaxis);
end

% let update do the work of drawing
update_cb(handles);

% --------------------------------------------------------------------
%
% CALLBACK: update_cb
%
% The big kahuna that sets up the axes and plots the danged thing...
% called directly from the "update" button
%
function update_cb(handles)

% check axes
show_pmf     = get(handles.cb2, 'Value');
show_summary = get(handles.cb3, 'Value');

% clear the axes
if show_pmf
    cla(handles.pmfaxis);
end
if show_summary
    cla(handles.summaryaxis);
end

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

cont = false; % flag
if ~isempty(trials)

    % get view times ... only considering trials with
    %   'dot_on' and 'dot_off' codes
    tstop  = gsGUI_ecodeTimesByName('getf', handles.dotoffmenu, [], trials);
    tstart = gsGUI_ecodeTimesByName('getf', handles.dotonmenu,  [], trials);

    if length(tstart) == length(tstop)

        % get good trials from view times
        view_times = tstop - tstart;
        min_time   = str2num(get(handles.mintedit, 'String'));
        max_time   = str2num(get(handles.maxtedit, 'String'));
        Lgood      = ~isnan(view_times) & ...
            view_times >= min_time & view_times <= max_time;

        if any(Lgood)
            
            % get good trials
            view_times = view_times(Lgood);
            trials     = trials(Lgood);

            % get cohs, selection arrays
            [Lcoh, cohs] = gsGUI_selectByUniqueID('getf', handles.cohmenu, trials, 12);

            % get outcome, selection arrays
            [Lout, outs] = gsGUI_selectByUniqueID('getf', handles.outcomemenu, trials, 12);

            % get dirs, selection arrays
            [Ldir, dirs] = gsGUI_selectByUniqueID('getf', handles.dirmenu, trials, 12);

            % get the selected dirs
            d1_ind = find(dirs == str2num(get(handles.d1edit, 'String')));
            d2_ind = find(dirs == str2num(get(handles.d2edit, 'String')));

            % update dirs, selection array for chosen 2 dirs
            dirs = dirs([d1_ind d2_ind]);
            Ldir = Ldir(:, [d1_ind d2_ind]);

            % check for cohs, dirs
            if size(cohs, 1) > 0 && size(dirs, 1) == 2

                % set flag
                cont = true;

                % select usable data
                Lgood      = sum(Lcoh, 2)==1 & sum(Lout, 2)==1 & sum(Ldir, 2)==1;
                trials     = trials(Lgood);
                view_times = view_times(Lgood);
                Lcoh       = Lcoh(Lgood, :);
                Lout       = Lout(Lgood, :);
                Ldir       = Ldir(Lgood, :);

                % selection indices outcomes
                c_cor = find(outs == 4905 | outs == 1);
                c_err = find(outs == 4906 | outs == 0);
                c_nc  = find(outs == 4907 | outs == -1);
                c_bf  = find(outs == 4913);

                % add dummy column to Lout, if neccesary
                if ~any(c_cor) || ~any(c_err) || ~any(c_nc) || ~any(c_bf)
                    Lout(:, end+1) = false(size(Lout, 1), 1);
                    if ~any(c_cor)
                        c_cor = size(Lout, 2);
                    end
                    if ~any(c_err)
                        c_err = size(Lout, 2);
                    end
                    if ~any(c_nc)
                        c_nc = size(Lout, 2);
                    end
                    if ~any(c_bf)
                        c_bf = size(Lout, 2);
                    end
                end

                % mark all 0% coherence trials as correct
                % Lout(Lcoh(:, cohs==0), c_cor) = true;
                % Lout(Lcoh(:, cohs==0), c_err) = false;

                % selection arrays for outcomes, choices
                Lcor  = Lout(:, c_cor);
                Lerr  = Lout(:, c_err);
                Lchc  = [ ...
                    (Ldir(:, 1) & Lcor) | (Ldir(:, 2) & Lerr), ...
                    (Ldir(:, 2) & Lcor) | (Ldir(:, 1) & Lerr)];
            end
        end
    end
end

% nothing found .. clean up and go
if ~cont
    set(handles.textnb,      'String', 'n/a');
    set(handles.textbias,    'String', 'n/a');
    set(handles.textcorrect, 'String', 'n/a');
    set(handles.textlapse,   'String', 'n/a');
    return
end

% fill in summary stats

% count of Broken Fixations, No Choice errors
set(handles.textnb, 'String', sprintf('%d / %d', ...
    sum(Lout(:, c_nc)), sum(Lout(:, c_bf))));

% count of biases
d1c = sum(Lchc(:,1));
d2c = sum(Lchc(:,2));
d1p = sum(Ldir(:,1) & (Lcor | Lerr));
d2p = sum(Ldir(:,2) & (Lcor | Lerr));
if (d1c || d2c) && (d1p || d2p)
    set(handles.textbias, 'String', ...
        sprintf('%.1f%% (%d/%d) .. %.1f%% (%d/%d)', ...
        d1c/(d1c+d2c)*100, d1c, d2c, ...
        d1p/(d1p+d2p)*100, d1p, d2p));
else
    set(handles.textbias, 'String', 'n/a');
    return
end

% total percent correct
cor = sum(Lcor);
err = sum(Lerr);
if cor + err > 0
    set(handles.textcorrect, 'String', ...
        sprintf('%.1f%% (%d/%d)', cor/(cor+err)*100, cor, err));
else
    set(handles.textcorrect, 'String', 'n/a');
    return
end

% if no plots, outta
if ~(show_pmf || show_summary)
    return
end

% get time bins
num_bins = get(handles.binmenu, 'Value');
if num_bins == 1

    Ltime = true(size(trials));
    bins = [min_time max_time];

else

    % check box "Fix bin" determines whether we bin
    %   time by viewing times or number of trials
    if get(handles.cb6, 'Value')

        % get fixed bins between time min and time max
        bins = linspace(min_time, max_time, num_bins+1);
    else

        % get bins based on prctiles of data
        bins = prctile(view_times, linspace(0, 100, num_bins+1));
    end

    % make time bin array
    Ltime = false(size(trials, 1), num_bins);

    % special case first bin
    Ltime(view_times >= bins(1) & view_times <= bins(2), 1) = true;

    % loop through the rest of the bins
    for ii = 2:num_bins
        Ltime(view_times > bins(ii) & view_times <= bins(ii+1), ii) = true;
    end
end

% get fit type
fit = get(handles.fitmenu, 'Value');

% CheckBox 1 determines whether we're plotting
%   pct correct vs coherence (0)
%       _or_
%   pct d1 choice vs signed coherence (1)
if get(handles.cb1, 'Value')

    % convert coh to signed coherence
    if cohs(1) == 0
        Lcoh = [ ...
            Lcoh(:, end:-1:2) & repmat(Ldir(:,2), 1, size(cohs, 1)-1), ...
            Lcoh(:, 1)        & (Ldir(:, 1) | Ldir(:, 2)), ...
            Lcoh(:, 2:end)    & repmat(Ldir(:,1), 1, size(cohs, 1)-1)];
        cohs = [-cohs(end:-1:2); cohs];
    else
        Lcoh = [ ...
            Lcoh(:, end:-1:1) & repmat(Ldir(:,2), 1, size(cohs, 1)), ...
            Lcoh              & repmat(Ldir(:,1), 1, size(cohs, 1))];
        cohs = [-cohs(end:-1:1); cohs];
    end

    % move selection array of d1/d2 choices to Lout
    Lout(:, [c_cor, c_err]) = Lchc;

    % check fit type
    if fit == 2
        disp('Unable to perform Quick fit on choice data; changing to Logistic')
        set(handles.fitmenu, 'Value', 3);
        fit = 3;
    end

    % ylabel
    yl = '% d1 Choices';
else

    % check fit type
    if fit == 3 || fit == 4
        disp('Unable to perform logistic fit on correct data; changing to Quick')
        set(handles.fitmenu, 'Value', 2);
        fit = 2;
    end

    yl = '% Correct';
end

% check whether we're fitting... if so, do
% full fit (if one time bin), otherwise typically
% a "pre" fit to determine lapse rate(s)
switch fit

    case 2

        % WEIBULL
        if num_bins == 1

            % get fit
            fits  = quick_fit(quick_formatData2( ...
                cohs, Lcoh(Lcor | Lerr, :), Lcor(Lcor | Lerr)));
            sfit  = fits;
            lapse = fits(3);

        else
            % get lapse rate from a fit to upper 50th prctile time data
            Llr   = view_times > median(view_times) & (Lcor | Lerr);
            sfit  = quick_fit(quick_formatData2(cohs, Lcoh(Llr, :), Lcor(Llr)));
            lapse = sfit(3);

            % set up fits array
            fits = zeros(2, num_bins);
        end

        % show lapse rate
        set(handles.textlapse, 'String', sprintf('%.1f', lapse*100));

    case 3

        % LOGISTIC
        if num_bins == 1

            sfit  = logist_fit(logist_formatData( ...
                cohs, Lcoh(Lcor | Lerr, :), Lchc(Lcor | Lerr, 1)));
            fits  = sfit(3:4); % save for later
            lapse = sfit(1:2);

        else

            % get lapse rates from a fit to upper 50th prctile time data
            Llr   = view_times > median(view_times) & (Lchc(:,1) | Lchc(:,2));
            sfit  = logist_fit(logist_formatData(cohs, Lcoh(Llr, :), Lchc(Llr, 1)));
            lapse = sfit(1:2);

            % set up fits array
            fits = zeros(2, num_bins);
        end

        % show lapse rate
        set(handles.textlapse, 'String', sprintf('%.1f / %.1f', lapse*100));

    case 4

        % LOGISTIC WITH TIME TERM
        Llt  = Lcor | Lerr;
        ldat = logist_formatData(cohs, Lcoh(Llt, :), Lchc(Llt, 1));

        % add a time*coh term and a time alone term
        ldat = [ldat(:,1) ldat(:,2) view_times(Llt)/1000.*ldat(:,2) view_times(Llt)/1000 ldat(:,3)];
        fits = logist_fit(ldat);

        % show lapse rate
        set(handles.textlapse, 'String', sprintf('%.1f / %.1f', fits(1:2)*100));

    otherwise

        % no fit
        set(handles.textlapse, 'String', 'n/a');
end

% build matrix of timebin x coh x
%   c_cor ... correct/d1 choice count
%   c_err ... error/d2 choice count
%   c_nc  ... No Choice count
%   c_bf  ... Break Fix count
dat = zeros(size(Lcoh, 2), 4, num_bins);
for tt = 1:num_bins
    for cc = 1:size(Lcoh, 2)
        Lbin = Ltime(:, tt) & Lcoh(:, cc);
        dat(cc, :, tt) = [ ...
            sum(Lout(:, c_cor) & Lbin), ...
            sum(Lout(:, c_err) & Lbin), ...
            sum(Lout(:, c_nc)  & Lbin), ...
            sum(Lout(:, c_bf)  & Lbin)];
    end

    % compute fits
    if num_bins > 1

        if fit == 2

            % WEIBULL
            Lsel = Ltime(:, tt) & (Lcor | Lerr);
            fits(:, tt) = quick_fit(quick_formatData2( ...
                cohs, Lcoh(Lsel, :), Lcor(Lsel)), lapse);

        elseif fit == 3

            % LOGISTIC
            Lsel        = Ltime(:, tt) & (Lcor | Lerr);
            % fits(:, tt)
            aa = logist_fit(logist_formatData( ...
                cohs, Lcoh(Lsel, :), Lchc(Lsel, 1)), lapse(1), lapse(2));
            fits(:, tt) = aa(3:4);
        end
    end
end

% check whether we're plotting vs time
timeflg = get(handles.cb5, 'Value');
if timeflg
    xl      = 'Time bin midpoint (ms)';
    dat     = permute(dat, [3 2 1]);
    xs      = round(bins(1:end-1) + diff(bins)/2)';
    xx      = xs;
else
    xl        = 'Motion strength (% coherence)';
    xs        = cohs;
    % plot logs, unless logistic
    if any(xs<0)
        xx = xs;
    else
        xx        = abs(xs);
        xx(xx==0) = 1;
        xx        = log(xx);
    end
end

% binshow menu value
binshow = get(handles.binshowmenu, 'Value');

% show summary data
if show_summary

    % clear the axis
    axes(handles.summaryaxis);

    if binshow == 1 || binshow-1 > size(dat, 3) % 'all'
        bar(handles.summaryaxis, sum(dat, 3));
    else
        bar(handles.summaryaxis, dat(:,:,binshow-1));
    end

    % set axis labels
    ylabel(handles.summaryaxis, 'Count');
    xlabel(handles.summaryaxis, xl);
    set(handles.summaryaxis, 'XTickLabel', cellstr(num2str(xs)));
end

if show_pmf

    co = { ...
        'k.-',  'r.-',  'g.-',  'b.-',  'c.-',  'm.-',  ...
        'k.--', 'r.--', 'g.--', 'b.--', 'c.--', 'm.--', ...
        'k.:',  'r.:',  'g.:',  'b.:',  'c.:', 'm.:'};

    % select axes
    axes(handles.pmfaxis);
    hold on;

    % plot data
    hh = zeros(size(dat, 3), 1);
    for dd = 1:size(dat, 3)
        den = dat(:,1,dd)+dat(:,2,dd);
        den(den==0) = nan;
        hh(dd) = plot(handles.pmfaxis, xx, dat(:,1,dd)./den*100, co{dd}, ...
            'MarkerSize', 20);
    end

    % get min, max x values
    minx = min(xx);
    maxx = max(xx);

    % scale the axes
    if minx == maxx
        set(handles.pmfaxis, 'XLim', [minx-10 maxx+10]);
    else
        set(handles.pmfaxis, 'XLim', [minx-(maxx-minx)/50 maxx+(maxx-minx)/50]);
    end

    % add grid lines for signed coh plots
    if any(cohs<0) && ~timeflg
        set(handles.pmfaxis, 'YLim', [0 100]);
        plot([minx maxx], [50 50], 'r:');
        plot([0 0], [0 100], 'r:');
    end

    switch fit

        case 1 % none
            set(handles.textparams, 'String', '');

        case 2 % Weibull

            set(hh, 'LineStyle', 'none');
            set(handles.pmfaxis, 'YLim', [40 100]);

            % if we're plotting vs time or coh
            if timeflg

                % plotting versus time
                % grid of time x coh preds
                pgrid = zeros(length(cohs), num_bins);

                for pp = 1:num_bins
                    pgrid(:, pp) = 100 * quick_val(cohs, fits(1, pp), fits(2, pp), lapse);
                end

                for cc = 1:length(cohs)
                    plot(xx, pgrid(cc, :)', co{cc}, 'LineStyle', '-', ...
                        'lineWidth', 2, 'Marker', 'none');
                end

            else

                % plotting versus coh
                xbase = minx:.1:maxx;
                xcomp = exp(xbase); % xx is logs

                for ff = 1:num_bins
                    plot(xbase, 100*quick_val(xcomp, fits(1, ff), fits(2, ff), lapse), ...
                        co{ff}, 'LineStyle', '-', 'lineWidth', 2, 'Marker', 'none');
                end

                % plot a line at the lapse
                plot([minx maxx], 100-100*[lapse lapse], 'k--');

            end

            % display the fit parameters
            if binshow == 1 || binshow-1 > num_bins
                set(handles.textparams, 'String', ...
                    sprintf('a = %.1f, b = %.1f', sfit(1), sfit(2)));
            else
                set(handles.textparams, 'String', ...
                    sprintf('a = %.1f, b = %.1f', ...
                    fits(1,binshow-1), fits(2,binshow-1)));
            end

        case 3 % simple logistic

            set(hh, 'LineStyle', 'none');

            % if we're plotting vs time or coh
            if timeflg

                xcomp = [ones(size(cohs)) cohs/100];

                % plotting versus time
                % grid of time x coh preds
                pgrid = zeros(length(cohs), num_bins);

                for pp = 1:num_bins
                    pgrid(:, pp) = ...
                        100*logist_val(xcomp, lapse(1), lapse(2), fits(1:2, pp));
                end

                for cc = 1:length(cohs)
                    plot(xx, pgrid(cc, :)', co{cc}, 'LineStyle', '-', ...
                        'lineWidth', 2, 'Marker', 'none');
                end

            else

                % plotting versus coh
                xbase = linspace(minx, maxx, 100);
                xcomp = [ones(100,1) xbase'/100];

                for ff = 1:num_bins
                    plot(xbase, 100*logist_val(xcomp, lapse(1), lapse(2), fits(1:2, ff)), ...
                        co{ff}, 'LineStyle', '-', 'lineWidth', 2, 'Marker', 'none');
                end

                % plot a line at the lapses
                plot([minx maxx], 100*[lapse(1) lapse(1)],     'k--');
                plot([minx maxx], 100-100*[lapse(2) lapse(2)], 'k--');

            end

            % display the fit parameters
            if binshow == 1 || binshow-1 > num_bins
                set(handles.textparams, 'String', ...
                    sprintf('b1 = %.1f, b2 = %.1f', sfit(3), sfit(4)));
            else
                set(handles.textparams, 'String', ...
                    sprintf('a = %.1f, b = %.1f', ...
                    fits(1,binshow-1), fits(2,binshow-1)));
            end

        case 4 % logistic with time term

            set(hh, 'LineStyle', 'none');

            % if we're plotting vs time or coh
            if timeflg

                % plotting versus time
                % grid of time x coh preds
                tbase  = [min(view_times):max(view_times)]'/1000;
                num_ts = size(tbase, 1);

                for cc = 1:length(cohs)
                    plot(tbase*1000, 100*logist_val( ...
                        [ones(num_ts, 1), ones(num_ts,1)*cohs(cc)/100, ...
                        ones(num_ts,1).*tbase*cohs(cc)/100, tbase], fits(1), ...
                        fits(2), fits(3:end)), co{cc}, 'LineStyle', '-', ...
                        'lineWidth', 2, 'Marker', 'none');
                end

            else

                % plotting versus coh
                num_cs = 100;
                xbase  = linspace(minx, maxx, num_cs);
                cs     = xbase'/100;
                times  = round(bins(1:end-1) + diff(bins)/2)';

                for ff = 1:num_bins
                    plot(xbase, 100*logist_val([ones(num_cs, 1), ...
                        cs, ones(num_cs,1).*cs*times(ff)/1000, ...
                        times(ff)*ones(num_cs,1)/1000], fits(1), fits(2), ...
                        fits(3:end)), co{ff}, 'LineStyle', '-', ...
                        'lineWidth', 2, 'Marker', 'none');
                end

                % plot a line at the lapses
                plot([minx maxx], 100*[fits(1) fits(1)],     'k--');
                plot([minx maxx], 100-100*[fits(2) fits(2)], 'k--');
            end

            % display the fit parameters
            set(handles.textparams, 'String', ...
                sprintf('bs = [%.1f, %.1f, %.1f, %.1f]', fits(3:end)));
    end

    % set axis labels
    ylabel(handles.pmfaxis, yl);
    if ~show_summary
        xlabel(handles.pmfaxis, xl);
        set(handles.pmfaxis, 'XTickLabel', cellstr(num2str(xs)));
    else
        set(handles.pmfaxis, 'XTick', []);
    end
end
