function varargout = plotGUI_quickT(varargin)
% plotGUI_quickT Application M-file for plotGUI_quickT.fig
%
% Usage:
%    FIG = plotGUI_quickT({<deleteFcn>})
%       launch plotGUI_quickT GUI.
%
%    plotGUI_quickT('callback_name', ...) invoke the named callback.
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
gsGUI_selectByUniqueID('setf', handles.dirmenu,     'dot_dir');

% set the dot on/off menus
gsGUI_ecodeTimesByName('setf', handles.dotonmenu,  {'dot_on', 'ins_on'});
gsGUI_ecodeTimesByName('setf', handles.dotoffmenu, {'dot_off', 'ins_off'});

% set dir boxes
modes = nanmode(getFIRA_ecodesByName('dot_dir', 'id'));
if length(modes) > 1
    set(handles.d1edit, 'String', num2str(modes(1)));
    set(handles.d2edit, 'String', num2str(modes(2)));
end

% set alpha, beta's
set(handles.alphamenu, 'Value', 1, 'String', {'Const' 'Pow' 'Exp'});
set(handles.betamenu,  'Value', 1, 'String', {'Const' 'Pow'});

% set check boxes
set(handles.logbox,  'Value', 0);
set(handles.fixbox,  'Value', 0);
set(handles.timebox, 'Value', 0);

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_quickT);

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'quickT', ...
    {...
    'menu',     'cohmenu';     ...
    'menu',     'outcomemenu'; ...
    'menu',     'dirmenu';     ...
    'menu',     'dotonmenu';   ...
    'menu',     'dotoffmenu';  ...
    'menu',     'alphamenu';   ...
    'menu',     'betamenu';    ...
    'menu',     'binmenu';     ...
    'edit',     'mintedit';    ...
    'edit',     'maxtedit';    ...
    'edit',     'd1edit';      ...
    'edit',     'd2edit';      ...
    'check',    'logbox';      ...
    'check',    'fixbox';      ...
    'check',    'timebox';     ...
    'slider',   'curslider';   ...
    'slider',   'prevslider';  ...
    'value',    'select'});

% store data in the figure's application data
guidata(handles.figure1, handles);

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

global FIRA

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

if ~isempty(trials)

    % get view times ... only considering trials with
    %   'dot_on' and 'dot_off' codes
    
    % get FIRA data
    cohs     = gsGUI_ecodeIDsByName('getf', handles.cohmenu,     trials);
    outs     = gsGUI_ecodeIDsByName('getf', handles.outcomemenu, trials);
    outs(outs==4905) = 1;
    outs(outs==4906) = 0;
    dirs     = gsGUI_ecodeIDsByName('getf', handles.dirmenu, trials);
    d1       = str2num(get(handles.d1edit, 'String'));
    d2       = str2num(get(handles.d2edit, 'String'));
    tstop    = gsGUI_ecodeTimesByName('getf', handles.dotoffmenu, [], trials);
    tstart   = gsGUI_ecodeTimesByName('getf', handles.dotonmenu,  [], trials);
    min_time = str2num(get(handles.mintedit, 'String'));
    max_time = str2num(get(handles.maxtedit, 'String'));
    
    Lgood = (outs==0|outs==1) & ...
        (dirs==d1|dirs==d2) & ...
        (tstop-tstart>=min_time & tstop-tstart<=max_time);
else
    Lgood = false;
end

if ~any(Lgood)

    % outta
    cla([handles.dir1axis, handles.dir2axis, handles.alphaaxis, ...
        handles.dir4axis]);
    return
end

% Collect data ...
% Columns are:
%    coherence (0...99.9)
%    view time (ms / 1500)
%    dir (-1 left, 1 right)
%    cor (1 correct, 0 error)
dat = [ ...
    cohs(Lgood), ...
    (tstop(Lgood) - tstart(Lgood))./1500, ...
    sign(cos(dirs(Lgood)*pi/180)), ...
    outs(Lgood)];

% get alpha, beta functions
afun = get(handles.alphamenu, 'Value');
bfun = get(handles.betamenu,  'Value');

% get time bins
tbins = getTimeBins(get(handles.binmenu, 'Value'), ...
    min_time, max_time, dat(:, 2), ...
    get(handles.fixbox, 'Value'));

% get fits
[fits,sems,stats] = quickTs_fit(dat,afun,bfun,[],[],tbins);
fits

% plot fits
quickTs_plot(dat, fits, sems, afun, bfun, tbins, ...
    [handles.dir1axis, handles.dir2axis], handles.alphaaxis, handles.betaaxis, ...
    get(handles.timebox, 'Value'), get(handles.logbox, 'Value'), '.');
