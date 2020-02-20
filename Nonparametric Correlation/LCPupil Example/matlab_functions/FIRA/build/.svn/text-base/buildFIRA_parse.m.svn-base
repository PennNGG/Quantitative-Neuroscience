function buildFIRA_parse(num_trials)
% function buildFIRA_parse(num_trials)
%
% Converts raw data in FIRA.raw into ecodes, etc.
% Note that this is the one buildFIRA_* routine that 
%   requires a special case -- the existance of a dataType
%   class called 'trial', which is called first to
%   get trial ecodes from the raw data
%
% Arguments:
%   num_trials ... optional argument for number of trials
%
% Returns:
%   nada

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania
%
% Revision history
% revised 2/28/05 by jig for new FIRA dataTypes tools
% created 10/29/04 by jig from makeFIRA

global FIRA

% check messageH
if FIRA.header.messageH
    base_string = get(FIRA.header.messageH, 'String');
end

% check 'trial' separately from other data types
fnames = setdiff(fieldnames(FIRA.spm), 'trial')';

if nargin < 1 || isempty(num_trials)
    num_trials = inf;
end

count = 0;

% trial parse method sets up FIRA.raw.trial (used by other
%   parse methods) and returns a flag indicating whether
%   or not to continue
while count < num_trials && parse(FIRA.spm.trial)

    % give some feedback
    if ~mod(FIRA.raw.trial.total_count, 50)
        if FIRA.header.messageH
            set(FIRA.header.messageH, 'String', sprintf('%s %d out of %d', ...
                base_string, FIRA.raw.trial.total_count, FIRA.raw.trial.num_startcds));
            drawnow;
        else
            disp(sprintf('Completed %d out of %d raw trials', ...
                FIRA.raw.trial.total_count, FIRA.raw.trial.num_startcds))
        end
    end
    
    % loop through the parse methods
    for fn = fnames
        parse(FIRA.spm.(fn{:}));
    end

    % call the spm trial routine
    if ~isempty(FIRA.header.spmF)
        feval(FIRA.header.spmF, 'trial');
    end
    
    count = count + 1;
end
