function varargout = gsGUI_analogByName(key, varargin)
% function varargout = gsGUI_analogByName(key, varargin)
%
%   assumes there is a GUI with a menu
%   'set' makes the menu entries the names of analog channels in FIRA
%   'get' gets the index of the chosen analog channel
%
% Usage:
%              gsGUI_analogByName('setf', menu_h);
%      index = gsGUI_analogByName('getf', menu_h);

% created 11/12/04 by jig

global FIRA

if strcmp(key, 'setf')
    
    if nargin < 2
        return
    end

    if isempty(FIRA) || ~isfield(FIRA, 'analog') || isempty(FIRA.analog.name)
        set(varargin{1}, 'Value', 1, 'String', {'no analog'});
    else
        set(varargin{1}, 'Value', 1, 'String', FIRA.analog.name);
    end

else
    
    if nargin < 2 || isempty(FIRA) || ~isfield(FIRA, 'analog') || isempty(FIRA.analog.name)
        varargout{1} = [];
    else
        varargout{1} = get(varargin{1}, 'Value');
    end
end
