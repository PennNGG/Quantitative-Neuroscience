function vals_ = ddExp4fz_LF(fits, data, lapse, fc)
% function vals_ = ddExp4fz_LF(fits, data, lapse, fc)
%
% 4 parameters: A, alpha, and two bias
%   parameters, one DC and one that scales the filtered choice array
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^1.25
%   And on time as a decaying exponential
%       A(coh, t) = A_max * exp(-alpha*t)
%
%   at values in "data":
%       data(1) ... coh [0 ... 1]
%       data(2) ... time (sec)
%       data(3) ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... filtered-choice bias scaling factor
%       fits(4) ... DC bias
%
%   lapse ... (optional) lapse rate
%   fc    ... (optional) array of filtered choices
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    if nargin < 2
        data = [];
    end

    % get initial values from ddExp3z
    vals_      = ddExp4fz([], data);
    valz       = ddExp4z([], data);
    vals_(5,:) = valz(4,:);
    vals_(3,:) = [];

else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25; % just cuz

    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));

    if nargin < 4 || isempty(fc)
        Bs = fits(4).*ones(size(data,1),1);        
    else
        Bs = fits(4)+fits(3).*fc;
    end
        
    if nargin > 2 && isnan(lapse)
    
        % flag for returning biases
        vals_ = [Bs mu];
    else

        if nargin < 3 || lapse < 0.001
            lapse = 0.001;
        end

        vals_ = 0.5 + (0.5 - lapse).* ...
            erf((mu+Bs.*data(:,3))./nu./sqrt(2));
    end
    
    %     if nargin < 4 || isempty(fc)
    %         vals_ = 0.5 + (0.5 - lapse).* ...
    %             erf((mu./nu + fits(4).*data(:,3))./sqrt(2));
    %     elseif isnan(fc)
    %         vals_ = mu./nu;
    %     else
    %         vals_ = 0.5 + (0.5 - lapse).* ...
    %             erf((mu./nu + (fits(4)+fits(3).*fc).*data(:,3))./sqrt(2));
    %     end
end
