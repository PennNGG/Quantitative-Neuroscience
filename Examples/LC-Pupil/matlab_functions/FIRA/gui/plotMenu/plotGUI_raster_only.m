function varargout = plotGUI_raster_only(varargin)
% plotGUI_rasterTC Application M-file for plotGUI_raster.fig
%
% Usage:
%    FIG = plotGUI_rasterTC({<deleteFcn>})
%       launch plotGUI_rasterTC GUI.
%
%    plotGUI_rasterTC('callback_name', ...) invoke the named callback.
%
% wrapper GUI for plotGUI_raster
% modified from plotGUI_raster.m, shows rasters only for all groups, max 24

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
gsGUI_ecodeTimesByName('setf', handles.rateendmenu,   3, handles.rateendedit,   0)
gsGUI_ecodeTimesByName('setf', handles.m1menu,        1, handles.m1edit,        0)
gsGUI_ecodeTimesByName('setf', handles.m2menu,        1, handles.m2edit,        0)

% initialize data for "Select..." button
% it is important that this gets saved in handles.select
handles.select = gsGUI_selectTrials('initf', ...
    handles.selectbutton, @plotGUI_raster_only);

% defaults
handles.rasteraxes = [];
handles.rasterhs   = [];
% handles.psthaxes   = [];
% handles.psthhs     = [];
handles.uniques    = [];

% set up the "save struct" ... see gsGUI_saveSettings for details
handles = gsGUI_saveSettings('setf', handles.figure1, handles, 'raster', ...
    {...
    'rb',       'rasterrb';      ...
%     'rb',       'psthrb';        ...
    'menu',     'spikemenu';     ...
    'menu',     'sbmenu';        ...
    'menu',     'sortmenu';      ...
    'menu',     'binsizemenu';   ...
    'menu',     'rasbeginmenu';  ...
    'menu',     'rasendmenu';    ...
    'menu',     'ratebeginmenu'; ...
    'menu',     'rateendmenu';   ...
    'menu',     'm1menu';        ...
    'menu',     'm2menu';        ...
    'edit',     'rasbeginedit';  ...
    'edit',     'rasendedit';    ...
    'edit',     'ratebeginedit'; ...
    'edit',     'rateendedit';   ...
    'edit',     'm1edit';        ...
    'edit',     'm2edit';        ...
    'slider',   'curslider';     ...
    'slider',   'prevslider';    ...
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
    gsGUI_spikeByID('setf', handles.spikemenu);
    handles.num_spikes = length(FIRA.spikes.id);
elseif isempty(FIRA) && handles.num_spikes ~= 0
    set(handles.spikemenu, 'String', {'no spikes'});
    handles.num_spikes = 0;
end

% get the selected trials
trials = gsGUI_selectTrials('getf', ...
    handles.select, handles.curslider, handles.prevslider);

% delete the axes if there's no data or no axes
if isempty(FIRA) || isempty(FIRA.spikes.data) || isempty(trials)
    cla(handles.rasteraxes);
%     cla(handles.psthaxes);
    guidata(handles.figure1, handles);
    return
end

% find the number of unique selections we have from sbmenu
% and set a max
[Lsb, uniques] = gsGUI_selectByUniqueID('getf', handles.sbmenu, trials, 24);

%%%
% Set up the raster/psth axes
%%%
num_axes = length(uniques); % get(handles.binsizemenu, 'Value');
num_rast = num_axes*get(handles.rasterrb, 'Value');
% num_psth = num_axes*get(handles.psthrb,   'Value');

% check if anything changed
if num_rast ~= length(handles.rasteraxes)          || ...
        length(uniques) ~= length(handles.uniques) || ...
        any(uniques ~= handles.uniques)

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
        handles.rasterhs = zeros(num_rast, 5);
    end

%     if ~isempty(handles.psthaxes)
%         delete(handles.psthaxes);
%         handles.psthaxes = [];
%         handles.psthhs   = [];
%     end
%     if num_psth
%         handles.psthaxes = zeros(num_psth, 1);
%         handles.psthhs   = zeros(num_psth, 2);
%     end

%     if num_rast + num_psth > 0
    if num_rast > 0
        
        % axis stuff
        br  = [.22 .02 .78 .98];
        sbr = 0.04;
        sbc = 0.02;
        rc  = [ ...
            1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 4;  ...  % number of rows
            1 2 3 2 3 3 4 4 3 4 4 4 4 4 4 4];      % number of columns

        sht  = br(4)/rc(1,num_axes);
        swid = br(3)/rc(2,num_axes);
%         sf   = (num_rast>0)+(num_psth>0);
        sf   = (num_rast>0);
        ht   = 1/sf*sht-sbr;
        boff = (sf-1)*ht;
        wid  = swid - sbc;
        ind = 0;

%         for bot = fliplr(br(2)+sht*[0:rc(1,num_axes)-1])
%             for left = br(1)+swid*[0:rc(2,num_axes)-1]
%             ind = ind + 1;
%                 if ind <= num_axes
                    
        for ind = 1:num_axes
                    if num_rast
%                         handles.rasteraxes(ind) = axes('Units', 'normalized', 'Position', ...
%                             [left bot+boff wid ht]);
                        handles.rasteraxes(ind) = subplot(4,6, ind);

                        handles.rasterhs(ind, 1) = plot(0, 0, 'k+')'; hold on;
                        handles.rasterhs(ind, 2) = plot(0, 0, 'k-')';
                        handles.rasterhs(ind, 3) = plot(0, 0, 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 2)';
                        handles.rasterhs(ind, 4) = plot(0, 0, 'g^', 'MarkerFaceColor', 'g', 'MarkerSize', 2)';
                        handles.rasterhs(ind, 5) = plot(0, 0, 'b^', 'MarkerFaceColor', 'b', 'MarkerSize', 2)';
                        set(handles.rasteraxes(ind), 'XTickLabel', [], 'XTick', [], ...
                            'YTickLabel', [], 'YTick', []);
                    end

%                     if num_psth
%                         handles.psthaxes(ind) = axes('Units', 'normalized', 'Position', ...
%                             [left bot wid ht]);
%                         handles.psthhs(ind, 1) = bar(0, 0)'; hold on;
%                         handles.psthhs(ind, 2) = plot(0, 0, 'k-')';
%                         set(handles.psthaxes(ind), 'XTickLabel', [], 'XTick', [], ...
%                             'YTickLabel', [], 'YTick', []);
%                     end
%                 end
%             end
        end
    end
end

% store data in the figure's application data
guidata(handles.figure1, handles);

% outta if nothing showing
% if ~num_axes || (num_rast + num_psth) == 0
%     return
% end
if ~num_axes || num_rast == 0
    return
end

% plot it using plotFIRA_rasterPSTH
[stats, badTrials] = plotFIRA_rasterPSTH(trials, Lsb, ...
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
    get(handles.binsizemenu, 'Value'), get(handles.sortmenu, 'Value'), ...
    handles.rasteraxes, handles.rasterhs, [], []);

% add stats to titles
if num_rast > 0
    axs = handles.rasteraxes;
% else
%     axs = handles.psthaxes;
end
str = getGUI_pmString(handles.sbmenu);
str(str=='_') = '.';
for i = 1:num_axes
    title(axs(i), sprintf('%s=%.1f (n=%d; bt=%d)\n%.1f+-%.1f / %.1f+-%.1f', ...
        str, uniques(i), stats(i, 6), badTrials, ...
        stats(i, 1), stats(i, 3), stats(i, 4), stats(i, 5)));
end