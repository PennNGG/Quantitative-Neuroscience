function varargout = plotGUI_neurometricROC(varargin)
% plotGUI_neurometricROC Application M-file for plotGUI_neurometricROC.fig
%
% Usage:
%    FIG = plotGUI_neurometricROC({<deleteFcn>})
%       launch plotGUI_neurometricROC GUI.
%
%    plotGUI_neurometricROC('callback_name', ...) invoke the named callback.
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
if ~isempty(FIRA)
    handles.num_spikes = length(FIRA.spikes.id);
else
    handles.num_spikes = 0;
end
gsGUI_spikeByID('setf', handles.spikemenu);

% coherence menu (choose FIRA column with coherence data)
gsGUI_selectByUniqueID('setf', handles.cohmenu, 'dot_coh');
gsGUI_selectByUniqueID('setf', handles.dirmenu, 'dot_dir');

% set dir boxes
modes = nanmode(getFIRA_ecodesByName('dot_dir', 'id'));
if length(modes) > 1
    set(handles.d1edit, 'String', num2str(modes(1)));
    set(handles.d2edit, 'String', num2str(modes(2)));
end

% set the epoch menu/edit pairs
gsGUI_ecodeTimesByName('setf', handles.ratebeginmenu, 4, handles.ratebeginedit, 0);
gsGUI_ecodeTimesByName('setf', handles.rateendmenu,   3, handles.rateendedit,   0);

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_neurometricROC);

% defaults
handles.cohaxes = [];
handles.cohhs   = [];

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'neurometricROC', ...
    {...
    'menu',     'spikemenu'; ...
    'menu',     'cohmenu';   ...
    'menu',     'dirmenu'; ...
    'menu',     'ratebeginmenu';    ...
    'menu',     'rateendmenu';    ...
    'edit',     'd1edit'; ...
    'edit',     'd2edit'; ...
    'edit',     'ratebeginedit';    ...
    'edit',     'rateendedit';    ...
    'slider',   'curslider'; ...
    'slider',   'prevslider';...
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
if ~isempty(FIRA) && (handles.num_spikes ~= length(FIRA.spikes.id))

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

% check that there's data
if isempty(FIRA) || isempty(trials)
    num_axes = 0;
else

    % find the number of cohs we have from cohmenu
    [Lsc, cohs] = gsGUI_selectByUniqueID('getf', handles.cohmenu, trials, 12);
    num_axes    = length(cohs);
end

% check if anything changed
if num_axes ~= length(handles.cohaxes)

    % destroy old axes
    if ~isempty(handles.cohaxes)
        delete(handles.cohaxes);
        handles.cohaxes = [];
        handles.cohhs   = [];
    end

    % make the new ones
    if num_axes
        handles.cohaxes = zeros(num_axes, 1);
        handles.cohhs   = zeros(num_axes, 2);

        x    = .25;     % axis horizontal position
        wid  = .28;     % axis width
        sbp  = 0.01;    % separation between panels
        tmg  = 0.01;    % top margin
        bmg  = 0.05;    % bottom margin
        pht  = (1 - (tmg+bmg))/num_axes;
        ht   = pht - sbp;

        for i = 1:num_axes
            handles.cohaxes(i) = axes('Units', 'normalized', ...
                'Position', [x bmg+(i-1)*pht wid ht]);
            handles.cohhs(i, 1) = bar(0, 0)'; hold on;
            handles.cohhs(i, 2) = bar(0, 0)';            
        end

        if length(handles.cohaxes) > 1
            set(handles.cohaxes(2:end), 'XTickLabel', [], 'XTick', [], 'YTick', []);
        end
        set(handles.cohaxes(1), 'XTickMode', 'auto', 'YTick', []);
        set(handles.cohhs(:, 1), 'EdgeColor', 'r', 'FaceColor', 'r', 'BarWidth', 0.5);
        set(handles.cohhs(:, 2), 'EdgeColor', 'b', 'FaceColor', 'b', 'BarWidth', 0.5);
    end

elseif ~isempty(handles.cohaxes)
    set(handles.cohhs, 'XData', 0, 'YData', 0);
    cla(handles.mainaxis); hold on;
end

% store the application data
guidata(handles.figure1, handles);

% look for 2 dirs to compute ROC
if ~isempty(trials) & num_axes

    % get all the dirs from dirmenu
    [Lsd, dirs] = gsGUI_selectByUniqueID('getf', handles.dirmenu, trials, 12);

    % get the selected dirs
    d1 = str2num(get(handles.d1edit, 'String'));
    d2 = str2num(get(handles.d2edit, 'String'));

    % check that data exist for the given dirs
    d1_ind = find(dirs == d1);
    d2_ind = find(dirs == d2);
    
else

    d1_ind = [];
    d2_ind = [];
end

% get spike index
spikei = gsGUI_spikeByID('getf', handles.spikemenu);

% just return if there's no data
if isempty(d1_ind) || isempty(d2_ind) || isempty(spikei)
    return
end

plotFIRA_neurometricROC(trials, Lsd(:, [d1_ind d2_ind]), Lsc, cohs, spikei, ...
    gsGUI_ecodeTimesByName('get', handles.ratebeginmenu, handles.ratebeginedit, trials), ...
    gsGUI_ecodeTimesByName('get', handles.rateendmenu,   handles.rateendedit,   trials), ...
    [], handles.mainaxis, handles.cohhs);
