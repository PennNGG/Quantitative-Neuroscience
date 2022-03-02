function params_ = getGUI_FIRAparams
% function params_ = getGUI_FIRAparams
%
% pops up a little modal gui to get the params to used
% to build FIRA

% make defaults persisent, so re-opening the dialog gives the
% same values entered the previous time
persistent defaults
if isempty(defaults)
    defaults = struct();
end

plist = cell2struct({
    'filetype',    'c', '',        'type of data file ([], "rex", or "nex"):'; ...
    'generator',   'c', '724',     'FIRA generator (e.g., 724):'; ...
    'keep_spikes', 'a', 'all',     'spike codes ("all" or <channel> <unit>; etc):'; ...
    'keep_sigs',   'n', '[15 16]', 'analog signals (e.g, [15 16])'; ...
    'keep_matlab', 'n', '0',       'matlab flag (keep(1)/not(0))'; ...
    'keep_dio',    'n', '0',       'dio flag (keep(1)/not(0))'; ...
    'flags',       'n', '',        'flags (e.g., [0 0])'}, ...
    {'field', 'type', 'default', 'prompt'}, 2);

% make cell array of strings for prompts, defaults
sp     = size(plist, 1);
prompt = cell(sp, 1);
defs   = cell(sp, 1);

for i = 1:sp
    prompt{i} = plist(i).prompt;
    if isfield(defaults, plist(i).field)
        if (plist(i).type == 'c' | plist(i).type == 'a') & ...
                ischar(defaults.(plist(i).field)) | isempty(defaults.(plist(i).field))
            defs{i} = defaults.(plist(i).field);
        elseif (plist(i).type == 'n' | plist(i).type == 'a') & ...
                isnumeric(defaults.(plist(i).field))
            defs{i} = mat2str(defaults.(plist(i).field));
        end
    end
    if isempty(defs{i})
        defs{i} = plist(i).default;
    end
end

% call the dialog
das = inputdlg(prompt, 'Options for building FIRA', 1, defs);

% if we got 'cancel' then just return null
if isempty(das)
    params_ = [];
    return
end

% otherwise, parse the arguments into a struct
params_ = struct();
for i = 1:sp
    if (plist(i).type == 'c') | ((plist(i).type == 'a') & strcmp(das{i}, 'all'))
        params_.(plist(i).field) = das{i};
    else % if (plist{i}{2} == 'n')
        params_.(plist(i).field) = str2num(das{i});
    end
end

% save the current params_ as the next defaults
defaults = params_;
