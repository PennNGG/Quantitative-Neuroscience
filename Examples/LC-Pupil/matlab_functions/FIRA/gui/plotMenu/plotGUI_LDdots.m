function varargout = plotGUI_LDdots(varargin)
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

dlg_title = 'SDF-dotsRT Settings';
prompt = {  'UnitID', ...
            'Trials to include (Error -1, All 0, Correct 1)', ...
            'Gaussian kernel sigma', ...
            'trials to exclude by #', ...
            'time range tgton', ...
            'time range dots on', ...
            'time range sac on', ...
            'time range rew on', ...
            'timebin for predictive index', ...
            'slidestep for predictive index', ...
            'rt percentile to include', ...
            'reward contingency'};
def = {'2001','1', '20', '', '-500:1000', '-500:1000', '-500:1000','-500:1000', '200', '20', '50', '2'};
a = inputdlg(prompt, dlg_title, 1, def);
if isempty(a)
    disp('settings: wrong inputs');
    return
end
if findstr(a{1},'all')
    allunits = 1;
else
    allunits = 0;
    unitID = str2num(a{1});
end

flag = str2num(a{2});
sigma = str2num(a{3});
if isempty(a{4})
    trialBounds = [];
else
    trialBounds = parseSymbol(a{4},'-');
end
flagtxt = {'Error', 'All', 'Correct'};

% flag = 0;       % 0: all trials, 1: correct only, -1: error only
% sigma = 20;     % sigma for SDF gaussian kernel

% parse time ranges
timerange = [];
for i=5:8
    timerange = [timerange; parseSymbol(a{i},':')];
end

timebin = str2num(a{9});
slidestep = str2num(a{10});
rt_percentile = str2num(a{11});

% filename = data.header.filename{1};
% k = findstr('\', filename);
% if ~isempty(k)
%     k = k(end);
% else
%     k=0;
% end
% 
% filename = filename(k+1:end);

colTaskID = find(strcmp('taskid', data.ecodes.name),1);
taskid = data.ecodes.data(:, colTaskID);
trials = find(taskid == 3);
if isempty(trials)
    disp('no data from dotsRT task');
    return;
end

  
    
% get condition ecodes
% use offline results
conditions_list = {'trialid', 't1_angle', 'dot_coh', 'dot_dir', 'choice', 'correct', 'reward', 'taskid', 'rewcont'};
% use REX results
conditions_list = {'trialid', 't1_angle', 'dot_coh', 'dot_dir', 'choice', 'OLscore', 'reward', 'taskid', 'rewcont'};

nConditions = length(conditions_list);
conditions = [];
for i = 1:nConditions
    col = find(strcmp(conditions_list{i}, data.ecodes.name),1);
    conditions = [conditions; data.ecodes.data(:,col)'];
end

% remove trials with reward contingencies not specified in menu
i_exclude = logical(conditions(9,:) ~= str2num(a{12}));
conditions(3, i_exclude) = NaN;
conditions(8, i_exclude) = NaN; 
% remove trials with nan as dots coherence
i_exclude = logical(isnan(conditions(3,:)));

% non_nanItems = find(~isnan(conditions(3,:)));

conditions1 = conditions(:,~i_exclude)';
conditions = conditions';
dot_coh_unique = sort(unique(conditions1(:,3)));
if isempty(dot_coh_unique)
    disp ('no matching reward contingency ');
    return
end

% %%%%%%  making figures for only a subset of coherence 
% figureflag = 1;
% dot_coh_unique = [32 128 512]/10;
% %%%%%%

n_dotcoh = length(dot_coh_unique);
dot_dir_unique = sort(unique(conditions1(:,4)));
n_dotdir = length(dot_dir_unique);
if n_dotdir>2
    dlg_title = '!!! more than 2 dot directions';
    dotdir_txt = '';
    for i=1:n_dotdir
        dotdir_txt = [dotdir_txt ' ' num2str(dot_dir_unique(i))];
    end
    prompt = {['angle1 to use ' dotdir_txt],['angle2 to use ' dotdir_txt]};
    temp = inputdlg(prompt, dlg_title, 1, {'0', '180'});
    if ~isempty(temp)
        dot_dir_unique = [str2num(temp{1}), str2num(temp{2})];
        n_dotdir = 2;
    else
        disp('no angle selected');
        return;
    end
end
temp = min(dot_dir_unique);
if temp<=90
    t_rightup = temp;
    t_leftdown = mod(temp+180, 360);
else
    t_rightup = mod(temp+180, 360);
    t_leftdown = temp;
end
t1_angles = unique(conditions1(:,2));
dot_dir_unique = [t_rightup t_leftdown]
sacdir = -ones(size(conditions(:,5)));
temp = find(conditions(:,5)==1);
sacdir(temp) = t_rightup;
temp = find(conditions(:,5)==2);
sacdir(temp) = t_leftdown;
sacdir_unique = [t_rightup t_leftdown];
n_sacdir = 2;
plotrows = n_dotcoh*n_dotdir;
plotcols = 5;

% get alignment times
% use offline behavioral measures
align_list = {'tgt_on', 'dot_on', 'sac_on_offline','rew_on', 'fdbkon', 'targoff', 'omitrew'};
% use online ecodes
align_list = {'tgt_on', 'dot_on', 'sac_on','rew_on', 'fdbkon', 'targoff', 'omitrew'};

nAlign = length(align_list);
alignTimes = [];
for i = 1:nAlign
    col = find(strcmp(align_list{i}, data.ecodes.name),1);
    alignTimes = [alignTimes; data.ecodes.data(:,col)'];
end
% alignTimes = alignTimes(:,non_nanItems)';
alignTimes = alignTimes';

% trials = find(taskid == 3 & ~isnan(alignTimes(:,2)));
% nTrials = length(trials);


nUnits = length(data.spikes.id);
for iUnit = 1:nUnits
    if allunits==1 || data.spikes.id(iUnit) == unitID
        figUnit(iUnit).raster = figure;

        %   panel 1     align data on targets onset, no need to separate trials, marker
        %               shows dots onset, sdf only for the shortest foreperiod,
        %               sorted by dots onset
        panel_tgton = subplot(plotrows,plotcols,[1:plotcols:plotrows*plotcols]);
        raster_tgt = []; marker = [];
        trials_included = find(conditions(:,6)>-2 & conditions(:,8)==3);
        if ~isempty(trialBounds)
            trials_included = trials_included(trials_included<trialBounds(1)|trials_included>trialBounds(2));
%             trials_excluded = trials_included(trials_included>=trialBounds(1) & trials_included <= trialBounds(2));
%             conditions(trials_excluded, 3) = -1000;
        end
        dotson = alignTimes(trials_included,2) - alignTimes(trials_included,1);
        raster_tgt = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,1), dotson, 0, timerange(1,1), timerange(1,2), panel_tgton, 'Target on', 0);
%         raster_tgt = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,1), dotson, 1, timerange(1,1), timerange(1,2), '', 'Target on', 0);

        %   panel 2     align data on dots on, separate by dots coherence and direction, markers show sac onset
        %               sorted by sac onset
        rasteraxis = [];
        for i_coh = 1:n_dotcoh
            for i_dir = 1:n_dotdir
                i_temp = i_coh+(i_dir-1)*n_dotcoh;
                if dot_coh_unique(i_coh) == 0   % collaspe all coh =0 trials
                    trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & conditions(:,8)==3);
                else
                    switch flag
                        case 0     %             include all finished trials
                            trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & conditions(:,4)==dot_dir_unique(i_dir) & conditions(:,8)==3);
                        case 1     %             include only correct trials
                            trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & conditions(:,4)==dot_dir_unique(i_dir) & conditions(:,6)==1 & conditions(:,8)==3);
                        case -1    %             include only wrong choice trials
                            trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & conditions(:,4)==dot_dir_unique(i_dir) & conditions(:,6)==0 & conditions(:,8)==3);
                    end
                end
                if ~isempty(trialBounds)
                    trials_included = trials_included(trials_included<trialBounds(1)|trials_included>trialBounds(2));
                end
                sacon_dot{i_coh, i_dir} = alignTimes(trials_included, 3) - alignTimes(trials_included, 2);
                rewon_dot{i_coh, i_dir} = alignTimes(trials_included, 4) - alignTimes(trials_included, 2);
                panel_dotson(i_temp) = subplot(plotrows,plotcols,2+(i_temp-1)*plotcols);
                raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,2), ...
                    [sacon_dot{i_coh, i_dir} rewon_dot{i_coh, i_dir}], 0, timerange(2,1), timerange(2,2), panel_dotson(i_temp), ...
                    ['DOTS ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(dot_dir_unique(i_dir))], 0 );
%                 raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,2), ...
%                     [sacon_dot{i_coh, i_dir} rewon_dot{i_coh, i_dir}], 1, timerange(2,1), timerange(2,2), '', ...
%                     ['DOTS ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(dot_dir_unique(i_dir))], 0 );
                raster_doton{i_coh, i_dir} = raster_temp;
                rasteraxis = [rasteraxis; axis(panel_dotson(i_temp))];
            end
        end

%         n_panel = length(panel_dotson);
%         for i_panel = 1:n_panel
%             axes(panel_dotson(i_panel));
%             ylim([0 max(rasteraxis(:,4))]);
%         end
                

        %   panel 3     align data on sac on, separate by dots coherence and choice direction, markers show dots onset
        %               sorted by dots onset
        %   panel 4     align data on feedback, separate by dots coherence
        %   and choice direction, markers show sac onset and reward onset
        %               sorted by rew onset
        for i_coh = 1:n_dotcoh
            for i_dir = 1:n_sacdir
                i_temp = i_coh + (i_dir-1)*n_dotcoh;
                switch flag
                    case 0     %             include all finished trials
                        trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & sacdir == sacdir_unique(i_dir)  & conditions(:,8)==3);
                    case 1     %             include only correct trials
                        trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & sacdir == sacdir_unique(i_dir) & conditions(:,6)==1 & conditions(:,8)==3);
                    case -1     %             include only error trials
                        trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & sacdir == sacdir_unique(i_dir) & conditions(:,6)==0 & conditions(:,8)==3);
                end
                if ~isempty(trialBounds)
                    trials_included = trials_included(trials_included<trialBounds(1)|trials_included>trialBounds(2));
                end
                dotson_sac{i_coh, i_dir} = alignTimes(trials_included,2) - alignTimes(trials_included,3);
                panel_sacon(i_temp) = subplot(plotrows, plotcols, 3+(i_temp-1)*plotcols);
                raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,3), ...
                    dotson_sac{i_coh, i_dir}, 0, timerange(3,1), timerange(3,2), panel_sacon(i_temp), ...
                    ['SAC ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
%                 raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,3), ...
%                     dotson_sac{i_coh, i_dir}, 1, timerange(3,1), timerange(3,2), '', ...
%                     ['SAC ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
                raster_sacon{i_coh, i_dir} = raster_temp;

                panel_fdbkon(i_temp) = subplot(plotrows, plotcols, 4+(i_temp-1)*plotcols);
                sacon_fdbkon{i_coh, i_dir} = alignTimes(trials_included,3) - alignTimes(trials_included,6);
                rewon_fdbkon{i_coh, i_dir}  = alignTimes(trials_included,4) - alignTimes(trials_included,6);
                raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,6), ...
                    [rewon_fdbkon{i_coh, i_dir} sacon_fdbkon{i_coh, i_dir}], 0, timerange(3,1), timerange(3,2), panel_fdbkon(i_temp), ...
                    ['FEEDBAK ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
                raster_fdbkon{i_coh, i_dir} = raster_temp;
%                 ylim([0 max(rasteraxis(:,4))]);
            end
        end

        %   panel 5     align data on rew on, separate by dots coherence and choice direction, markers show sac onset
        %               sorted by reward onset
        %               starting 9-16-08, file may contain correct trials with reward omitted. 
        if flag>=0     % include only correct trials
            for i_coh = 1:n_dotcoh
                for i_dir = 1:n_sacdir
                    i_temp = i_coh + (i_dir-1)*n_dotcoh;
                    panel_rewon(i_temp) = subplot(plotrows, plotcols, 5+(i_temp-1)*plotcols); hold on;
                    if dot_coh_unique(i_coh) == 51.2
                        trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & sacdir == sacdir_unique(i_dir) & conditions(:,6) == 1 & isnan(conditions(:,7)) & conditions(:,8)==3);
                        if ~isempty(trialBounds)
                            trials_included = trials_included(trials_included<trialBounds(1)|trials_included>trialBounds(2));
                        end
                        sacon_omitrew{i_coh, i_dir} = alignTimes(trials_included,3) - alignTimes(trials_included,7);
                        raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,7), ...
                            sacon_omitrew{i_coh, i_dir}, 0, timerange(4,1), timerange(4,2), panel_rewon(i_temp), ...
                            ['REW ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 1 );
                        %                     raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,4), ...
                        %                         sacon_rew{i_coh, i_dir}, 1, timerange(4,1), timerange(4,2), '', ...
                        %                         ['REW ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
                        raster_omitrew{i_coh, i_dir} = raster_temp;
                    end
                    
                    trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & sacdir == sacdir_unique(i_dir) & ~isnan(conditions(:,7)) & conditions(:,8)==3);
                    if ~isempty(trialBounds)
                        trials_included = trials_included(trials_included<trialBounds(1)|trials_included>trialBounds(2));
                    end
                    sacon_rew{i_coh, i_dir} = alignTimes(trials_included,3) - alignTimes(trials_included,4);
                    raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,4), ...
                        sacon_rew{i_coh, i_dir}, 0, timerange(4,1), timerange(4,2), panel_rewon(i_temp), ...
                        ['REW ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
%                     raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,4), ...
%                         sacon_rew{i_coh, i_dir}, 1, timerange(4,1), timerange(4,2), '', ...
%                         ['REW ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
                    raster_rewon{i_coh, i_dir} = raster_temp;
%                     ylim([0 max(rasteraxis(:,4))]);
                end
            end
        else    % use fdbkon
            for i_coh = 1:n_dotcoh
                for i_dir = 1:n_sacdir
                    i_temp = i_coh + (i_dir-1)*n_dotcoh;
                    trials_included = find(conditions(:,3)==dot_coh_unique(i_coh) & sacdir == sacdir_unique(i_dir) & isnan(conditions(:,7)) & conditions(:,8)==3);
                    if ~isempty(trialBounds)
                        trials_included = trials_included(trials_included<trialBounds(1)|trials_included>trialBounds(2));
                    end
                    sacon_rew{i_coh, i_dir} = alignTimes(trials_included,3) - alignTimes(trials_included,5);
                    panel_rewon(i_temp) = subplot(plotrows, plotcols, 5+(i_temp-1)*plotcols);
                    raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,5), ...
                        sacon_rew{i_coh, i_dir}, 0, timerange(4,1), timerange(4,2), panel_rewon(i_temp), ...
                        ['FEEDBACK ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
%                     raster_temp = plotRasterLDdots(data, trials_included, iUnit, alignTimes(trials_included,4), ...
%                         sacon_rew{i_coh, i_dir}, 1, timerange(4,1), timerange(4,2), '', ...
%                         ['REW ON    coh ' num2str(dot_coh_unique(i_coh)) ' dir ' num2str(sacdir_unique(i_dir))], 0 );
                    raster_rewon{i_coh, i_dir} = raster_temp;
%                     ylim([0 max(rasteraxis(:,4))]);
                end
            end
            
        end
    end
end

