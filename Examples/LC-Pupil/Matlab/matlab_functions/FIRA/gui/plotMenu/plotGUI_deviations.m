function varargout = plotGUI_deviations(varargin)
%
% Usage:
%    FIG = plotGUI_deviations({<deleteFcn>})
%       launch plotGUI_deviations GUI.
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

% id selection menus
gsGUI_selectByUniqueID('setf', handles.cohmenu,     'dot_coh');
gsGUI_selectByUniqueID('setf', handles.outcomemenu, 'correct');
gsGUI_selectByUniqueID('setf', handles.choicemenu,  'choice');

% set the dot on/off menus
gsGUI_ecodeTimesByName('setf', handles.dotonmenu,  {'dot_on', 'ins_on'});
gsGUI_ecodeTimesByName('setf', handles.dotoffmenu, {'dot_off', 'ins_off'});

% set dir boxes
modes = nanmode(getFIRA_ecodesByName('dot_dir', 'id'));
if length(modes) > 1
    set(handles.d1edit, 'String', num2str(modes(1)));
    set(handles.d2edit, 'String', num2str(modes(2)));
end

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_deviations);

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'deviations', ...
    {...
    'menu',     'cohmenu';     ...
    'menu',     'outcomemenu'; ...
    'menu',     'choicemenu';  ...
    'menu',     'dotonmenu';   ...
    'menu',     'dotoffmenu';  ...
    'menu',     'cohbinmenu';  ...
    'menu',     'timebinmenu'; ...
    'edit',     'rmsedit';     ...
    'edit',     'mintedit';    ...
    'edit',     'maxtedit';    ...
    'edit',     'd1edit';      ...
    'edit',     'd2edit';      ...
    'slider',   'curslider';   ...
    'slider',   'prevslider';  ...
    'value',    'select'});

% store data in the figure's application data
guidata(handles.figure1, handles);

% update it
update_cb(handles);

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
% CALLBACK: update_cb
%
% The big kahuna that sets up the axes and plots the danged thing...
% called directly from the "update" button
%
function update_cb(handles)

% clear the data
delete(get(handles.axes1, 'Children'));
delete(get(handles.axes2, 'Children'));
delete(get(handles.axes3, 'Children'));

% "Show menu" determines which axes get shown
showm = get(handles.showmenu, 'Value');
if showm == 2 || showm == 4 || showm == 5
    set(handles.axes1, 'Visible', 'off');
    set([handles.axes2, handles.axes3], 'Visible', 'on');
else
    set([handles.axes2, handles.axes3], 'Visible', 'off');
    set(handles.axes1, 'Visible', 'on');
    axes(handles.axes1);
end

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

Lgood = false; % flag
if ~isempty(trials)

    % get view times ... only considering trials with
    %   'dot_on' and 'dot_off' codes
    tstop  = gsGUI_ecodeTimesByName('getf', handles.dotoffmenu, [], trials);
    tstart = gsGUI_ecodeTimesByName('getf', handles.dotonmenu,  [], trials);

    if length(tstart) == length(tstop)

        % get good trials from view times, stim_flag
        view_times = tstop - tstart;
        min_time   = str2double(get(handles.mintedit, 'String'));
        max_time   = str2double(get(handles.maxtedit, 'String'));
        Lgood      = ~isnan(view_times) & ...
            getFIRA_ec(trials, 'stim_flag') > 1 & ...
            view_times >= min_time & view_times <= max_time;
    end
end

% check for good trials
if ~any(Lgood)
    return
end

% re-select good trials
view_times = view_times(Lgood);
trials     = trials(Lgood);

% get outcome, selection arrays
[Lout, outs] = gsGUI_selectByUniqueID('getf', handles.outcomemenu, trials, 12);
if ~any(outs==0 | outs==1)
    return
end
Lout = Lout(:, [find(outs==0) find(outs==1)]);
if ~any(outs==0)
    Lout = [false(size(Lout)) Lout];
end
if ~any(outs==1)
    Lout = [Lout false(size(Lout))];
end

% get dirs, selection arrays
[Ldir, dirs] = gsGUI_selectByUniqueID('getf', handles.choicemenu, trials, 12);
d1_ind = find(dirs == str2double(get(handles.d1edit, 'String')));
d2_ind = find(dirs == str2double(get(handles.d2edit, 'String')));
dirs   = dirs([d1_ind d2_ind]);
Ldir   = Ldir(:, [d1_ind d2_ind]);

% get coh, time bins for plots 6-9
if any(showm == [6 7 8 9])

    % get time bins, selection arrays
    tbins = prctile(view_times, linspace(0, 100, ...
        get(handles.timebinmenu, 'Value')+1));
    tbins(end) = tbins(end) + 1;

    Ltime = false(size(trials, 1), length(tbins) - 1);
    for ii = 1:length(tbins) - 1
        Ltime(view_times >= tbins(ii) & view_times < tbins(ii+1), ii) = true;
    end

    % get coh bins, selection arrays
    cohs = getFIRA_ec(trials, 'dot_coh');

    switch get(handles.cohbinmenu, 'Value')

        case 1
            cbins = [0 99.9];

        case 2
            cbins = [25.6 99.9; 0 12.8];

        case 3
            cbins = [51.2 99.9; 6.4 25.6; 0 3.2];

        case 4
            cbins = [51.2 99.9; 12.8 25.6; 3.2 6.4; 0 0];
            
        otherwise
            cbins = repmat(flipdim(nonanunique(cohs),1), 1, 2);
    end

    Lcoh = false(size(trials, 1), size(cbins, 1));
    for ii = 1:size(cbins, 1)
        Lcoh(cohs>=cbins(ii,1) & cohs<=cbins(ii,2), ii) = true;
    end
end

% trial min, max
mxt = max(trials);
mnt = min(trials);

% get run-mean window
rms = ceil(str2double(get(handles.rmsedit, 'String')));

% case on type of plot
switch showm

    % raw or rms x vs. y
    case {1, 3}

        if showm == 1
            rs   = getFIRA_ec(trials, {'stim_endrx', 'stim_endry'});
            alim = 20;
            lab  = 'Raw';
        else
            rs   = getFIRA_ec(trials, {'stim_endmx', 'stim_endmy'});
            alim = 10;
            lab  = 'Run-mean subtracted';
        end

        % plot points first
        hold on;
        ma = {'x' 'o'};
        co = {'g' 'b'};
        for out = 1:2
            for dir = 1:2
                Ltr = Lout(:, out) & Ldir(:, dir);
                plot(rs(Ltr, 1), rs(Ltr, 2), ma{out}, ...
                    'MarkerSize', 3, 'MarkerEdgeColor', co{dir});
            end
        end

        % plot avgs next (overlay)
        ma = {'d' 'o'};
        for out = 1:2
            for dir = 1:2
                Ltr = Lout(:,out) & Ldir(:, dir);
                if any(Ltr)
                    [hs,hx,hy] = errorbar2(mean(rs(Ltr,1)), mean(rs(Ltr,2)), ...
                        std(rs(Ltr,1)), std(rs(Ltr,2)));
                    hold on
                    set(hs, 'Marker', ma{out}, 'MarkerEdgeColor', co{dir}, ...
                        'MarkerSize', 15);
                    set([hx hy], 'Color', 'k', 'LineWidth', 2);
                end
            end
        end
        
        % plot zero lines
        plot([-20 20], [0 0], 'k--');
        plot([0 0], [-20 20], 'k--');
        
        % plot fp, targets
        plot(0,0,'ro', 'MarkerFaceColor', 'r');
        vals = getFIRA_ec(find(~isnan(getFIRA_ec([], 't1_x')), 1), ...
            {'t1_x', 't1_y', 't2_x', 't2_y'});
        plot(vals([1 3]), vals([2 4]), 'ro', ...
            'MarkerFaceColor', 'r', 'MarkerSize', 10);

        % set axes, labels
        axis([-alim alim -alim alim]);
        xlabel(sprintf('%s x', lab));
        ylabel(sprintf('%s y', lab));


    % raw or rms x and y vs. trial
    case {2, 4}

        if showm == 2
            rs   = getFIRA_ec(trials, {'stim_endrx', 'stim_endry'});
            alim = 20;
            ylab = 'Raw';
        else
            rs   = getFIRA_ec(trials, {'stim_endmx', 'stim_endmy'});
            alim = 10;
            ylab = 'Run-mean subtracted';
        end
        
        % plot points, run-means
        ma  = {'x' 'o'};
        co  = {'g' 'b'};
        ax  = [handles.axes2 handles.axes3];
        yl  = 'xy';
        
        for xy = 1:2
            
            % x is top axis, y is bottom axis
            axes(ax(xy));
            hold on;
            
            % plot outcome, choices separately
            for dir = 1:2
                for out = 1:2                 
                    Ltr = Lout(:, out) & Ldir(:, dir);
                    plot(trials(Ltr), rs(Ltr, xy), ma{out}, ...
                        'MarkerSize', 3, 'MarkerEdgeColor', co{dir});
                end
                
                % plot runmean for given choice
                plot(trials(Ldir(:,dir)), nanrunmean(rs(Ldir(:,dir),xy), rms), ...
                    '-', 'Color', co{dir}, 'LineWidth', 2);
            end
            
            % plot zero line
            plot([mnt mxt], [0 0], 'k--');
                       
            % set the axis limits
            axis([mnt mxt -alim alim]);
            xlabel('Trial number');
            ylabel(sprintf('%s %s', ylab, yl(xy)));
        end

    % plot dev, zdev vs trial
    case 5
        
        % get deviations
        devs  = getFIRA_ec(trials, {'stim_dev' 'stim_zdev'});
        
        ma  = {'x' 'o'};
        yl  = {'Deviations (deg)' 'Deviations (z-score)'};
        ax  = [handles.axes2 handles.axes3];
        
        for dd = 1:2
            
            % x is top axis, y is bottom axis
            axes(ax(dd));
            hold on;
            
            % plot outcome separately
            for out = 1:2
                
                plot(trials(Lout(:, out)), devs(Lout(:, out), dd), ma{out}, ...
                    'MarkerEdgeColor', 'k', 'MarkerSize', 4);                                    
            end
            
            % plot run mean
            plot(trials, nanrunmean(devs(:, dd), rms), 'r-', ...
                'LineWidth', 2);

            % plot zero line
            plot([mnt mxt], [0 0], 'k--');
            
            % set axes
            axis([mnt mxt -4 4]);
            xlabel('Trial number');            
            ylabel(yl{dd});
        end        
        
    % plot vs coh, binned by time
    case {6, 8}  
        
        if showm == 6
            devs   = getFIRA_ec(trials, 'stim_dev');
            ylabel('Deviations (deg)');
            axis([0 99.9 -1 1.5]);

        else
            devs   = getFIRA_ec(trials, 'stim_zdev');
            ylab = 'Deviations (z-score)';
            axis([0 99.9 -.5 .5]);
        end

        % compute mean, sem per coh per time bin per outcome
        pst   = {'d:' 'o-'};
        lsz   = [0.5 2];
        cols  = {'k' 'r' 'g' 'b' 'c' 'm' 'y' 'k' 'r' 'g' 'b'};
        cvals = mean(cbins, 2);
        vals  = nans(size(Lcoh, 2), 2);
        for oo = 1:2
            for tt = 1:size(Ltime, 2)       
                
                % get mean, sem per coherence for this time bin
                for cc = 1:size(Lcoh, 2)
                    Ltr = Lcoh(:,cc)&Ltime(:,tt)&Lout(:,oo);
                    vals(cc, :) = [nanmean(devs(Ltr)) nanse(devs(Ltr))];
                end
                
                % plot mean, sem vs coh
                hs = errorbar(cvals, vals(:, 1), vals(:, 2));
                set(hs, 'Color', cols{tt}, 'LineStyle', 'none', 'MarkerSize', 1);
                plot(cvals, vals(:, 1), pst{oo}, 'Color', cols{tt}, ...
                    'MarkerFaceColor', cols{tt}, 'MarkerSize', 4, ...
                    'LineWidth', lsz(oo));
            end
        end
        
        % draw line at 0
        plot([0 99.9], [0 0], 'k--');
        
        % set axes
        xlabel('Motion strength (% coh)');

   % plot vs time (run mean), binned by coh
    case {7, 9}
        
        if showm == 7
            devs   = getFIRA_ec(trials, 'stim_dev');
            ylabel('Deviations (deg)');
            axis([0 max(view_times) -1 1.5]);

        else
            devs   = getFIRA_ec(trials, 'stim_zdev');
            ylab = 'Deviations (z-score)';
            axis([0 max(view_times) -.5 .5]);
        end

        % compute mean, sem per coh per time bin per outcome
        pst   = {':' '-'};
        cols  = {'k' 'r' 'g' 'b' 'c' 'm' 'y'};
        hold on;
        for oo = 1:2
            for cc = 1:size(Lcoh, 2)
                % for each coh, plot raw pts and runmean (sorted)
                Ltr = Lcoh(:, cc) & Lout(:, oo);
                if sum(Ltr) > 20
                    dd = devs(Ltr);
                    plot(view_times(Ltr), dd, '.', ...
                        'MarkerEdgeColor', cols{cc});
                    [vt, I] = sort(view_times(Ltr));
                    plot(vt, nanrunmean(dd(I), rms), pst{oo}, ...
                        'LineWidth', 2, 'Color', cols{cc});
                end
            end
        end
          
        % draw line at 0
        plot([0 max(view_times)], [0 0], 'k--');
        
        % set axes
        xlabel('Viewing time (ms)');
end
