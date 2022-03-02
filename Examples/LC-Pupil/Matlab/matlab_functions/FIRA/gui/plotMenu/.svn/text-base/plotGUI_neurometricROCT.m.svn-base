function varargout = plotGUI_neurometricROCT(varargin)
% plotGUI_neurometricROC Application M-file for plotGUI_neurometricROCT.fig
%
% Usage:
%    FIG = plotGUI_neurometricROCT({<deleteFcn>})
%       launch plotGUI_neurometricROCT GUI.
%
%    plotGUI_neurometricROCT('callback_name', ...) invoke the named callback.
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

global FIRA

% initialize the spike menu
if ~isempty(FIRA) && isfield(FIRA, 'spikes')
    handles.num_spikes = length(FIRA.spikes.id);
else
    handles.num_spikes = 0;
end
gsGUI_spikeByID('setf', handles.spikemenu);

% coherence/direction/outcome menus 
%   (choose FIRA column with coherence/direction data)
gsGUI_selectByUniqueID('setf', handles.cohmenu,     'dot_coh');
gsGUI_selectByUniqueID('setf', handles.outcomemenu, 'correct');
gsGUI_selectByUniqueID('setf', handles.dirmenu,     'dot_dir');

% alpha, beta
set(handles.alphamenu, 'Value', 1, 'String', {'Pow', 'Exp'});
set(handles.betamenu,  'Value', 1, 'String', {'Const', 'Pow'});

% time bins, min/max times set automatically

% set dir boxes
modes = nanmode(getFIRA_ecodesByName('dot_dir', 'id'));
if length(modes) > 1
    set(handles.d1edit, 'String', num2str(modes(1)));
    set(handles.d2edit, 'String', num2str(modes(2)));
end

% set "vs. time" button
set(handles.timebox, 'Value', 1.0);

% set the epoch menu/edit pairs
gsGUI_ecodeTimesByName('setf', handles.ratebeginmenu, 4, handles.ratebeginedit, 0);
gsGUI_ecodeTimesByName('setf', handles.rateendmenu,   3, handles.rateendedit,   0);

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_neurometricROCT);

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'neurometricROCT', ...
    {...
    'menu',     'spikemenu';        ...
    'menu',     'cohmenu';          ...
    'menu',     'dirmenu';          ...
    'menu',     'alphamenu';        ...
    'menu',     'betamenu';         ...    
    'menu',     'ratebeginmenu';    ...
    'menu',     'rateendmenu';      ...
    'edit',     'sizeedit';         ...
    'edit',     'stepedit';         ...
    'edit',     'mintedit';         ...
    'edit',     'maxtedit';         ...
    'edit',     'd1edit';           ...
    'edit',     'd2edit';           ...
    'edit',     'ratebeginedit';    ...
    'edit',     'rateendedit';      ...
    'check',    'cumulativebox';    ...
    'check',    'showbox';          ...
    'check',    'timebox';          ...
    'check',    'logbox';           ...
    'slider',   'curslider';        ...
    'slider',   'prevslider';       ...
    'value',    'select'});

% Not needed because of call to gsGUI_saveSettings
% store data in the figure's application data
% guidata(handles.figure1, handles);

% update it, which includes setting up the axes
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
%| H is the callback object's handle (obtained using GCBO).
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

global FIRA

% check the spike menu
if ~isempty(FIRA) && isfield(FIRA, 'spikes') && ...
        (handles.num_spikes ~= length(FIRA.spikes.id))

    % set spike ids
    gsGUI_spikeByID('setf', handles.spikemenu);
    handles.num_spikes = length(FIRA.spikes.id);

elseif isempty(FIRA) && handles.num_spikes ~= 0

    % no spikes
    set(handles.spikemenu, 'String', {'no spikes'});
    handles.num_spikes = 0;

end

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

if ~isempty(trials)

    % determines whether sorting by choice or direction
    byChoice = get(handles.choicebox, 'Value');

    % find the number of cohs we have from cohmenu. If sorting by
    % direction, remove 0% coh
    [Lsc, cohs] = gsGUI_selectByUniqueID('getf', handles.cohmenu, trials, 12);
    if ~byChoice
        Lsc(:, cohs==0) = [];
        cohs(cohs==0)   = [];
    end

    % get outcomes... keep only correct, error
    [Lout, outs] = gsGUI_selectByUniqueID('getf', ...
        handles.outcomemenu, trials, 5, [0 1 4905 4906]);
    outs(outs==4905) = 1;
    outs(outs==4906) = 0;

    % look for 2 dirs to compute ROC ... use them or 
    % convert to choice if appropriate
    % get all the dirs from dirmenu, then select the chosen 2
    dirCol = gsGUI_ecodeIDsByName('getf', handles.dirmenu, trials);
    Ldir = dirCol==str2num(get(handles.d1edit, 'String')) | ...
        dirCol == str2num(get(handles.d2edit, 'String'));
    % convert to 1, -1
    dirCol = sign(cos(dirCol*pi/180));
    if byChoice
        dirCol(Lout(:,outs==0)) = -dirCol(Lout(:, outs==0));
    end
    dirCol(~Ldir) = nan;
    dirs = nonanunique(dirCol);
    for dd = 1:length(dirs)
        Lsd(:, dd) = dirCol == dirs(dd);
    end

    % get spike index
    spikei = gsGUI_spikeByID('getf', handles.spikemenu);

    % get epochs
    begin_times = gsGUI_ecodeTimesByName('get', ...
        handles.ratebeginmenu, handles.ratebeginedit, trials);
    end_times   = gsGUI_ecodeTimesByName('get', ...
        handles.rateendmenu,   handles.rateendedit,   trials);
    durs        = end_times - begin_times;

    % get the time bins
    bin_size = max(str2double(get(handles.sizeedit, 'String')), 1);
    bin_step = max(str2double(get(handles.stepedit, 'String')), 1);
    min_time = max(str2double(get(handles.mintedit, 'String')), 0);
    max_time = max(str2double(get(handles.maxtedit, 'String')), 1);

    % trim long trials
    Llong = durs > max_time;
    if any(Llong)
        end_times(Llong) = end_times(Llong) - (durs(Llong) - max_time);
        durs             = end_times - begin_times;
    end
    
    % select good (long enough) trials
    Lgood = durs >= min_time;

    if any(Lgood) && ~all(Lgood)

        trials      = trials(Lgood);
        Lsc         = Lsc(Lgood, :);
        Lout        = Lout(Lgood, :);
        Lsd         = Lsd(Lgood, :);
        begin_times = begin_times(Lgood);
        end_times   = end_times(Lgood);
        durs        = durs(Lgood);
    end
end

if isempty(trials) || length(dirs) ~= 2
   
    cla([handles.topaxis, handles.alphaaxis, handles.betaaxis]);
    return
end

% get time bins
time_bins = [min_time:bin_step:max_time-bin_size]';
time_bins = [time_bins time_bins+bin_size];

% if cumulative flag is set, always start at first bin
if get(handles.cumulativebox, 'Value');
    time_bins(:, 1) = min_time;
end

%%%
% call getFIRA_neurometricROCT to get grid
% of ROC area for coh, view time
%%%
[rocs, ns, sems] = getFIRA_neurometricROCT(trials, Lsd, Lsc, spikei, ...
    begin_times, end_times, time_bins, 5);

fit_dat   = grid2mat(rocs, ns, mean(time_bins, 2), cohs);
fit_dat   = [fit_dat(:, 1) fit_dat(:, 2)./1000 ones(size(fit_dat, 1), 1) fit_dat(:, [3 4])];
time_bins = nonanunique(fit_dat(:,2));

if get(handles.showbox, 'Value')

    % get alpha, beta functions
    afun = get(handles.alphamenu, 'Value') + 1;
    bfun = get(handles.betamenu,  'Value');

    % get fits
    fdat = fit_dat;
    [fits,sems,stats] = quickTs_fit(fit_dat,afun,bfun,[],[],time_bins);
    
    % plot data + fits
    quickTs_plot(fit_dat, fits, sems, afun, bfun, time_bins, ...
        handles.topaxis, handles.alphaaxis, handles.betaaxis, ...
        get(handles.timebox, 'Value'), get(handles.logbox, 'Value'), '.');

else
    global ax
    
    % just plot data
    quickTs_plot(fit_dat, [], [], [], [], time_bins, ...
        ax, [], [], ...%handles.topaxis, [], [], ...
        get(handles.timebox, 'Value'), get(handles.logbox, 'Value'), '.-');
end

return

%%%
% plot grid of data
%%%
co = {'k' 'r' 'g' 'b' 'c' 'm' 'y'};
axes(handles.topaxis); cla; hold on;
if get(handles.timebox, 'Value')

    % plot versus time, binned by coh
    xax  = mean(time_bins, 2);
    bins = cohs;
    for bb = 0:size(bins, 1)-1

        % plot the data
        plot(xax, rocs(:, end-bb), '.-', 'Color', ...
            co{mod(bb, length(co))+1});
    end
    if get(handles.logbox, 'Value')
        set(handles.topaxis, 'XScale', 'log');
    else
        set(handles.topaxis, 'XScale', 'linear');        
    end

else

    % plot versus coh, binned by time
    xax  = cohs';
    xax(xax == 0) = 1;
    bins = mean(time_bins, 2);
    for bb = 1:size(bins, 1)

        % plot the data
        plot(xax, rocs(bb, :), '.-', 'Color', co{mod(bb-1, length(co))+1});
    end
    set(handles.topaxis, 'XScale', 'log');

end
axis([min(xax) max(xax) 0.3 1])
plot([min(xax) max(xax)], [0.5 0.5], 'k:');

%%%
% get/plot fits
%%%
if get(handles.showbox, 'Value')

    a = 'plot fits'
end


% fits = plotFIRA_neurometricROCT(trials, Lsd, ...
%     Lsc, cohs, spikei, begin_times, end_times, tbins, ...
%     get(handles.showbox, 'Value', ...
%     
% 
%     do_fits, handles.topaxis, handles.bottomaxis);
