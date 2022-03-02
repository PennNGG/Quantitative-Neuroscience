function varargout = gsGUI_saveSettings(varargin)
%
% stores/loads the current state of the interface
% store info in a file called settings_<name>.mat, placed in 
%   FS_labMfilePath('FIRA', 'gui', 'figs')
%
% Assumptions:
%   parent function is called "getGUI_<name>" and
%       it has a function named "update_cb"
%   FS_* tools are in the path
%
% Usage for setup:
%  handles = gsGUI_saveSettings('setf', h, handles, name, ss)
%
% Usage for callback:
%   gsGUI_saveSettings('callback')

% INVOKE NAMED SUBFUNCTION OR CALLBACK

if nargin < 1
    return
end

try
    if (nargout)
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
        feval(varargin{:}); % FEVAL switchyard
    end
catch

    disp(lasterr);
end

% --------------------------------------------------------------------
%
% SUBROUTINE: setf
%
% function used to set up the settings menu
%
% Arguments:
%   h       ... handle of the parent fig
%   handles ... user data from the parent fig
%   name    ... base name of the parent
%   ss      ... cell array of {'type' 'name'} pairs
%
function handles = setf(h, handles, name, ss)

if nargin < 3
    return
end

% get the parent fig
h = handles.figure1;

% use FIRA.header.generator as a key for distinguising
%   different sets of settings
global FIRA

% look for the settings data, which tells us whether
% or not the menus have already been set up
if ~isfield(handles, 'settingStruct')
    
    % make the basic menu
    the_menu = uimenu(h, 'Label', 'Settings');
    uimenu(the_menu, 'Label', 'Save As...', 'Callback', ...
        ['gsGUI_saveSettings(''save_cb'', gcbo, guidata(gcbo))']);
    uimenu(the_menu, 'Label', 'Delete...',  'Callback', ...
        ['gsGUI_saveSettings(''delete_cb'', gcbo, guidata(gcbo))']);
    handles.settingStruct = struct( ...
        'calling_func', str2func(['plotGUI_' name]), ...
        'filename',     FS_labMfilePath('FIRA', 'gui', 'plotMenu', 'figs', ['settings_' name '.mat']), ...
        'ss',           {ss},             ...
        'menu',         the_menu,       ...
        'entries',      [],             ...
        'settings',     [],             ...
        'sname',        []);
else
    delete(handles.settingStruct.entries);
    handles.settingStruct.entries  = [];
    handles.settingStruct.settings = [];
end

% re-store handles as application data, in case
% we have to break early
guidata(h, handles);

% Load in the list of appropriate settings from the file
if isempty(FIRA)
    return
end

% look for the file
fid = fopen(handles.settingStruct.filename);
if fid == -1
    return
end
fclose(fid);

% look for the appropriate variable
if isa(FIRA.header.spmF, 'function_handle')
    handles.settingStruct.sname = ['settings_' func2str(FIRA.header.spmF)];
elseif ischar(FIRA.header.spmF)
    handles.settingStruct.sname = ['settings_' FIRA.header.spmF];
else
    handles.settingStruct.sname = 'settings_default';
end
if isempty(whos('-file', handles.settingStruct.filename, ...
        handles.settingStruct.sname))
    return
end

% read the data
s = load(handles.settingStruct.filename, handles.settingStruct.sname);
handles.settingStruct.settings = s.(handles.settingStruct.sname);

% cycle through the struct, setting up a menu entry
% for each saved setting
for i = 1:length(handles.settingStruct.settings)

    handles.settingStruct.entries(i) = uimenu(handles.settingStruct.menu, ...
        'Label',    handles.settingStruct.settings(i).name, ...
        'Callback', ['gsGUI_saveSettings(''activate_cb'', gcbo, guidata(gcbo))']);

    % separate from rest of menu
    if i == 1
        set(handles.settingStruct.entries(1), 'Separator', 'on');
    end
end

% re-store handles as application data
guidata(h, handles);

% --------------------------------------------------------------------
%
% CALLBACK: save_cb
%
% called when the "Save As..." entry is chosen
%   brings up a dialog with the list of entries ... chose
%   one and it's removed from the list
%
function save_cb(h, handles)

global FIRA

if isempty(FIRA)
    return
end

% get the name of the saved settings from a dialog
menu_name = inputdlg('Input set name');
if isempty(menu_name)
    return
end

% make the new settings struct
slist = struct( ...
    'type',  handles.settingStruct.ss(:,1), ...
    'name',  handles.settingStruct.ss(:,2), ...
    'value', []);

% fill it with the current values from the gui
for i = 1:length(slist)
    
    if strcmp(slist(i).type, 'rb') || strcmp(slist(i).type, 'menu') || ...
            strcmp(slist(i).type, 'slider') || strcmp(slist(i).type, 'check')
        slist(i).value = get(handles.(slist(i).name), 'Value');

    elseif strcmp(slist(i).type, 'edit')
        slist(i).value = get(handles.(slist(i).name), 'String');
    
    elseif strcmp(slist(i).type, 'cell')
        slist(i).value = {handles.(slist(i).name)};
    
    else % 'value'
        slist(i).value = handles.(slist(i).name);
    end
end

% save it in the settings list
num_entries = length(handles.settingStruct.settings) + 1;
if num_entries == 1
    handles.settingStruct.settings = struct( ...
        'name',  menu_name{:}, ...
        'slist', slist);
    handles.settingStruct.entries  = uimenu(handles.settingStruct.menu, ...
        'Label',     menu_name{:}, ...
        'Callback',  ['gsGUI_saveSettings(''activate_cb'', gcbo, guidata(gcbo))'], ...
        'Separator', 'on');
else
    handles.settingStruct.settings(num_entries) = struct( ...
        'name',  menu_name{:}, ...
        'slist', slist);
    handles.settingStruct.entries(num_entries)  = uimenu(handles.settingStruct.menu, ...
        'Label',     menu_name{:}, ...
        'Callback',  ['gsGUI_saveSettings(''activate_cb'', gcbo, guidata(gcbo))']);
end

% save the settings array to the file
if ~isempty(handles.settingStruct.filename)

    if isempty(handles.settingStruct.sname)
        if isa(FIRA.header.spmF, 'function_handle')
            handles.settingStruct.sname = ['settings_' func2str(FIRA.header.spmF)];
        elseif ischar(FIRA.header.spmF)
            handles.settingStruct.sname = ['settings_' FIRA.header.spmF];
        else
            handles.settingStruct.sname = 'settings_default';
        end
    end

    eval([handles.settingStruct.sname '= handles.settingStruct.settings;']);
    save(handles.settingStruct.filename, handles.settingStruct.sname);
end
    
% re-store handles as application data
guidata(h, handles);

% --------------------------------------------------------------------
%
% CALLBACK: delete_cb
%
% called when the "Delete..." entry is chosen
%   brings up a dialog with the list of entries ... chose
%   one and it's removed from the list
%
function delete_cb(h, handles)

global FIRA
if isempty(FIRA)
    return
end

% bring up a list dialog to get the list of entries to remove
[sel, ok] = listdlg('ListString', {handles.settingStruct.settings.name});
if ~ok
    return
end

% remove them from the gui
delete(handles.settingStruct.entries(sel));

% remove it from the settings
handles.settingStruct.entries(sel)  = [];
handles.settingStruct.settings(sel) = [];

% just to be nice
if ~isempty(handles.settingStruct.entries)
    set(handles.settingStruct.entries(1), 'Separator', 'on');
end

% save to file
if ~isempty(handles.settingStruct.filename)
    eval([handles.settingStruct.sname '= handles.settingStruct.settings;']);
    save(handles.settingStruct.filename, handles.settingStruct.sname);
end

% re-store handles as application data
guidata(h, handles);

% --------------------------------------------------------------------
%
% CALLBACK: activate_cb
%
% called when one of the settings entries is chosen
%
function activate_cb(h, handles)

% get the appropriate settings
slist = handles.settingStruct.settings(find(...
    handles.settingStruct.entries == h)).slist;

% loop through the saved settings
for i = 1:length(slist)
    if strcmp(slist(i).type, 'rb') || strcmp(slist(i).type, 'check')
        set(handles.(slist(i).name), 'Value', slist(i).value);
    elseif strcmp(slist(i).type, 'menu')
        if slist(i).value <= length(get(handles.(slist(i).name), 'String'))
            set(handles.(slist(i).name), 'Value', slist(i).value);
        end
    elseif strcmp(slist(i).type, 'edit')
        set(handles.(slist(i).name), 'String', slist(i).value);
    elseif strcmp(slist(i).type, 'slider')
        if (slist(i).value >= get(handles.(slist(i).name), 'Min') & ...
                (slist(i).value <= get(handles.(slist(i).name), 'Max')))
            set(handles.(slist(i).name), 'Value', slist(i).value);
        end
    elseif strcmp(slist(i).type, 'cell')
        handles.(slist(i).name) = {slist(i).value};
    else % 'value'
        handles.(slist(i).name) = slist(i).value;
    end
end

% re-store handles as application data
guidata(h, handles);

% call the update routine
feval(handles.settingStruct.calling_func, 'update_cb', handles);