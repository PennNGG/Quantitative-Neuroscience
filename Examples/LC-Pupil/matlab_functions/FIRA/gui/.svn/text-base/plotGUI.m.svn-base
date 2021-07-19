function varargout = plotGUI(varargin)
% plotGUI Application M-file for plotGUI.fig
%    FIG = plotGUI launch plotGUI GUI.
%    plotGUI('callback_name', ...) invoke the named callback.
%
% This is the main gui for analyzing FIRA data files
%

% created 2/10/02 by jig
% 11/12/02 jd added response field feature
% 11/25/02 jd fixed automatic update
% 2/4/03 jd added manual spike header update request
% 7/10/03 jd added support for 4th spm function
% 11/04/04 jig updated for new FIRA

% Last Modified by GUIDE v2.0 14-Feb-2002 09:42:28
global mainfig

if nargin == 0  % LAUNCH GUI

	mainfig = openfig(mfilename,'reuse');
    
	% Use system color scheme for figure:
	set(mainfig, 'Color', get(0, 'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(mainfig);
    
    % create a timer for automatic FIRA update .. period defaults to zero
    set(handles.updateslider, 'Value', 0);
    set(handles.updatetext, 'String', 'Auto Update off');
    handles.update_timer = timer( ...
        'TimerFcn',         @update_timer_Callback, ...
        'ExecutionMode',    'fixedSpacing', ...
        'Period',           0.01);
    
    % create a timer for script iti
    period = round(get(handles.itislider, 'Value')*1000)/1000;
    set(handles.ititext, 'String', sprintf('ITI: %.2f sec', period));
    handles.iti_timer = timer( ...
        'TimerFcn',         @iti_timer_Callback, ...
        'ExecutionMode',    'fixedSpacing', ...
        'Period',           period);

    % THIS IS WHERE WE REGISTER THE PLOT TYPES
    % we assume that each type has an associated function
    % named plotGUI_<name>, and each function has 
    % "setup" and "update" methods
    handles.plots = struct('name', { ...
        'summary';          ...
        'scatter';          ...
        'eyePosition';      ...
        'psychometric';     ...
        'quickT';           ...
        'polarTC';          ...
        'raster';           ...
        'neurometricROC';   ...
        'neurometricROCT';  ...
        'deviations';       ...
        }, 'func', [], 'figs', []);

    % make the menus
    for i = 1:length(handles.plots)
        uimenu(handles.Plotmenu, ...
            'Label',    [handles.plots(i).name '...'], ...
            'tag',      handles.plots(i).name, ...
            'Callback', ['plotGUI(''Plot_Callback'',gcbo,[],guidata(gcbo))']);
        handles.plots(i).func = str2func(strcat('plotGUI_', handles.plots(i).name));
    end

    % associate the handles with the main figure
	guidata(mainfig, handles);

    % now make sure everything is set up appropriately
    setup_all(handles);

	if nargout > 0
		varargout{1} = mainfig;
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
% SUBROUTINE: setup_all
%
% Goes through each of the figure children & sets them up appropriately
%
function setup_all(handles)

global FIRA

if isempty(FIRA)
    %%%
    % No data
    %%%
    set(handles.text1,          'String',  'Status: no data');
    set(handles.updatebutton,   'Visible', 'off');
    set(handles.purgebutton,    'Visible', 'off');
    set(handles.updatetext,     'Visible', 'off');
    set(handles.updateslider,   'Visible', 'off');
    set(handles.startbutton,    'Visible', 'off');
    set(handles.pausebutton,    'Visible', 'off');
    set(handles.stopbutton,     'Visible', 'off');
    set(handles.ititext,        'Visible', 'off');
    set(handles.itislider,        'Visible', 'off');
    
elseif strcmp(FIRA.header.filetype, 'connect')
    %%%
    % Connected to Plexon
    %%%
    set(handles.text1,          'String', ...
        sprintf('Status: connected to Plexon, %d trials', size(FIRA.ecodes.data,1)));
    set(handles.updatebutton,   'Visible', 'on');
    set(handles.purgebutton,    'Visible', 'on');
    set(handles.updatetext,     'Visible', 'on');
    set(handles.updateslider,   'Visible', 'on');
    set(handles.startbutton,    'Visible', 'off');
    set(handles.pausebutton,    'Visible', 'off');
    set(handles.stopbutton,     'Visible', 'off');
    set(handles.ititext,        'Visible', 'off');
    set(handles.itislider,      'Visible', 'off');

    % start the auto timer
    if(get(handles.updateslider, 'Value') > 0.01)
        start(handles.update_timer);
    end

elseif strcmp(FIRA.header.filetype, 'psych')
    %%%
    % running psych script
    %%%
    set(handles.text1,          'String', ...
        sprintf('Status: running script, %d trials', size(FIRA.ecodes.data, 1)));
    set(handles.updatebutton,   'Visible', 'off');
    set(handles.purgebutton,    'Visible', 'off');
    set(handles.updatetext,     'Visible', 'off');
    set(handles.updateslider,   'Visible', 'off');
    set(handles.startbutton,    'Visible', 'on');
    set(handles.pausebutton,    'Visible', 'on');
    set(handles.stopbutton,     'Visible', 'on');
    set(handles.ititext,        'Visible', 'on');
    set(handles.itislider,      'Visible', 'on');

else
    %%%
    % Opened a file
    %%%
    if isempty(FIRA.header.filename) || strcmp(FIRA.header.filename,'auto') %BSH ||
        set(handles.text1, 'String', ...
            sprintf('Status: file (unnamed), %d trials', size(FIRA.ecodes.data,1)));
    else
        [pathstr, name, ext, versn] = fileparts(FIRA.header.filename{1});
        set(handles.text1, 'String', ...
            sprintf('Status: file <%s>, %d trials', name, size(FIRA.ecodes.data,1)));
    end
    set(handles.updatebutton,   'Visible', 'off');
    set(handles.purgebutton,    'Visible', 'off');
    set(handles.updatetext,     'Visible', 'off');
    set(handles.updateslider,   'Visible', 'off');
    set(handles.startbutton,    'Visible', 'off');
    set(handles.pausebutton,    'Visible', 'off');
    set(handles.stopbutton,     'Visible', 'off');
    set(handles.ititext,        'Visible', 'off');
    set(handles.itislider,      'Visible', 'off');
end

% set up all of the figures
for i = 1:length(handles.plots)
    for j = 1:length(handles.plots(i).figs)
        feval(handles.plots(i).func, 'setup', guidata(handles.plots(i).figs(j)));
    end
end

% --------------------------------------------------------------------
%
% SUBROUTINE: update_all
%
% update all of the figures
%
function update_all(handles)

for i = 1:length(handles.plots)
    for j = 1:length(handles.plots(i).figs)
        feval(handles.plots(i).func, 'update_cb', guidata(handles.plots(i).figs(j)));
    end
end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'itislider_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.itislider. This
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

%%%
% MENU CALLBACKS 
%%%

% --------------------------------------------------------------------
% File Menu
%  Open...
%
% CALLBACK: Openentry_Callback
%
% calls "uigetfile" to get the filename from the filesystem, 
% then figures out what kind of file it is & whether it can
% be opened.
%
function varargout = Openentry_Callback(h, eventdata, handles, varargin)

global FIRA

% close anything that's open
if ~isempty(FIRA)    
    if ~strcmp('Yes', questdlg('Do you want to close the existing file?', 'File open', ...
            'Yes', 'No', 'Yes'))
        return
    end
    Closeentry_Callback(h, eventdata, handles);
end

% use uigetfile dialog to get the file name
[fname, pname] = uigetfile( ...
       {'*.mat;*.nex;*.plx;*.A;*.E;*.gz', 'data files'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a data file');
if ~fname
    return
end
              
% check if the file is a '.mat' file with FIRA in it
filename = [pname fname];

if length(filename) > 4 & strcmp(filename(end-3:end), '.mat')

    % let openFIRA do the work of finding the appropriate variable,
    % setting it to the global FIRA and converting it to new-style
    openFIRA(filename);
else
    
    % Otherwise try to read a raw data file
    % First get the params to use to convert to FIRA
    params = getGUI_FIRAparams;
    
    if ~isempty(params) % not cancelled

        % setup the FIRA data structure
        set(handles.text1, 'String', sprintf('Status: reading file <%s>.', fname))
        drawnow;

        % call buildScript bFile to build FIRA from filename
        bFile(filename, [], params.generator, [], params.keep_spikes, ...
            params.keep_sigs, params.keep_matlab, params.keep_dio, ...
            params.flags, handles.text1);
    end
end

% make sure everything is set up appropriately for the new FIRA
setup_all(handles);

% --------------------------------------------------------------------
% File Menu
%  Connect...
% 
% CALLBACK: Connectentry_Callback
%
% makes a connection to the plexon server
%
function varargout = Connectentry_Callback(h, eventdata, handles, varargin)

global FIRA

% make sure we're on the right computer
if ~(strcmp(computer, 'PCWIN') || strcmp(computer, 'PCWIN64'))
    errordlg('Wrong computer, woopiedoopie');
    return
end

% Close anything that's open
if ~isempty(FIRA)
    if ~strcmp('Yes', questdlg('Do you want to close the existing file?', 'File open', ...
        'Yes', 'No', 'Yes'))
        return;
    end
    Closeentry_Callback(h, eventdata, handles);
end

% Get the params to use to convert to FIRA
params = getGUI_FIRAparams;
if ~isempty(params) % not cancelled

    % make the connection
    bConnect(params.generator, params.keep_spikes, params.keep_sigs, ...
        params.keep_matlab, params.keep_dio, params.flags);
end

% make sure everything is set up appropriately for the new FIRA
setup_all(handles);

% --------------------------------------------------------------------
% File Menu
%  Run Script...
% 
% CALLBACK: Scriptentry_Callback
%
% run a script
%
function varargout = Scriptentry_Callback(h, eventdata, handles, varargin)

% nothing for now
return

global FIRA

% make sure we're on the right computer
AssertOSX;

% Close anything that's open
if ~isempty(FIRA)
    if ~strcmp('Yes', questdlg('Do you want to close the existing file?', 'File open', ...
        'Yes', 'No', 'Yes'))
        return;
    end
    Closeentry_Callback(h, eventdata, handles);
end

% use uigetfile dialog to get the file name
% restrict to .m files
[fname, pname] = uigetfile( ...
       {'*.m', 'm-files'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Pick an exp file');
if ~fname
    return
end

if ~isempty(fname) && strncmp(fname, 'exp', 3) &&...
        fname(end) == 'm'
    
    % save the function name
    handles.scripthandle = str2func(fname(1:end-2));
    handles.scripton     = false;
    guidata(h, handles); 

    % run script with 'init' flag
    feval(handles.scripthandle, 'setup');
    
    % setup the figs
    setup_all(handles);
end

% --------------------------------------------------------------------
% File Menu
%  Close
% 
% CALLBACK: Closeentry_Callback
%
% Closes the current copy of FIRA
%
function varargout = Closeentry_Callback(h, eventdata, handles, varargin)

global FIRA

if isempty(FIRA)
    return
end

if strcmp(FIRA.header.filetype, 'connect')

    % Close connection to plexon
    PL_Close(FIRA.header.filename);

    % stop the automatic update (in case it is still active)
    stop(handles.update_timer);     
end

% clear FIRA
FIRA = [];

% now make sure everything is set up appropriately
setup_all(handles);

% --------------------------------------------------------------------
% File Menu
%  Save As...
%
% CALLBACK: Saveasentry_Callback
%
% Saves FIRA to a file 
% WARNING: this removes all the temporary fields of FIRA
%   spm, raw, trial
function varargout = Saveasentry_Callback(h, eventdata, handles, varargin)

global FIRA mainfig

% make sure there's something to save
if isempty(FIRA)
    return
end

% get a filename
[fname,pname] = uiputfile('*.*', 'Select filename for writing');
if ~fname % selected 'cancel'
    return
end
outname = [pname fname]

% if we're connected, we need to run the "cleanup" routine
if strcmp(FIRA.header.filetype, 'connect')    
    cleaupbutton_Callback(mainfig, [], guidata(mainfig));
end

% save it
saveFIRA(outname);

% --------------------------------------------------------------------
% Plot Menu
% 
% CALLBACK: Plot_callback
%
% generic callback function ... calls the appropriate function based on 
%   its tag
%
function varargout = Plot_Callback(h, eventdata, handles, varargin)

% get the tag (string)
tag = get(h, 'tag');

% call the plot routine with the "destroy" callback as an argument
ind = find(strcmp(tag, {handles.plots.name}));
if isscalar(ind)
    handles.plots(ind).figs(end+1) = feval(handles.plots(ind).func, ...
        {['plotGUI(''figure_destroy_Callback'', ''' tag ''', gcbo)']});
    guidata(h, handles);   
end

%%%
% Other Callbacks
%%%

% --------------------------------------------------------------------
%
% CALLBACK: delete_Callback
%
%   called when closing the window
% 
function varargout = delete_Callback(h, eventdata, handles, varargin)

% stop the timer(s)
stop(handles.update_timer);
stop(handles.iti_timer);

% delete all the figs
for i = 1:length(handles.plots)
    delete(handles.plots(i).figs);
    handles.plots(i).figs = [];
end
guidata(h, handles);

% --------------------------------------------------------------------
%
% CALLBACK: updatebutton_Callback
%
%   called when "Update" button is pressed. reads data & updates plots.
%
function varargout = updatebutton_Callback(h, eventdata, handles, varargin)

global FIRA

% call connect_loop function
bConnect_loop;

% update status message
if isempty(FIRA.ecodes.data)
    num_trials = 0;
else
    num_trials = sum(~isnan(FIRA.ecodes.data(:,1)));
end
set(handles.text1, 'String', ...
    sprintf('Status: connected to Plexon, %d trials', num_trials));

% update the display
update_all(handles)

% --------------------------------------------------------------------
% 
% CALLBACK: updateslider_Callback
%
%   called when the "auto update" slider is changed.
%       sets a timer that calls "update" automatically, every n seconds
%

function varargout = updateslider_Callback(h, eventdata, handles, varargin)

% get the new period from the slider
period = round(get(h, 'Value')*1000)/1000;

if period < 0.1
    
    % inactivate timer
    stop(handles.update_timer);
    set(handles.updatetext, 'String', 'Auto Update off');

else

    % show period
    set(handles.updatetext, 'String', sprintf('Auto Update: %.1f sec', period));

    % set period (timer must be off)
    if strcmp(get(handles.update_timer, 'Running'), 'on')
        stop(handles.update_timer);
        set(handles.update_timer, 'Period', period);
        start(handles.update_timer);
    else
        set(handles.update_timer, 'Period', period);
        start(handles.update_timer);
    end
end

% --------------------------------------------------------------------
%
% CALLBACK: update_timer_Callback
%
%   called each timer interval
%
function update_timer_Callback(varargin)

global mainfig

updatebutton_Callback(mainfig,[],guidata(mainfig));

% --------------------------------------------------------------------
%
% CALLBACK: purgebutton_Callback
%
%   called when "Purge" button is pressed. 
%   calls builFIRA_purge to purge data from FIRA
%
function varargout = purgebutton_Callback(h, eventdata, handles, varargin)

global FIRA

% purge data
buildFIRA_purge;

% update all of the figures
update_all(handles);

% --------------------------------------------------------------------
%
% CALLBACK: startbutton_Callback
%
%   called when "Start" button is pressed during a script
%
function varargout = startbutton_Callback(h, eventdata, handles, varargin)

if handles.scripton
   return
end

% run the script, with the plotGUI fig as an argument
feval(handles.scripthandle, 'setup');

% set flag
handles.scripton = true;

% start the timer
start(handles.iti_timer);

% save changed handles
guidata(h, handles);

% --------------------------------------------------------------------
%
% CALLBACK: pausebutton_Callback
%
%   called when "Pause" button is pressed during a script
%
function varargout = pausebutton_Callback(h, eventdata, handles, varargin)

% make sure script is running
if ~handles.scripton
    return
end

if strcmp(get(handles.iti_timer, 'Running'), 'on')
    stop(handles.iti_timer);
    set(handles.pausebutton, 'String', 'Continue');
else
    start(handles.iti_timer);
    set(handles.pausebutton, 'String', 'Pause');
end

% --------------------------------------------------------------------
%
% CALLBACK: stopbutton_Callback
%
%   called when "Stop" button is pressed during a script
%
function varargout = stopbutton_Callback(h, eventdata, handles, varargin)

% make sure script is running
if ~handles.scripton
    return
end

% stop the timer
stop(handles.iti_timer);

% run the script, with the plotGUI fig as an argument
feval(handles.scripthandle, 'cleanup');

% set flag
handles.scripton = false;

% just in case we've stopped during pause
set(handles.pausebutton, 'String', 'Pause');

% save changed handles
guidata(h, handles);

% update the figs, just in case
update_all(handles);

% --------------------------------------------------------------------
%
% CALLBACK: itislider_Callback
%
%   called when the ITI slider is changed
%
function varargout = itislider_Callback(h, eventdata, handles, varargin)

period = round(get(h, 'Value')*1000)/1000;

set(handles.ititext, 'String', sprintf('ITI: %.2f sec', period));

if strcmp(get(handles.iti_timer, 'Running'), 'on')
    stop(handles.iti_timer);
    set(handles.iti_timer, 'Period', period);
    start(handles.iti_timer);
else
    set(handles.iti_timer, 'Period', period);
end

% --------------------------------------------------------------------
%
% CALLBACK: iti_timer_Callback
%
%   called each timer interval
%
function iti_timer_Callback(varargin)

global mainfig

% disp(round(mod(GetSecs, 50)*10)/10)
handles = guidata(mainfig);
feval(handles.scripthandle, 'trial', 1);

% update the figs, just in case
update_all(handles);

% --------------------------------------------------------------------
%
% CALLBACK: figure_destroy_Callback
%
%   Called when one of the figure children is destroyed
%
function figure_destroy_Callback(fig_type, h_to_destroy)

global mainfig

% get the handles
handles = guidata(mainfig);

% remove the figure from the appropriate list
ind = strmatch(fig_type, {handles.plots.name});
if isscalar(ind)
    handles.plots(ind).figs(handles.plots(ind).figs==h_to_destroy) = [];
end

% re-set the data
guidata(mainfig, handles);
