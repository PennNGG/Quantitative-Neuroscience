function varargout = plotGUI_polarTC(varargin)
% plotGUI_rasterTC Application M-file for plotGUI_polarTC.fig
%
% Usage:
%    FIG = plotGUI_polarTC({<deleteFcn>})
%       launch plotGUI_polarTC GUI.
%
%    plotGUI_polarTC('callback_name', ...) invoke the named callback.
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

% sort by menu
gsGUI_selectByUniqueID('setf', handles.sbmenu, 1);

% set the epoch menu/edit pairs
gsGUI_ecodeTimesByName('setf', handles.rasbeginmenu,  2, handles.rasbeginedit,  0)
gsGUI_ecodeTimesByName('setf', handles.rasendmenu,    3, handles.rasendedit,    0)
gsGUI_ecodeTimesByName('setf', handles.ratebeginmenu, 1, handles.ratebeginedit, 0)
gsGUI_ecodeTimesByName('setf', handles.rateendmenu,   1, handles.rateendedit,   0)
gsGUI_ecodeTimesByName('setf', handles.m1menu,        1, handles.m1edit,        0)
gsGUI_ecodeTimesByName('setf', handles.m2menu,        1, handles.m2edit,        0)

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_polarTC);

% defaults
handles.polaraxis  = axes('Units', 'normalized', 'Position', [0.47 0.34 0.35 0.35]);
handles.rasteraxes = [];
handles.rasterhs   = [];
handles.psthaxes   = [];
handles.psthhs     = [];
handles.uniques    = [];

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'polarTC', ...
    {...
    'rb',       'rasterrb'; ...
    'rb',       'psthrb'; ...
    'menu',     'spikemenu'; ...
    'menu',     'sbmenu';   ...
    'menu',     'smenu';   ...
    'menu',     'binsizemenu'; ...
    'menu',     'rasbeginmenu';    ...
    'menu',     'rasendmenu';    ...
    'menu',     'ratebeginmenu';    ...
    'menu',     'rateendmenu';    ...
    'menu',     'm1menu';    ...
    'menu',     'm2menu';    ...
    'edit',     'rasbeginedit';    ...
    'edit',     'rasendedit';    ...
    'edit',     'ratebeginedit';    ...
    'edit',     'rateendedit';    ...
    'edit',     'm1edit';    ...
    'edit',     'm2edit';    ...
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
if ~isempty(FIRA) & (handles.num_spikes ~= length(FIRA.spikes.id))
    gsGUI_spikeByID('setf', handles.spikemenu);
    handles.num_spikes = length(FIRA.spikes.id);
elseif isempty(FIRA) & handles.num_spikes ~= 0
    set(handles.spikemenu, 'String', {'no spikes'});
    handles.num_spikes = 0;
end

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

% delete the axes if there's no data or no axes
if isempty(FIRA) || isempty(FIRA.spikes.data) || isempty(trials)
    cla(handles.polaraxis);
    cla(handles.rasteraxes);
    cla(handles.psthaxes);
    guidata(handles.figure1, handles);
    return
end

% find the number of unique selections we have from sbmenu
[Lsb, uniques] = gsGUI_selectByUniqueID('getf', handles.sbmenu, trials, 12);

%%%
% Set up the raster/psth axes
%%%
num_axes = length(uniques);
num_rast = num_axes*get(handles.rasterrb, 'Value');
num_psth = num_axes*get(handles.psthrb,   'Value');

% check if anything changed
if num_rast ~= length(handles.rasteraxes)          | ...
        num_psth ~= length(handles.psthaxes)       | ...
        length(uniques) ~= length(handles.uniques) | ...
        any(uniques ~= handles.uniques)

    % set to current figure
    figure(handles.figure1);
    
    % save the new set & destroy old ones
    handles.uniques = uniques;

    if ~isempty(handles.rasteraxes)
        delete(handles.rasteraxes);
        handles.rasteraxes = [];
        handles.rasterhs   = [];
    end
    if num_rast
        handles.rasteraxes = zeros(num_rast, 1);
        % handles for 5 different plot objects:
        %   1. the raster data
        %   2. line at 0
        %   3. marker at rate off
        %   4. m1 (optional, from gui)
        %   5. m2 (optional, from gui)
        handles.rasterhs   = zeros(num_rast, 5); % data + line at
    end

    if ~isempty(handles.psthaxes)
        delete(handles.psthaxes);
        handles.psthaxes = [];
        handles.psthhs   = [];
    end
    if num_psth
        handles.psthaxes = zeros(num_psth, 1);
        handles.psthhs   = zeros(num_psth, 2);
    end

    % plot params
    ctr_x = .55;
    ctr_y = .38;
    if num_rast & num_psth
        sz = [.26 .36 .18 0.125 0.125];
    else
        sz = [.26 .36 .18 0.25  0];
    end

    % make arrays of axes, plot handles
    for i = 1:num_axes

        if num_rast
            handles.rasteraxes(i) = axes('Units', 'normalized', 'Position', ...
                [cos(uniques(i)*pi/180)*sz(1)+0.55...
                sin(uniques(i)*pi/180)*sz(2)+0.38+sz(5) sz(3) sz(4)]);
            handles.rasterhs(i, 1) = plot(0, 0, 'k+')'; hold on;
            handles.rasterhs(i, 2) = plot(0, 0, 'k-')';
            handles.rasterhs(i, 3) = plot(0, 0, 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 2)';
            handles.rasterhs(i, 4) = plot(0, 0, 'g^', 'MarkerFaceColor', 'g', 'MarkerSize', 2)';
            handles.rasterhs(i, 5) = plot(0, 0, 'b^', 'MarkerFaceColor', 'b', 'MarkerSize', 2)';
            set(handles.rasteraxes(i), 'XTickLabel', [], 'XTick', [], ...
                'YTickLabel', [], 'YTick', []);
        end

        if num_psth
            handles.psthaxes(i) = axes('Units', 'normalized', 'Position', ...
                [cos(uniques(i)*pi/180)*sz(1)+0.55...
                sin(uniques(i)*pi/180)*sz(2)+0.38 sz(3) sz(4)]);
            handles.psthhs(i, 1) = bar(0, 0)'; hold on;
            handles.psthhs(i, 2) = plot(0, 0, 'k-')';
            set(handles.psthaxes(i), 'XTickLabel', [], 'XTick', [], ...
                'YTickLabel', [], 'YTick', []);
        end
    end
end

% store data in the figure's application data
guidata(handles.figure1, handles);

% outta if nothing showing
if ~num_axes
    return
end

% plot it using plotFIRA_rasterPSTH
stats = plotFIRA_rasterPSTH(trials, Lsb, ...
    gsGUI_spikeByID('getf', handles.spikemenu), ...
    gsGUI_ecodeTimesByName('get', handles.rasbeginmenu,  handles.rasbeginedit,  trials), ...
    gsGUI_ecodeTimesByName('get', handles.rasendmenu,    handles.rasendedit,    trials), ...
    gsGUI_ecodeTimesByName('get', handles.ratebeginmenu, handles.ratebeginedit, trials), ...
    gsGUI_ecodeTimesByName('get', handles.rateendmenu,   handles.rateendedit,   trials), ...
    [ ... % markers follow ... always show rateend, m1/m2 optional
    gsGUI_ecodeTimesByName('get', handles.rateendmenu,   handles.rateendedit,   trials), ...
    gsGUI_ecodeTimesByName('get', handles.m1menu,        handles.m1edit,        trials), ...
    gsGUI_ecodeTimesByName('get', handles.m2menu,        handles.m2edit,        trials), ...
    ], ...
    get(handles.binsizemenu, 'Value'), get(handles.smenu, 'Value'), ...
    handles.rasteraxes, handles.rasterhs, handles.psthaxes, handles.psthhs);

% plot the polar data (being sure to "close the loop")
cla(handles.polaraxis, 'reset');
h = polar(handles.polaraxis, uniques([1:end 1],:)*pi/180, stats([1:end 1], 1), 'ko-');
set(h, 'LineWidth', 2, 'MarkerFaceColor', 'k');
hold(handles.polaraxis, 'on');
h = polar(handles.polaraxis, uniques([1:end 1],:)*pi/180, stats([1:end 1], 4), 'ro-');
set(h, 'LineWidth', 2, 'MarkerFaceColor', 'r');


% compute the fit from Jeff's magical program
stats = stats(~isnan(stats(:,1)), :);
if length(uniques) > 2 & sum(stats(:,1))
    [th, width, s] = getTuning(pi/180*uniques, stats(:,1), stats(:,2), stats(:,5), 'VonMises');
    set(handles.vmtext, 'String', ...
        sprintf('vMis: m=%.0f s=%.0f p=%.2f', 180/pi*th, 180/pi*width, s(3)));
    
    [th, width, s] = getTuning(pi/180*uniques, stats(:,1), stats(:,2), stats(:,5), 'VectorAvg');
    set(handles.vatext, 'String', ...
        sprintf('vAvg: m=%.0f s=%.0f r=%.2f', 180/pi*th, 180/pi*width, s(1)));
    
    if s(2)
        set(handles.iDir, 'String', sprintf('isDirectional: yes'));
    else
        set(handles.iDir, 'String', sprintf('isDirectional: no'));
    end 
    
else
    set(handles.vmtext, 'String', 'vMis:');
    set(handles.vatext, 'String', 'vAvg:');
end