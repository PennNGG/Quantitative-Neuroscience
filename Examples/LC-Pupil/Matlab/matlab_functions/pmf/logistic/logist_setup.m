function [fun_, data_, inits_] = logist_setup(data, lumode)
% function [fun_, data_, inits_] = logist_setup(data, lumode)
%
% if data is a cell:
%    expr   '[C C.*T]'
%    choices
%    bias flag
%    data...

if nargin < 1
    return
end

if iscell(data)
    
    % get expr to feval
    expr    = inline(data{1});
    data(1) = [];

    % get choices
    choices = data{1};
    data(1) = [];
    
    % get bias flag
    bias    = data{1};
    data(1) = [];
    
    % eval expression
    data_ = feval(expr, data{:});

    % add bias term to the beginning
    if bias
        data_ = cat(2, ones(size(data_,1),1), data_);
    end

    % add choices to the end
    data_ = cat(2, data_, choices);
else
    
    data_ = data;
end

% Generate a first guess. For the betas, simply convert all the 1's to .99 and
% all the 0's to .01's and do a quick regression on the logits.  This is
% roughly equivalent to converting the 1's to logit of 3 and 0's to logit of -3
if nargout > 2
    y      = (6 * data_(:,end)) - 3;
    inits_ = [(data_(:,1:end-1)\y), ....
        -100*ones(size(data_,2)-1,1) 100*ones(size(data_,2)-1,1)];  % this is a 1st guess
else
    inits_ = repmat([0 0 1], size(data_,2), 1);
end

% if gamma/lambda given, constrain to use those values
if nargin < 2 || isempty(lumode)
    lumode = 'lu1';
end
if ischar(lumode)
    switch lumode
        case 'n'
            fun_   = @logist_val;
        case 'nk'
            fun_   = @logist_valk;            
        case 'l'
            fun_   = @logist_valL;
            inits_ = cat(1, inits_, [0.01 0 0.2]);
        case 'u'
            fun_   = @logist_valU;
            inits_ = cat(1, inits_, [0.01 0 0.2]);
        case 'lug'
            fun_   = @logist_valLUg;
        case 'lu1'
            fun_   = @logist_valLU1;
            inits_ = cat(1, inits_, [0.01 0 0.2]);
        case 'lu2'
            fun_   = @logist_valLU2;
            inits_ = cat(1, inits_, [0.01 0 0.2; 0.01 0 0.2]);
        otherwise
            fun_   = @logist_val;
    end
end
