function varargout = gsGUI_selectByUniqueID(key, varargin)
% function varargout = gsGUI_selectByUniqueID(key, varargin)
%
%   assumes there is a GUI with a menu
%   'set' makes the menu entries the "id" ecode fields from FIRA
%   'get' gets a matrix of selection arrays of the given trials for
%       the unique values of the chosen id
%
% Usage:
%                    gsGUI_selectByUniqueID('setf', menu_h, default_value);
%   [Lsb, uniques] = gsGUI_selectByUniqueID('getf', menu_h, trials, max_n, include_list);

% created 11/12/04 by jig

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
    
    if nargin >= 3
        if isscalar(varargin{2})
            
            % given as index
            if varargin{2} > 1 && varargin{2} <= length(ids)
                default_index = varargin{2};
            end
            
        elseif ischar(varargin{2})

            % given as string name
            ind = find(strcmp(varargin{2}, ids));
            if ~isempty(ind)
                default_index = ind + 1; % +1 becz 'none' starts list
            end
        end
    end

    % set the entries
    set(varargin{1}, 'Value', default_index, 'String', {'none' ids{:}});

else

    %%%
    % GET
    %%%

    % check args (sort of -- will bomb if nargout > 1
    % & nargin > 0)
    if nargout < 1 || nargin < 2
        return
    end

    % let selectFIRA_trialsByUniqueID do the work
    if nargin >= 3
        [varargout{1:nargout}] = selectFIRA_trialsByUniqueID( ...
            getGUI_pmString(varargin{1}), varargin{2});
    else
        [varargout{1:nargout}] = selectFIRA_trialsByUniqueID( ...
            getGUI_pmString(varargin{1}));
    end

    % fourth (optional) arg is maximum number of categories
    if nargin >= 4 && ~isempty(varargin{3}) && ...
            size(varargout{1},2) > varargin{3}
        varargout{1} = varargout{1}(:,1:varargin{3});
        if nargout > 1
            varargout{2} = varargout{2}(1:varargin{3});
        end
    end
    
    % fifth (optional) argument is include list
    if nargin >= 5 && ~isempty(varargin{4}) && nargout > 1
        includes = ismember(varargout{2}, varargin{4});
        varargout{1} = varargout{1}(:, includes);
        varargout{2} = varargout{2}(includes);
    end
end
