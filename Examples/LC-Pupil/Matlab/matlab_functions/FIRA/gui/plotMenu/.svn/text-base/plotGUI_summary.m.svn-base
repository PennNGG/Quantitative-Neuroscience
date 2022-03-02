function varargout = plotGUI_summary(varargin)
% plotGUI_summary Application M-file for plotGUI_summary.fig
%
% Usage:
%    FIG = plotGUI_summary({<deleteFcn>})
%       launch plotGUI_summary GUI.
%
%    plotGUI_summary('callback_name', ...) invoke the named callback.
%
% wrapper GUI for plotGUI_summary

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

% set the menus
gsGUI_ecodeIDsByName(   'setf', handles.idsmenu);
gsGUI_ecodeTimesByName( 'setf', handles.timesmenu);
gsGUI_ecodeValuesByName('setf', handles.valuesmenu);
gsGUI_spikeByID(        'setf', handles.spikemenu);
gsGUI_analogByName(     'setf', handles.analogmenu);

% call update_cb to fill in the text strings
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
% called when menus are selected
function update_cb(handles)

global FIRA

% set the strings
if isempty(FIRA)

    set(handles.filenametext,   'String', 'n/a');
    set(handles.filetypetext,   'String', 'n/a');
    set(handles.paradigmtext,   'String', 'n/a');
    set(handles.generatortext,  'String', 'n/a');
    set(handles.datetext,       'String', 'n/a');
    set(handles.flagstext,      'String', 'n/a');
    set(handles.totaltext,      'String', 'n/a');
    set(handles.goodtext,       'String', 'n/a');

    set(handles.idvaluestext,   'String', 'n/a');

    set(handles.tmintext,       'String', 'n/a');
    set(handles.tmaxtext,       'String', 'n/a');
    set(handles.tmeantext,      'String', 'n/a');

    set(handles.vmintext,       'String', 'n/a');
    set(handles.vmaxtext,       'String', 'n/a');
    set(handles.vmeantext,      'String', 'n/a');

    set(handles.spmintext,      'String', 'n/a');
    set(handles.spmaxtext,      'String', 'n/a');
    set(handles.spmeantext,     'String', 'n/a');

    set(handles.asrtext,        'String', 'n/a');
    set(handles.amintext,       'String', 'n/a');
    set(handles.amaxtext,       'String', 'n/a');
    set(handles.ameantext,      'String', 'n/a');

else

    % get trials
    if ~isempty(FIRA.ecodes.data)
        tr  = find(~isnan(FIRA.ecodes.data(:,1)))';
        num = length(tr);
    else
        tr  = [];
        num = 0;
    end
    
    set(handles.filenametext, 'String', FIRA.header.filename{1});
    set(handles.filetypetext, 'String', FIRA.header.filetype);
    set(handles.paradigmtext, 'String', num2str(FIRA.header.paradigm));
    if isempty(FIRA.header.spmF)
        set(handles.generatortext, 'String', 'none');
    else
        set(handles.generatortext, 'String', func2str(FIRA.header.spmF));
    end        
    set(handles.datetext,       'String', FIRA.header.date);
    set(handles.flagstext,      'String', num2str(FIRA.header.flags));
    if ~isempty(FIRA.ecodes.data)
        set(handles.totaltext,  'String', num2str(max(FIRA.ecodes.data(:,1))));
    else
        set(handles.totaltext,  'String', 0);
    end
    set(handles.goodtext,       'String', num2str(num));

    ids = gsGUI_ecodeIDsByName('getf', handles.idsmenu);
    uniques = nonanunique(ids);
    if length(uniques) == 1
        set(handles.idvaluestext, 'String', num2str(uniques));
    elseif length(uniques) > 1
        set(handles.idvaluestext, 'String', ...
            num2str([uniques hist(ids, uniques)']'));
    else
        set(handles.idvaluestext, 'String', 'n/a');
    end
    
    times = gsGUI_ecodeTimesByName( 'getf', handles.timesmenu);
    set(handles.tmintext,  'String', num2str(nanmin(times)));
    set(handles.tmaxtext,  'String', num2str(nanmax(times)));
    set(handles.tmeantext, 'String', num2str(nanmean(times)));

    values = gsGUI_ecodeValuesByName('getf', handles.valuesmenu);
    set(handles.vmintext,  'String', num2str(nanmin(values)));
    set(handles.vmaxtext,  'String', num2str(nanmax(values)));
    set(handles.vmeantext, 'String', num2str(nanmean(values)));
    
    if isfield(FIRA, 'spikes') && ~isempty(FIRA.ecodes.data) && ...
            ~isempty(FIRA.spikes.data)
        sp = gsGUI_spikeByID('getf', handles.spikemenu);
        sp_rates = zeros(num, 1);
        for i = 1:num
            if ~isnan(FIRA.ecodes.data(tr(i), 2)) & ~isnan(FIRA.ecodes.data(tr(i), 3))
                sp_rates(i) = 1000*length(FIRA.spikes.data{tr(i), sp})/...
                    diff(FIRA.ecodes.data(tr(i), 2:3));
            else
                sp_rates(i) = length(FIRA.spikes.data{tr(i), sp});
            end
        end

        set(handles.spmintext,  'String', min(sp_rates));
        set(handles.spmaxtext,  'String', max(sp_rates));
        set(handles.spmeantext, 'String', mean(sp_rates));
    else
        set(handles.spmintext,  'String', 0);
        set(handles.spmaxtext,  'String', 0);
        set(handles.spmeantext, 'String', 0);
    end

    if ~isempty(FIRA.ecodes.data) && isfield(FIRA, 'analog') && ~isempty(FIRA.analog.data)
        ach = gsGUI_analogByName('getf', handles.analogmenu);
        a_lengths = zeros(num, 1);
        for i = 1:num
            a_lengths(i) = FIRA.analog.data(tr(i), ach).length;
        end
        set(handles.asrtext,   'String', num2str(FIRA.analog.store_rate(ach)));
        set(handles.amintext,  'String', min(a_lengths));
        set(handles.amaxtext,  'String', max(a_lengths));
        set(handles.ameantext, 'String', mean(a_lengths));
    else
        set(handles.asrtext,   'String', 0);
        set(handles.amintext,  'String', 0);
        set(handles.amaxtext,  'String', 0);
        set(handles.ameantext, 'String', 0);
    end
end

% store data in the figure's application data
guidata(handles.figure1, handles);

