function addTrial(an, start_times, data, names, store_rates)
% function addTrial(an, start_times, data, names, store_rates)
%
% addTrial method for class analog. Adds data to the
%   most recent trial.
%
% Input:
%   an          ... the analog object
%   start_times ... scalar or array of start times
%   data        ... cell array of data arrays
%   names       ... cell array of string names of channels
%   store_rates ... cell array of store rates, one per channel
%
% Output:
%   nada, but fills FIRA.analog.data(trial,:) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if nargin < 3
    return
end

if nargin < 4 
    
    % start with indices of all given data columns
    num_given = size(data, 2);
    num_exist = size(FIRA.analog.name, 2);
    loc       = 1:num_given;
    
    if num_given > num_exist
        
        % if more channels given than exist, name new channels "ch#"
        loc(num_exist+1:end) = 0;
        new_names            = cell(1, num_given - num_exist);
        for nn = 1:size(new_names, 2)
            new_names(nn) = sprintf('ch%d', num_exist+nn);
        end        
    end
    
else
    
    % check given names with existing names
    [tf, loc] = ismember(names, FIRA.analog.name);
    new_names = names(~tf);
end

if any(loc == 0)
    
    % check new names
    Lchk    = check(an, new_names);
    num_new = sum(Lchk);
    
    if num_new
        
        % setup FIRA.analog with new columns
        inds             = find(loc == 0);
        loc(inds(Lchk))  = size(FIRA.analog.name, 2) + [1:num_new];
        FIRA.analog.name = cat(2, FIRA.analog.name, new_names(Lchk));
        if nargin > 4
            if isscalar(store_rates)
                FIRA.analog.store_rate = cat(2, FIRA.analog.store_rate, ...
                    store_rates * ones(1, num_new));
            else
                FIRA.analog.store_rate = cat(2, FIRA.analog.store_rate, ...
                    tore_rates(inds(Lchk)));
            end
        end
        
        % data already exists, must add new columns first
        if size(FIRA.analog.data, 1) > 0            
        
            % add trials to new columns of FIRA.analog.data
            FIRA.analog.data = cat(2, FIRA.analog.data, ...
                struct( ...
                'start_time', nancells(size(FIRA.analog.data, 1), num_new), ...
                'length',     0, ...
                'values',     []));
        end
        
        % add trials to end (rows) of FIRA.analog.data
        alloc(an, FIRA.header.numTrials - size(FIRA.analog.data, 1));
    end
    
    % remove unneeded data
    loc(~Lchk)     = [];
    data(:, ~Lchk) = [];
    if ~isscalar(start_times)
        start_times(~Lchk) = [];
    end
end

% save data
[FIRA.analog.data(end, loc).start_time] = deal(start_times);
[FIRA.analog.data(end, loc).data]        = deal(data{:});
for ii = 1:size(loc, 2);
    FIRA.analog.data(end, loc(ii)).length = size(data{ii}, 1);
end
