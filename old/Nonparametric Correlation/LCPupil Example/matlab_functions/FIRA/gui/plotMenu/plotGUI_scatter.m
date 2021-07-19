function varargout = plotGUI_scatter(varargin)
% plotGUI_scatter Application M-file for plotGUI_scatter.fig
%    FIG = plotGUI_scatter launch plotGUI_scatter GUI.
%    plotGUI_scatter('callback_name', ...) invoke the named callback.
%
% GUI wrapper for plotFIRA_scatter

% Last Modified by GUIDE v2.0 07-Feb-2002 11:43:44

if nargin == 0 | ~ischar(varargin{1}) % LAUNCH GUI

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

% set up the menus
gsGUI_ecodeValuesByName('setf', handles.xmenu, 1);
gsGUI_ecodeValuesByName('setf', handles.ymenu, 1);
gsGUI_selectByUniqueID('setf', handles.sbmenu, 1);

% set marker, line styles
set(handles.msmenu, ...
    'String', {'none' '.' 'o' 'x' '+' '*' 's' 'd' 'v' '^' '<' '>' 'p' 'h'}, ...
    'Value', 2);
set(handles.lsmenu, ...
    'String', {'none' '-' ':' '-.' '--' 'runmean...' 'polyfit...' 'means'}, ...
    'Value', 1);

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_scatter);

% dumb variables .. don't need to save them
handles.runmean = [];
handles.polyfit = [];
handles.lsarg   = [];

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'scatter', ...
    {...
    'menu',     'xmenu'; ...
    'menu',     'ymenu';   ...
    'menu',     'sbmenu';   ...
    'menu',     'msmenu';    ...
    'menu',     'lsmenu';    ...
    'rb',       'legendbutton'; ...
    'slider',   'curslider'; ...
    'slider',   'prevslider';...
    'value',    'select'});
    
% Not needed if you call gsGUI_saveSettings
% guidata(handles.figure1, handles);

% update it using axes_cb, which will set up the axes
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
% CALLBACK: lsmenu_cb
%
% Callback for the "linestyle" menu..
% if "runmean..." or "polyfit..." chosen, need small modal dialog
%
function varargout = lsmenu_cb(h, eventdata, handles, varargin)

% get the value from the popup menu
pm = getGUI_pmString(h);

% two special cases ask for parameters...
if strcmp(pm, 'runmean...')
    cstr = inputdlg('Input runmean window size', 'Runmean parameters', 1, {num2str(handles.runmean)});
    handles.runmean = round(abs(sscanf(cstr{:}, '%f')));
    handles.lsarg   = handles.runmean;
    guidata(h, handles);

elseif strcmp(pm, 'polyfit...')
    cstr = inputdlg('Input polyfit degree (integer)', 'Polyfit parameters', 1, {num2str(handles.polyfit)});
    handles.polyfit = round(abs(sscanf(cstr{:}, '%f')));
    handles.lsarg   = handles.polyfit;
    guidata(h, handles);
end

% call update to draw it...
update_cb(handles);

% --------------------------------------------------------------------
%
% SUBROUTINE: update_cb
%
% Calls plotFIRA_scatter, the big kahuna that plots the danged thing
%
function update_cb(handles)

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

% clear if no trials
if isempty(trials)
    return
end

% get sort array, colors for legend
[Lsb, uniques] = gsGUI_selectByUniqueID('getf', handles.sbmenu, trials);
if get(handles.legendbutton, 'Value') & ~strcmp(getGUI_pmString(handles.sbmenu), 'none')
    leg = uniques;
else
    leg = [];
end

% use plotFIRA_scatter to do the work
plotFIRA_scatter( ...
    gsGUI_ecodeValuesByName('getf', handles.xmenu, trials), ...
    gsGUI_ecodeValuesByName('getf', handles.ymenu, trials), ...
    Lsb, ....
    getGUI_pmString(handles.msmenu), ...
    getGUI_pmString(handles.lsmenu), ...
    handles.axes1, leg, ...
    handles.lsarg);
