function vals_ = logiTs(fits, data, spec)
% function vals_ = logiTs(fits, data, spec)
% 
% Logistic fit as a function of Coherence AND Time.
%
%   Computed at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... OPTIONAL time (sec)
%       data(3)   ... OPTIONAL dot dir (-1/1)
%
%   Given parameters in "fits":
%       1 - 3 parameters for threshold
%       1 - 2 parameters for shape
%       0 - 1 parameters for lapse
%       0 - 1 parameters for bias
% 
% Determined by spec ... see below
%
% Lapse and Bias are computed using Abbott's Law:
% P = G + (1 - G - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

persistent func

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % check data matrix.. should include columns:
    %   Coherence
    %   OPTIONAL Time
    %   OPTIONAL Direction
    %   % correct
    %   OPTIONAL n
    if isempty(data)
        error('quickTs: no data')
    end
    
    % get guesses for alpha, beta, lambda from quick3
    if any(data(:, end) > 1
        vals = quick3([], data(:, [1 end-1]));
    else
        vals = quick3([], data(:, [1 end]));
    end

    % Parse specs to determine form of alpha, beta, lapse, bias
    if nargin < 3 || isempty(spec)
        spec = [1 0 1 0];
    elseif size(spec,2) < 4
        ss   = [1 0 1 0];
        ss(
        spec = 
        spec = cat(2, spec, 0);
    end
    % alpha and beta can be time dependent only if 
    %   time is given
    if nargin < 2 || size(data,2) < 3 || ...
            (size(data,2) == 3 && any(data(:,3)>1))
        spec(1:2) = 0;
    end
    % bias possible only if dir given
    if nargin < 2 || size(data,2) < 4 || ...
            (size(data,2) == 4 && any(data(:,4)>1))
        spec(4) = 0;
    end
        
    % build function and update guesses
    % Alpha
    switch spec(1)
        case 0
            alpha = 'fits(1)';
            vals_ = vals(1,:);   
        case 1
            alpha = '(fits(1).*data(:,2).^fits(2))';
            vals_ = cat(1, vals(1,:), [0.5 -10 10]);
        case 2
            alpha = '(fits(1)+fits(2).*exp(-data(:,2)./fits(3)))';
            vals_ = [ ...
                20   0.01 100; ...
                40   0.01 100; ...
                0.2 0.01 10];
    end

    % Beta
    fiti = size(vals_, 1) + 1;
    switch spec(2)
        case 0
            beta  = sprintf('fits(%d)', fiti);
            vals_ = cat(1, vals_, vals(2,:));
        case 1
            beta  = sprintf('(fits(%d).*data(:,2).^fits(%d))', fiti, fiti+1);
            vals_ = cat(1, vals_, vals(2,:), [0.0 -10 10]);
    end
    
    % Lapse
    if spec(3)
        lapse = sprintf('fits(%d)', size(vals_, 1) + 1);
        vals_ = cat(1, vals_, vals(3,:));
    else
        lapse = '0';
    end
    
    % Guess
    if spec(4)
        guess = sprintf('(0.5+fits(%d).*data(:,3))', size(vals_, 1) + 1);
        vals_ = cat(1, vals_, [0 -0.5 0.5]);
    else
        guess = '0.5';
    end
        
    % make the func
    func = ['vals_=' guess '+(1-' guess '-' lapse ').*(1-exp(-(data(:,1)./' alpha ').^' beta '));']

else

    % just eval the string
    eval(func);
end
