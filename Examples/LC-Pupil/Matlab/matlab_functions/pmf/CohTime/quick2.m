function vals_ = quick2(fits, data)
% function vals_ = quick2(fits, data)
% 
% 2 parameter Quick (cumulative Weibull): 
%   alpha (threshold)
%   beta  (shape)
%
% Computes a standard 2AFC Quick fit
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%
%   given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... beta    (shape)
% 

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    TINY = 0.001;
    vals_ = [0.2 TINY 1-TINY; 1.4 0.1 10];
    if nargin < 2 || isempty(data)
        return
    end

    % Use linear interpolation to guess alpha.
    %   First get % cor per coherence...
    % 	Note that here, data is actually
    %       [data pcor], where pcor cols are % correct & n
    if size(data, 2) < 3 || length(unique(data(:,1))) == size(data, 1)
        if length(unique(data(:,1))) == size(data, 1)
            cp = data(:, [1 2]);
        else
            cp = repmat(nonanunique(data(:,1)), 1, 2);
            for ii = 1:size(cp,1)
                Lcoh = data(:,1) == cp(ii,1);
                cp(ii,2) = sum(data(Lcoh,2))./sum(Lcoh);
            end
        end
    end

    % next line takes x and %-cor columns, flips them and interpolates along
    % x to find the value corresponding to .8 correct.  The interpolation
    % requires monotonic %-cor column, so we sort the matrix 1st.
    % Remember, it's just a guess.
    gpct   = 0.82;
    row_lo = find(cp(:,2)<=gpct, 1, 'last');
    if isempty(row_lo)            % no percent correct > gpct
        vals_(1,1) = cp(1,1);
    elseif row_lo == size(cp,1)   % no percent correct < gpct
        vals_(1,1) = cp(end,1);
    else                            % interpolate
        row_hi = row_lo + 1;
        vals_(1,1) = cp(row_lo,1) + (cp(row_hi,1) - cp(row_lo,1)) * ...
            (gpct - cp(row_lo,2)) / (cp(row_hi,2) - cp(row_lo,2));
    end
else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + 0.5 .* (1 - exp(-(data(:,1)./fits(1)).^fits(2)));
end
