function addFIRA_tc(params, reps, randomize_flag)
% function addFIRA_tc(params, reps, randomize_flag)
%
% set-up and allocated tuning curve data in FIRA.
%   Can be n-dimensional -- makes every possible
%   data-value combination
%
% Arguments:
%   params ... nx2 cell array in which each row is:
%                <compute_name>  <values>
%   reps   ... number of complete repetitions
%   randomize_flag ... duh

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check args
if nargin < 1
    params = [];
end

if nargin < 2 || isempty(reps)
    reps = 1;
end

if nargin < 3 || isempty(randomize_flag)
    randomize_flag = true;
end

if isempty(params)

    % just allocate the given number of reps (trials)
    buildFIRA_alloc(reps);
    
else
        
    % make N-D tuning curve
    % this code kicks ass
    grids      = cell(1, size(params, 1));
    [grids{:}] = ndgrid(params{:,2});

    % allocate space for the appropriate number of trials
    num_trials = prod(size(grids{1})) * reps;
    buildFIRA_alloc(num_trials);
    
    % randomize order
    if randomize_flag
        inds = randperm(num_trials);
    else
        inds = 1:num_trials;
    end
    
    % fill in FIRA
    for i = 1:size(grids, 2)
        vals = repmat(grids{i}(:), reps, 1);
        FIRA.ecodes.data(:, getFIRA_ecodeColumnByName(params{i,1})) = ...
            vals(inds);
    end
end