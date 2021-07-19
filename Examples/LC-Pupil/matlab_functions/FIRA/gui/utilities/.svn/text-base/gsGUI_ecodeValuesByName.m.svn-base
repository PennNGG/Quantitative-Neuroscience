function varargout = gsGUI_ecodeValuesByName(key, varargin)
% function varargout = gsGUI_ecodeValuesByName(key, varargin)
%
%   assumes there is a GUI with a menu and an edit box
%   'set' makes the menu entries the "value" ecode fields from FIRA
%   'get' gets the array of values
%
% Usage:
%               gsGUI_ecodeValuesByName('setf', menu_h, default_index);
%      values = gsGUI_ecodeValuesByName('getf', menu_h, trials)

% created 11/12/04 by jig

global FIRA

if strcmp(key, 'setf')

    %%%
    % SET
    %%%

    if nargin < 1
        return
    end

    % get list of times (these are the menu entries)
    values = getFIRA_ecodeNames('value');

    % get the default entry
    default_index = 1;
    if nargin >= 3 & varargin{2} > 1 & varargin{2} <= length(values)
        default_index = varargin{2};
    end

    % set the entries
    set(varargin{1}, 'Value', default_index, 'String', {'none' values{:}});

else

    %%%
    % GET
    %%%
    
    if nargin < 2
        varargout{1} = [];
        return
    end

    % get the values
    if nargin == 3
        varargout{1} = getFIRA_ecodesByName( ...
            getGUI_pmString(varargin{1}), 'value', varargin{2});
    else
        varargout{1} = getFIRA_ecodesByName( ...
            getGUI_pmString(varargin{1}), 'value');
    end
end
