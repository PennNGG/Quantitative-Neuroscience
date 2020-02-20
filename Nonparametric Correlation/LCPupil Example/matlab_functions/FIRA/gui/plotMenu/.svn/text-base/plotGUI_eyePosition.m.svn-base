function varargout = plotGUI_eyePosition(varargin)
% plotGUI_eyePosition Application M-file for plotFIRA_eyes.fig
%
% Usage:
%    FIG = plotGUI_eyePosition({<deleteFcn>})
%       launch plotGUI_eyePosition GUI.
%
%    plotGUI_eyePosition('callback_name', ...) invoke the named callback.
%
% wrapper GUI for plotFIRA_eyePosition

% Last Modified by GUIDE v2.0 12-Feb-2002 17:21:04

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

% set the epoch menu/edit pairs
gsGUI_ecodeTimesByName('setf', handles.beginmenu, 1, handles.beginedit, 0)
gsGUI_ecodeTimesByName('setf', handles.endmenu,   1, handles.endedit,   0)
gsGUI_ecodeTimesByName('setf', handles.wrtmenu,   1, handles.wrtedit,   0)
gsGUI_ecodeTimesByName('setf', handles.m1menu,    1, handles.m1edit,    0)
gsGUI_ecodeTimesByName('setf', handles.m2menu,    1, handles.m2edit,    0)
gsGUI_selectByUniqueID('setf', handles.sbcmenu,   1);

% set min/max epoch times
set(handles.minedit, 'String', '0');
set(handles.maxedit, 'String', '4000');

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_eyePosition);

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'eyePosition', ...
    {...
    'rb',       'ax1button'; ...
    'rb',       'ax2button'; ...
    'rb',       'ax3button'; ...
    'menu',     'beginmenu'; ...
    'menu',     'endmenu';   ...
    'menu',     'wrtmenu';   ...
    'menu',     'm1menu';    ...
    'menu',     'm2menu';    ...
    'menu',     'sbcmenu';   ...
    'menu',     'gainmenu';  ...
    'menu',     'scalemenu'; ...
    'slider',   'curslider'; ...
    'slider',   'prevslider';...
    'edit',     'beginedit'; ...
    'edit',     'endedit';   ...
    'edit',     'wrtedit';   ...
    'edit',     'm1edit';    ...
    'edit',     'm2edit';    ...
    'edit',     'minedit';   ...
    'edit',     'maxedit';   ...
    'value',    'select'});

% Not needed if you call gsGUI_saveSettings
% guidata(handles.figure1, handles);

% update it using axes_cb, which will set up the axes
axes_cb(handles.figure1, [], guidata(handles.figure1));

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
% CALLBACK: axes_cb
%
% Callback that sets up the axes.. called by radiobuttons,
%    gain, etc
%
function varargout = axes_cb(h, eventdata, handles, varargin)

ax =   [get(handles.ax1button, 'Value') handles.axes1; ...
    get(handles.ax2button, 'Value') handles.axes2; ...
    get(handles.ax3button, 'Value') handles.axes3];
if sum(ax(:,1)) == 3
    set(handles.axes1, 'Units', 'normalized', 'Position', [.4 .67 .55 .28], 'Visible', 'on');
    set(handles.axes2, 'Units', 'normalized', 'Position', [.4 .34 .55 .28], 'Visible', 'on');
    set(handles.axes3, 'Units', 'normalized', 'Position', [.4 .01 .55 .28], 'Visible', 'on');
elseif sum(ax(:,1)) == 2
    axs = ax(ax(:,1)==1,2);
    set(axs(1), 'Units', 'normalized', 'Position', [.4 .51 .55 .43], 'Visible', 'on');
    set(axs(2), 'Units', 'normalized', 'Position', [.4 .05 .55 .43], 'Visible', 'on');
else
    set(ax(ax(:,1)==1,2), 'Units', 'normalized', 'Position', [.4 .05 .55 .92], 'Visible', 'on');
end

% clear the invisible axes of children
for a = ax(ax(:,1)==0, 2)'
    set(a, 'Visible', 'off');
    axes(a);
    cla;
end

% scale the axes that are showing
scale = str2num(getGUI_pmString(handles.scalemenu));
if ~isempty(scale)
    set(handles.axes1, 'YLim', [-scale scale]);
    set(handles.axes2, 'YLim', [-scale scale]);
    set(handles.axes3, 'XLim', [-scale scale], 'YLim', [-scale scale]);
else
    set(handles.axes1, 'YLimMode', 'auto')
    set(handles.axes2, 'YLimMode', 'auto')
    set(handles.axes3, 'XLimMode', 'auto', 'YLimMode', 'auto')
end

% call update to draw it...
update_cb(handles);

% --------------------------------------------------------------------
%
% CALLBACK: update_cb
%
% The big kahuna that plots the danged thing... called directly
% from the "update" button
%
function update_cb(handles)

% make sure we're drawing something
if(get(handles.ax1button, 'Value'))
    axes1 = handles.axes1;
else
    axes1 = [];
end

if(get(handles.ax2button, 'Value'))
    axes2 = handles.axes2;
else
    axes2 = [];
end

if(get(handles.ax3button, 'Value'))
    axes3 = handles.axes3;
else
    axes3 = [];
end

if isempty(axes1) && isempty(axes2) && isempty(axes3)
    return
end

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

% clear if no trials
if isempty(trials)
    cla(axes1);
    cla(axes2);
    cla(axes3);
    return
end

% see plotFIRA_eyePosition for details
plotFIRA_eyePosition(...
    trials, ... % trial selection
    gsGUI_ecodeTimesByName('getf', handles.beginmenu, handles.beginedit, trials), ...
    gsGUI_ecodeTimesByName('getf', handles.endmenu,   handles.endedit,   trials), ...
    gsGUI_ecodeTimesByName('getf', handles.wrtmenu,   handles.wrtedit,   trials), ...
    [str2double(get(handles.minedit, 'String')), ...
     str2double(get(handles.maxedit, 'String'))], ...
    gsGUI_selectByUniqueID('getf', handles.sbcmenu, trials), ...
    [gsGUI_ecodeTimesByName('getf', handles.m1menu, handles.m1edit, trials), ...
     gsGUI_ecodeTimesByName('getf', handles.m2menu, handles.m2edit, trials)], ...
    str2double(getGUI_pmString(handles.gainmenu)), ...
    axes1, axes2, axes3);
