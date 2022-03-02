function varargout = gsGUI_ecodeTimesByName(key, varargin)
% function varargout = gsGUI_ecodeTimesByName(key, varargin)
%
%   assumes there is a GUI with a menu and an edit box
%   'set' makes the menu entries the "time" ecode fields from FIRA
%   'get' gets an array of times for each of the given trials
%       of the time of the event chosen in the menu plus the offset in
%       the text box
%
% Usage:
%              gsGUI_ecodeTimesByName('setf', menu_h, default_index, ...
%                                       edit_h, edit_value);
%      times = gsGUI_ecodeTimesByName('getf', menu_h, edit_h, ...
%                                       trials);

% created 11/12/04 by jig

if strcmp(key, 'setf')
    
    %%%
    % SET
    %%%
    
    if nargin < 2
        return
    end
    
    % get list of times (these are the menu entries)
    times = getFIRA_ecodeNames('time');

    % get the default entry
    default_index = 1;
    if nargin >= 3 
        
        if isscalar(varargin{2}) 

            % index given
            if varargin{2} > 1 && varargin{2} <= length(times)
                default_index = varargin{2};
            end
            
        elseif ischar(varargin{2})
            
            % name given
            ind = find(strcmp(varargin{2}, times));
            if ~isempty(ind)
                default_index = ind + 1; % +1 becz 'none' starts list
            end
            
        elseif iscell(varargin{2})
            
            % cell array of possible strings given
            tries = varargin{2};
            while ~isempty(tries)
                ind = find(strcmp(tries{1}, times));
                if ~isempty(ind)
                    default_index = ind + 1; % +1 becz 'none' starts list
                    break
                end
                tries(1) = [];
            end                
        end
    end

    % set the entries
    set(varargin{1}, 'Value', default_index, 'String', {'none' times{:}});
    
    % init the edit box, if arguments are given
    if nargin >= 5 && ~isempty(varargin{3})
        set(varargin{3}, 'String', num2str(varargin{4}));
    end

else
    
    %%%
    % GET
    %%%
    
    if nargin < 2
        varargout{1} = [];
        return
    end
    
    % get the times
    if nargin == 4
        varargout{1} = getFIRA_ecodesByName( ...
            getGUI_pmString(varargin{1}), 'time', varargin{3});
    else
        varargout{1} = getFIRA_ecodesByName( ...
            getGUI_pmString(varargin{1}), 'time');
    end
    
    % add offset, if given
    if nargin >= 3 && ~isempty(varargin{2})
        varargout{1} = varargout{1} + str2double(get(varargin{2}, 'String'));
    end
end
