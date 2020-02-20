function varargout = gsGUI_selectTrials(varargin)
% function varargout = gsGUI_selectTrials(varargin)
%
% Sets up a modal dialog that is used to
% make an "Larray" from FIRA data. Typically is
% given the list of "id" column names from
% FIRA.ecodes and sets up a series of rows 
% of radiobuttons, each row corresponding to 
% all possible values of the given id.
%
% WARNING
% -------
% BE SURE TO SET THE OUTPUT OF INITF TO HANDLES.SELECT
%
% Usage:
%
% sel_ = gsGUI_selectTrials('initf', select_button_h, creator)
%        ... initializes the sel_ struct and sets up the
%               appropriate callbacks
%
% gsGUI_selectTrials('setf', plot_h, handles)
%        ... invokes the GUI to make the cell array of new values
%               (array for each id) used to generate the Larray
%               this is set up automatically by initf
%
% trials = gsGUI_selectTrials('getf', newS, curslider_handle, histslider_handle)
%        ... generates the list of selected trials from FIRA based on the
%               gui
%
% Callbacks:
%  gsGUI_Larray('rb_cb',     h, ind, hdata)
%  gsGUI_Larray('ok_cb',     hdata)
%  gsGUI_Larray('cancel_cb', hdata)

if nargin == 0 | ~ischar(varargin{1})
    return
end

% using MATLAB's little trick to be able to call
% imbedded functions.. these are the callback routines
try
    if (nargout)
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
        feval(varargin{:}); % FEVAL switchyard
    end
catch
    disp(lasterr);
end

%--------------------------------------------------------------------
%
% SUBROUTINE: initf
%
% initialization
%
function sel_ = initf(select_button_h, creator)

% set the callback
set(select_button_h, 'Callback', ...
    ['gsGUI_selectTrials(''setf'', gcbo, guidata(gcbo))']);

% make the sel_ struct
sel_ = struct( ...
    'creator',    creator, ...
    'ids',        [], ...
    'ranges',     [], ...
    'values',     []);

sel_.ids    = getFIRA_ecodeNames('id');
sel_.ranges = getFIRA_uniqueEcodeValues(sel_.ids);

% added by jig 8/5/05
for ii = 1:size(sel_.ids, 2)
    if size(sel_.ranges{ii}, 1) > 13
        sel_.ranges{ii} = sel_.ranges{ii}(1:10);
    end
end

sel_.values = nancells(1, length(sel_.ids));

%--------------------------------------------------------------------
%
% SUBROUTINE: setf
%
% creates the dialog to generate the "values_" list
% WARNING -- this assumes that the sel_ struct created
%  in initf, above, was saved as "handles.select"
%
function setf(plot_h, handles)

if ~isfield(handles, 'select')
    error('gsGUI_selectTrials: must store sel_ as handles.select')
end

not_done = 1;

while not_done

    % make the dialog
    dlg = make_dialog(plot_h, handles.select);

    % make modal
    uiwait(dlg);

    % get the data
    hdata = guidata(dlg);
    
    % check for reset flag
    if ~iscell(hdata.settings) & hdata.settings == -1
        close(dlg);
        handles.select.ids    = getFIRA_ecodeNames('id');
        handles.select.ranges = getFIRA_uniqueEcodeValues(handles.select.ids);
        handles.select.values = nancells(1, length(handles.select.ids));
    else
        not_done = 0;
    end
end

% ok selected
handles.select.values = hdata.settings;
close(dlg);
guidata(plot_h, handles);

feval(handles.select.creator, 'update_cb', handles);


%--------------------------------------------------------------------
%
% SUBROUTINE: make_dialog
%
% creates the dialog to generate the "values_" list
function dlg_ = make_dialog(plot_h, selS)

dlg_ = [];

global FIRA
if isempty(FIRA)
    return
end

% parse the args
num_rows = length(selS.ids);

% set up user data ... store a cell array for each row (type), 
% plus store the current settings
hdata.plot_h = plot_h;
hdata.rows   = cell(num_rows, 1);
if ~isempty(selS.values)
    hdata.settings = selS.values;
else
    hdata.settings = selS.ranges;
end

% num cols is the largest array in possible values
% plus "ignore", "none" and "all" buttons
num_cols = 0;
for i = 1:length(selS.ranges)
    if length(selS.ranges{i}) > num_cols
        num_cols = length(selS.ranges{i});
    end
end
num_cols = num_cols + 3;

% define geometry
text_ht  = 0.55;
tb_ht    = 0.55;
sep_ht1  = 0.01;
sep_ht2  = 0.1;
tb_wd    = 1.85;
sep_wd   = 0.1;
pb_ht    = 0.5;
lmargin  = 0.4;
tmargin  = 0.25;
jump_ht  = text_ht + tb_ht + sep_ht1 + sep_ht2;
jump_wd  = tb_wd + sep_wd;
wd       = jump_wd * num_cols + 2*lmargin;
ht       = jump_ht * num_rows + pb_ht + sep_ht2 + 2*tmargin;
pb_wd    = min(0.333*wd, 2);

% open the dialog
dlg_ = dialog('Units', 'centimeters', ...
    'Position', [2 2 wd ht]); 

% Use system color scheme for figure:
set(dlg_,'Color',get(0,'defaultUicontrolBackgroundColor'));
  
% add "OK" , "Reset", and "Cancel" buttons on the bottom
uicontrol(dlg_, ...
    'Style', 'pushbutton', ...
    'Callback', ['gsGUI_selectTrials(''cancel_cb'', guidata(gcbo))'], ...
    'Units', 'centimeters', ...
    'Position', [wd*.25-pb_wd*0.5 tmargin pb_wd pb_ht], ...
    'String', 'Cancel');
uicontrol(dlg_, ...
    'Style', 'pushbutton', ...
    'Callback', ['gsGUI_selectTrials(''reset_cb'', guidata(gcbo))'], ...
    'Units', 'centimeters', ...
    'Position', [wd*.5-pb_wd*0.5 tmargin pb_wd pb_ht], ...
    'String', 'Reset');
uicontrol(dlg_, ...
    'Style', 'pushbutton', ...
    'Callback', ['gsGUI_selectTrials(''ok_cb'', guidata(gcbo))'], ...
    'Units', 'centimeters', ...
    'Position', [wd*.75-pb_wd*0.5 tmargin pb_wd pb_ht], ...
    'String', 'OK');

for i = 1:num_rows
    
    hans = zeros(2+length(selS.ranges{i}),1);
    
    % useful offsets for position data
    txt_base = ht - tmargin - (i-1)*jump_ht - text_ht;
    ht_base  = txt_base - sep_ht1 - tb_ht;
        
    % add a label, set of controls
    uicontrol(dlg_, ...
        'Style',    'text', ...
        'String',   selS.ids{i}, ...
        'HorizontalAlignment', 'left', ...
        'Units',    'centimeters', ...
        'Position', [lmargin txt_base 3 text_ht]);
    
    % 'ignore' button
    hans(1) = uicontrol(dlg_, ...
        'Style',    'radiobutton', ...
        'Value',    sum(find(isnan(hdata.settings{i})))>0, ...
        'String',   'Ignore', ...
        'HorizontalAlignment', 'left', ...
        'Units',    'centimeters', ...
        'Position', [lmargin ht_base tb_wd tb_ht]);
    
    % 'none' button
    hans(2) = uicontrol(dlg_, ...
        'Style',    'radiobutton', ...
        'Callback', ['gsGUI_selectTrials(''rb_cb'', gcbo, ' sprintf('%d',i) ', guidata(gcbo))'], ...
        'Value',    0, ...
        'String',   'None', ...
        'HorizontalAlignment', 'left', ...
        'Units',    'centimeters', ...
        'Position', [lmargin+jump_wd ht_base tb_wd tb_ht]);
    
    % 'all' button
    hans(3) = uicontrol(dlg_, ...
        'Style',    'radiobutton', ...
        'Callback', ['gsGUI_selectTrials(''rb_cb'', gcbo, ' sprintf('%d',i) ', guidata(gcbo))'], ...
        'Value',    0, ...
        'String',   'All', ...
        'HorizontalAlignment', 'left', ...
        'Units',    'centimeters', ...
        'Position', [lmargin+2*jump_wd ht_base tb_wd tb_ht]);

    % following is series of buttons, this is the horizontal start point
    wd_base = lmargin + 3*jump_wd;

    % loop through each value
    for j = 1:length(selS.ranges{i})
        
        % check if button is set
        setv = ismember(selS.ranges{i}(j), hdata.settings{i});

        % make the radiobutton
        hans(3+j) = uicontrol(dlg_, ...
            'Style',    'radiobutton', ...
            'Callback', ['gsGUI_selectTrials(''rb_cb'', gcbo, ' sprintf('%d',i) ', guidata(gcbo))'], ...
            'Value',    setv, ...
            'String',   num2str(selS.ranges{i}(j)), ...
            'HorizontalAlignment', 'left', ...
            'Units',    'centimeters', ...
            'Position', [wd_base+(j-1)*jump_wd ht_base tb_wd tb_ht]);
    end
    
    % set the data
    hdata.rows{i} = hans;

    % call the radiobutton callback to set "all" and "none"
    rb_cb(0, i, hdata);
end

% link the data to the figure
guidata(dlg_, hdata);

%--------------------------------------------------------------------
%
% SUBROUTINE: getf
% 
% find the list of selected trials using the "select..."
% button and "current trial" and "show_previous" sliders
% 
% Arguments:
%   sel    ... the struct returned by setf (above)
%   cur_h  ... handle of the "current trial" slider
%   prev_h ... handle of the "show previous" slider
function trials_ = getf(sel, cur_h, prev_h)

global FIRA

if isempty(FIRA) | isempty(FIRA.ecodes.data)
    trials_ = [];
    return
end

% default: select all
Larray = ~isnan(FIRA.ecodes.data(:,1));

% check only if we got something
if nargin >= 1 & ~isempty(sel) & length(sel.ids) == length(sel.values)

    % loop through each id, updating the selection
    % array based on membership in the given "values" vector
    for i = 1:length(sel.ids)
        if ~any(isnan(sel.values{i}))   % nan means to ignore
            col = getFIRA_ecodeColumnByName(sel.ids{i}, 'id');
            if ~isempty(col)
                Larray = Larray & ismember(FIRA.ecodes.data(:, col), sel.values{i});
            end
        end
    end
end

% get the indices
trials_ = find(Larray);

% now check the sliders
if nargin >= 3 & ~isempty(trials_)
    
    % cur trial determines the last trial in the list
    cur_trial = get(cur_h, 'Value');
    if cur_trial
        trial_end = ceil(length(trials_) * cur_trial);
    else
        trial_end = 1;
    end
    
    % trial history determines the number of trials in the list
    trial_hist = get(prev_h, 'Value');
    if trial_hist
        trial_begin = trial_end - floor(trial_end * trial_hist);
        if trial_begin < 1
            trial_begin = 1;
        end
    else
        trial_begin = trial_end;
    end
    
    trials_ = trials_(trial_begin:trial_end);
end

%--------------------------------------------------------------------
%
% radiobutton callback
function rb_cb(h, ind, hdata)

% get this row's array of handles
arr = hdata.rows{ind};

% if 'none' was set, unset the rest
if h ~= 0 && strcmp(get(h, 'String'), 'None') && ...
        get(h, 'Value') == 1
    for i = 3:length(arr)
        set(arr(i), 'Value', 0);
    end
    
    % if 'all' was set, set the rest
elseif h ~= 0 && strcmp(get(h, 'String'), 'All') && ...
        get(h, 'Value') == 1
    set(arr(2), 'Value', 0);
    for i = 4:length(arr)
        set(arr(i), 'Value', 1);
    end
    
    % check to set all, none
else
    vs = zeros(length(arr)-3, 1);
    for i = 4:length(arr)
        vs(i-3) = get(arr(i), 'Value');
    end
    if prod(vs) == 1 % set "All"
        set(arr(2), 'Value', 0);
        set(arr(3), 'Value', 1);
    elseif sum(vs) == 0 % set "None"
        set(arr(2), 'Value', 1);
        set(arr(3), 'Value', 0);
    else
        set(arr(2), 'Value', 0);
        set(arr(3), 'Value', 0);
    end
end

%--------------------------------------------------------------------
%
% cancel pushbutton callback
%
% all we care about is getting out of modal-mode
function cancel_cb(hdata)
uiresume(gcf);

%--------------------------------------------------------------------
%
% Reset pushbutton callback
%
function reset_cb(hdata)

% send flag to setf
hdata.settings = -1;
guidata(gcf, hdata);

% make unmodal
uiresume(gcf);

%--------------------------------------------------------------------
%
% OK pushbutton callback
%
% When OK is chosen, read the radio buttons and generate a cell array
% of selected values, which we return in hdata.
%
function ok_cb(hdata)

% read the buttons
values_ = cell(size(hdata.settings));
for i = 1:length(values_);
    % if 'ignore' was set, add a 'nan' as a placehold_seler (see getFIRA_LarrayFromList)
    if get(hdata.rows{i}(1), 'Value') == 1
        values_{i} = nan;
    else
        values_{i} = [];
    end
    for j = 4:length(hdata.rows{i})
        if get(hdata.rows{i}(j), 'Value') == 1
            values_{i} = [values_{i} sscanf(get(hdata.rows{i}(j), 'String'), '%f')];
        end
    end
end

% put it in the data
hdata.settings = values_;
guidata(gcf, hdata);

% we're outta, so un-modalize
uiresume(gcf);
