function [Lgood_, id_] = verify(s, id)
% function [Lgood_, id_] = verify(s, id)
%
% verify method for class analog
%
% verifies whether the given spike id (typically
%   an nx2 array of [channel unit])
%   is in the "keep_spikes" list. If good spikes
%   are found, setup FIRA.spikes
%
% Returns:
%   Lgood_ ... selection array of ids we want
%   id_    ... (optional) actual id of SINGLE given channel/unit

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
% 
% created 11/23/04 by jig
% updated 3/3/05

global FIRA

% check args -- if just unit given, add dummy channel
if size(id, 2) == 1
    id = [ones(size(id)) id];
end

% find appropriate ids, keeping track of what
% we find so we can setup FIRA.spikes
if isnumeric(s.keep_spikes)
    
    % find good ids
    [Lgood_, loc] = ismember(id, s.keep_spikes(:, 1:2), 'rows');
    
    % want to setup given ids
    if any(Lgood_)
        tosave = s.keep_spikes(unique(loc(loc>0)), :);
    else
        tosave = [];
    end
    
elseif strcmp(s.keep_spikes, 'all')
    
    % all ids are good
    Lgood_ = ~isnan(id(:,2));

    % want to alloc all found ids
    tosave = unique(id(Lgood_,:), 'rows');
    
elseif strcmp(s.keep_spikes, 'allnz')
    
    % all ids with unit ~= 0 are good
    Lgood_ = id(:,2) ~= 0;
    
    % want to alloc all found ids
    tosave = unique(id(Lgood_,:), 'rows');
    
end

% setup FIRA.spikes with found ids not already in FIRA.spikes
if isempty(tosave)
    if nargout == 2
        id_ = [];
    end
    return
elseif size(tosave, 2) == 2
    [new_ids, I] = setdiff(tosave(:,1)*1000+tosave(:,2), FIRA.spikes.id');
elseif size(tosave, 2) == 3
    [new_ids, I] = setdiff(unique(tosave(:,3)), FIRA.spikes.id');
end

if ~isempty(new_ids)
    
    % update channel/unit/id
    FIRA.spikes.channel = [FIRA.spikes.channel tosave(I, 1)'];
    FIRA.spikes.unit    = [FIRA.spikes.unit    tosave(I, 2)'];
    FIRA.spikes.id      = [FIRA.spikes.id      new_ids'];
    
    % add extra (empty) columns of data, if necessary
    if isempty(FIRA.spikes.data)

        % careful of this case: nothing allocated in
        % FIRA.spikes.data, which can occur if looking for
        % 'all' spikes (specific spikes would have been 
        % specifically allocated) but none has arrived until
        % now ... in this case we alloc as many trials
        % as have been alloc'ed in FIRA.ecodes
        FIRA.spikes.data = cell(size(FIRA.ecodes.data, 1), ...
            size(FIRA.spikes.id, 2));
    else

        [rows, cols]     = size(FIRA.spikes.data);
        FIRA.spikes.data = cat(2, FIRA.spikes.data, ...
            cell(rows, size(FIRA.spikes.id, 2) - cols));
    end
end

if nargout == 2
    if size(tosave, 1) == 1
        if size(tosave, 2) == 2
            id_ = id(1)*1000+id(2);
        else
            id_ = tosave(1, 3);
        end
    else
        id_ = [1000];
    end
end
