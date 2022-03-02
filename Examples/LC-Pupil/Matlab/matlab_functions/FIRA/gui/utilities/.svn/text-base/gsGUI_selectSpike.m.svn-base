function varargout = gsGUI_selectSpike(key, varargin)
% function varargout = gsGUI_selectSpike(key, varargin)
%
%   assumes there is a GUI with a menu
%   'set' makes the menu entries the ids of spikes in FIRA
%   'get' gets the index of the chosen spike id
%
% Usage:
%              gsGUI_selectSpike('setf', menu_h);
%      index = gsGUI_selectSpike('getf', menu_h);

% created 11/12/04 by jig

global FIRA

if strcmp(key, 'setf')
    
    if nargin < 2
        return
    end

    if isempty(FIRA) | isempty(FIRA.spikes.id)
        set(varargin{1}, 'Value', 1, 'String', {'no spikes'});
    else
        set(varargin{1}, 'Value', 1, 'String', cellstr(num2str(FIRA.spikes.id'))');
    end

else
    
    if nargin < 2 | isempty(FIRA) | isempty(FIRA.spikes.id)
        varargout{1} = [];
    else
        varargout{1} = get(varargin{1}, 'Value');
    end
end
