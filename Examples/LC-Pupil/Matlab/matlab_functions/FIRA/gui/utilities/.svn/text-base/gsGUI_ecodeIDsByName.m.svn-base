function varargout = gsGUI_ecodeIDsByName(key, varargin)
% function varargout = gsGUI_ecodeIDsByName(key, varargin)
%
%   assumes there is a GUI with a menu and an edit box
%   'setf' makes the menu entries the "id" ecode fields from FIRA
%   'getf' gets an array of ids for each of the given trials
%
% Usage:
%              gsGUI_ecodeIDsByName('setf', menu_h, default_index);
%      times = gsGUI_ecodeIDsByName('getf', menu_h, trials);

% created 11/12/04 by jig

global FIRA

if strcmp(key, 'setf')
    
    %%%
    % SET
    %%%
    
    if nargin < 2
        return
    end
    
    % get list of ids (these are the menu entries)
    ids = getFIRA_ecodeNames('id');

    % get the default entry
    default_index = 1;
    if nargin == 3 & varargin{2} > 1 & varargin{2} <= length(ids)
        default_index = varargin{2};
    end

    % set the entries
    set(varargin{1}, 'Value', default_index, 'String', {'none' ids{:}});
    
else
    
    %%%
    % GET
    %%%
    
    if nargin < 2
        varargout{1} = [];
        return
    end
    
    % get the ids
    if nargin == 3
        varargout{1} = getFIRA_ecodesByName( ...
            getGUI_pmString(varargin{1}), 'id', varargin{2});
    else
        varargout{1} = getFIRA_ecodesByName( ...
            getGUI_pmString(varargin{1}), 'id');
    end
end
