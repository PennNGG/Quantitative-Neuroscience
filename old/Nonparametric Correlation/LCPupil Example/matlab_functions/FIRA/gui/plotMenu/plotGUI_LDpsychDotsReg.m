function varargout = plotGUI_LDpsychDotsReg(varargin)
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

% update it, which includes setting up the axes
update_cb;

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
function update_cb()

global FIRA
% data = handles.data;
data = FIRA;

flagOffline = 1;
if flagOffline==1
% use offline results
conditions_list = {'trialid', 't1_angle', 'dot_coh', 'dot_dir', 'choice', 'correct', 'reward', 'taskid', 'rewcont'};
align_list = {'tgt_on', 'dot_on', 'fp_off', 'sac_on_offline','rew_on', 'fdbkon', 'targoff'};
else
% use online ecodes
conditions_list = {'trialid', 't1_angle', 'dot_coh', 'dot_dir', 'choice', 'OLscore', 'reward', 'taskid', 'rewcont'};
align_list = {'tgt_on', 'dot_on', 'fp_off', 'sac_on','rew_on', 'fdbkon', 'targoff'};% use REX results
end
% get condition ecodes
nConditions = length(conditions_list);
conditions = [];
for i = 1:nConditions
    col = find(strcmp(conditions_list{i}, data.ecodes.name),1);
    conditions = [conditions; data.ecodes.data(:,col)'];
end

trials = find(conditions(8,:) == 4);
if isempty(trials)
    disp('no data from dotsReg task');
    return;
end

% IDENTIFY COHERENCES USED, EXCLUDE NaN
i_exclude = logical(isnan(conditions(3,:)));
conditions1 = conditions(:,~i_exclude)';
dot_coh_unique = sort(unique(conditions1(:,3)));
dot_coh_unique = dot_coh_unique(dot_coh_unique>0);
if isempty(dot_coh_unique)
    disp ('no matching reward contingency ');
    return
end

conditions = conditions';
n_dotcoh = length(dot_coh_unique);
colorset = [0 0 0; 0 0 1; 1 0 1; 0 1 0; 1 0 0];
for i=1:n_dotcoh
    txtlegend{i} = num2str(dot_coh_unique(i));
end

% IDENTIFY DIRECTIONS USED AND MATCH TO CHOICES
ind_correct = logical(conditions(:,6) == 1);
ind_good = logical(conditions(:,6)>=0);
ind_ch1 = logical(conditions(:,5) == 1);
ch1dir = unique(conditions(ind_ch1 & ind_correct, 4));
if length(ch1dir)>1
    disp('more than one directions for choice 1');
    return;
end
dot_dir_unique = [ch1dir mod(ch1dir+180,360)];
ind_dir1 = logical(conditions(:,4) == dot_dir_unique(1));
ind_dir2 = logical(conditions(:,4) == dot_dir_unique(2));

% GET ALIGNMENT TIMES
nAlign = length(align_list);
alignTimes = [];
for i = 1:nAlign
    col = find(strcmp(align_list{i}, data.ecodes.name),1);
    alignTimes = [alignTimes; data.ecodes.data(:,col)'];
end
alignTimes = alignTimes';
viewtime = alignTimes(:,3) - alignTimes(:,2);

viewtimebins = [200:200:1600];
n_timebin = size(viewtimebins,2);
ind_time = zeros(size(conditions,1), n_timebin);
for j=1:n_timebin
    ind_time(:,j) = logical( viewtime>= viewtimebins(j) & viewtime<=viewtimebins(j)+400);
end
percent_correct = NaN(n_dotcoh, n_timebin, 3); 
titletxt = {'overall','dir1', 'dir2'};
% figure; hold on;
subplot(1,3,1);
for i=1:n_dotcoh
    ind_coh = logical(conditions(:,3)==dot_coh_unique(i));
    for j=1:n_timebin
%         ind_time = logical( viewtime>= viewtimebins(j) & viewtime<=viewtimebins(j)+400);
        ind = ind_time(:,j) & ind_coh & ind_good;
        if sum(ind)>0
            percent_correct(i,j,1) = sum(ind_correct & ind)/sum(ind);
            percent_correct(i,j,2) = sum(ind_correct & ind & ind_dir1)/sum(ind & ind_dir1);
            percent_correct(i,j,3) = sum(ind_correct & ind & ind_dir2)/sum(ind & ind_dir2);
        else
            disp([num2str(n_dotcoh) '    ' num2str(viewtimebins(j))]);
        end
    end
    for k=1:3
        subplot(1,3,k); hold on;
        plot(viewtimebins, percent_correct(i,:, k), '.', 'markersize', 15, 'color', colorset(i,:));
    end
end
for k=1:3
    subplot(1,3,k);
    title(titletxt{k});
    ylim([0 1.05]);
end
legend(txtlegend);

%% fit with quickTs.m
data2fit = [conditions(ind_good, 3)/100.0 viewtime(ind_good) conditions(ind_good, 6)];
th_args = [];
citype = [];
[fits, fitsd] = ctPsych_fit(@quickTs, data2fit(:,1:2), data2fit(:,3), th_args, citype, [], [1,0,0,0]);
fits
% PLOT FITTED CURVES
t = [min(viewtime):1:max(viewtime)]';
c = ones(size(t))*0.01;
% val = quickTs(fits, data2fit(:,1:2));
subplot(1,3,1);
for i=1:n_dotcoh
    val = quickTs(fits, [c*dot_coh_unique(i) t], [0 0 1 0]);
    plot(t, val, '-', 'color', colorset(i,:));
end
% suptitle(fname);

