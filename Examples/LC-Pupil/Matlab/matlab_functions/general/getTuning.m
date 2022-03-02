function  [th, width, stat] = getTuning(x, y, ys, n, method)
% Usage:
%   [th, width, r] = getTuning(x, y,... , 'method', 'vonmises')
%
%   INPUTS:
%       x      - diections in radian
%       y      - neural responses
%       method - 'VonMises', 'WrappedGaussian' or 'VectorAverage'
%                 - 'VonMises' fits y to a von Mises function
%                 - 'WrappedGaussian' fits y to a circular gaussian
%                 - 'VectorAverage' compute the mean vector of (x,y) in
%                   polar coordinate
%
%   OUTPUTS:
%       th     - preferred direction
%       width  - circular standard deviation given by the fit
%                (in case of vector average, it's given by a transformation
%                of the tuning strength)
%       stat   - [r, d, p], where 
%                 - r is the tuning strength given by the vector average of the responses
%                   (i.e. the magnitude of the mean vector to the preferred direction)
%                 - d is a directionality test
%                 - p is the goodness of fit, given by fmincon
%

% created by jcl on 08/02/04

% check inputs
if nargin < 2
    return;

elseif nargin < 3
    ys     = ones(size(y));
    n      = ones(size(y));
    method = 'vectoravg';

elseif nargin < 4
    n      = ones(size(y));
    method = 'vectoravg';

elseif nargin < 5
    method = 'vectoravg';
    
elseif nargin > 5
    return;  
end

if isempty(ys)
    ys = ones(size(y));
end

if isempty(n)
    n  = ones(size(y));
end


% set data as global variable
global cird
cird = [x(:) y(:) ys(:)];

warning off
% compute preferred direction and tuning width based on the method
if strcmp(lower(method), 'vectoravg')       % vector averaging
    % use trigonometry to compute the mean angle
    a = dot(cos(x), y);
    b = dot(sin(x), y);

    % compute the preferred direction
    if a > 0
        th = atan(b/a);
    elseif a < 0
        th = pi+atan(b/a);
    elseif (a == 0) & (b > 0)
        th = pi/2;
    elseif (a == 0) & (b < 0)
        th = 3*pi/2;
    else
        th = nan;
    end

    % compute tuning strength
    % r=0 if responses are equal in all direction
    % r=1 if response>0 only at the preferred direction
    % For a gaussian orientation tuning curve, r decreases approx.
    % linear with the width of the tuning curve (Swindale NV 1998)
    r = norm(a,b)/sum(y);

    % compute angular standard deviation
    % angular variance = 2*(1-k(2)), where r is the tuning
    % strength (Batschlet 1981)
    width = (2*(1-r))^0.5;
    
    p = nan;
    
   
elseif strcmp(lower(method), 'wrappedgaussian')     % least square fits of the wrapped gaussian function
    % estimates initial conditions ([C,I] = max(y); phi = x(I); s = pi/2^2;)
    [k0(1),i] = max(y);
    k0(2) = 1.5708^2;
    k0(3) = x(i);
   
    % perform chi square fit to model function
    [k, f, eflag, output, l, g, h] = ...
        fmincon(str2func('WrappedGaussian_err'), k0, [], [], [], [],...
                [0 0 0], [1200 12.5664 6.2832], [],...
                optimset('LargeScale', 'off', 'Display', 'off', 'Diagnostics', 'off'));

    % give appropriate outputs
    [tmp, width] = feval(str2func('WrappedGaussian'), k, x);
    width = mod(width,2*pi);
    th    = mod(k(3),2*pi);
    
    p = 1-chi2cdf(WrappedGaussian_err(k), length(x)-length(k));



elseif strcmp(lower(method), 'vonmises')    % least square fits of the von mises function
    % estimates initial conditions ([C,I] = max(y); phi = x(I); s = pi/2^2;)
    [k0(1),i] = max(y);
    k0(2) = 1.5708^2;
    k0(3) = x(i);
    
    % perform chi square fit to model function
    [k, f, eflag, output, l, g, h] = ...
        fmincon(str2func('VonMises_err'), k0, [], [], [], [],...
                [0 0 0], [1200 12.5664 6.2832], [],...
                optimset('LargeScale', 'off', 'Display', 'off', 'Diagnostics', 'off'));

    % give appropriate outputs
    [tmp, width] = feval(str2func('VonMises'), k, x);
    width = mod(width,2*pi);
    th    = mod(k(3),2*pi);
    
    p = 1-chi2cdf(VonMises_err(k), length(x)-length(k));

    
else
    error('No such a method: %s.\n', method)
end


if nargout>2
    if ~strcmp(lower(method), 'vectoravg')  % get r if method is not vector average
        % use trigonometry to compute the mean angle
        a = dot(cos(x), y);
        b = dot(sin(x), y);

        % compute tuning strength
        % r=0 if responses are equal in all direction
        % r=1 if response>0 only at the preferred direction
        % For a gaussian orientation tuning curve, r decreases approx.
        % linear with the width of the tuning curve (Swindale NV 1998)
        r = norm(a,b)/sum(y);
    end
    
    %%%     Test directionality of data with rayleigh test      %%%
    %                                                             
    %   H0: y is drawn from a uniform distribution with respect to x.
    %       If this is the case, the distribution of r is known. We will
    %       test if r is significantly different than . So we will test if      
    %       n computed from y is significantly bigger than a certain critical
    %       value at a particular significant level (0.05 in this case).       
    %   
    %%% Reference: Circular statistics in biology, Batschelet 1981 and
    %%% See also Rayleigh Test for Randomness of Circular Data, Wilkie D
    %%% 1983, Appl. Statist. (1983) 32, No. 3, pp. 311-312
    
    N = sum(n); % Set N = 8 for now. N is the number of unit vector used to compute r.
                % This is not what we do here (y is not a unit vector,
                % y=firing rate) and I still have to think about what the
                % correct n is.
    al = 0.05;
    k  = N*r^2;                  % test statistics
    A  = log(al);
    K  = -A-(2*A+A^2)/(4*N);     % critical value for k
    d  = k>=K;
    stat = [r,d,p];
end

warning on
return;



%--------------------ERROR FUNCTIONS----------------------
% The von Mises function error function
function err_ = VonMises_err(k)
    global cird;  
    err_ = sum(((cird(:,2) - VonMises(k,cird(:,1))).^2)./(cird(:,3).^2));   % sum of square err weighted by the variance
return;



% The wrapped gaussian function error function
function err_ = WrappedGaussian_err(k)
    global cird;   
    err_ = sum(((cird(:,2) - WrappedGaussian(k,cird(:,1))).^2)./(cird(:,3).^2));   % sum of square err weighted by the variance
return;



%--------------------MODEL FUNCTIONS----------------------
% The von Mises function
function varargout = VonMises(k, th)
% von Mises function:
% The circular analogue of the normal distribution.
% 
% The von Mises distribution with a mean angle, phi,
% and a spread parameter, kappa, is given by
%
%   f(theta) = exp(kappa*cos(theta-phi))/(2*pi*I0(kappa)) ---- (1)
%   
% , where I0() is the modified bessel function of the first kind of order 0.
%
% In the model function, a scale factor, A, was added to equation (1),
% which gives the following equation (note that the 2*pi term is included
% in the scale factor A.
% 
%   f(theta) = A*exp(kappa*cos(theta-phi))/I0(kappa)
%
%
% USAGE:  
%   OUTPUT: [R, s]: R - responses at angle th
%                   s - angular deviation of the von Mises function,
%                       analogous to the sigma of the normal distribution
%                       The circular variance is equal to:
%                       sigma^2 = 1-(besseli(phi,kappa)/besseli(0,kappa));
%
%   INPUT:  th - input angle
%           k  - [A, kappa, phi], where:
%                   A     - scale factor
%                   kappa - the width parameter
%                   phi   - preferred direction.
%
% ref: 
%   Eric W. Weisstein. "von Mises Distribution." From MathWorld--A
%   Wolfram Web Resource. http://mathworld.wolfram.com/vonMisesDistribution.html
%

    if nargout == 1
        varargout{1} = k(1)*exp(k(2)*(cos(th-k(3))-1))/besseli(0,k(2));
    elseif nargout == 2
        varargout{1} = k(1)*exp(k(2)*(cos(th-k(3))-1))/besseli(0,k(2));
        varargout{2} = (1-(besseli(k(3),k(2))/besseli(0,k(2))))^0.5; 
    end
        
return;




% The the wrapped Gaussian
function varargout = WrappedGaussian(k, th)
% Wrapped Gaussian function:
% This function gives the sum of a gaussian function at points th+/-n*2*pi as
% though the gaussian function is wrapped around in the direction axis.
% Only the first five terms of the summation (n=-3 to n=3) is included in the summation.
%
% USAGE:  
%   OUTPUT: [R, s]: R - responses at angle th
%                   s - standard deviation of the gaussian function       
%
%   INPUT:  th - input angle
%           k  - [A, sigma, phi], where
%                   A     - scale factor
%                   sigma - variance of the gaussian function
%                   phi   - preferred direction.
    
    if nargout == 1
        varargout{1} = k(1)*(...
                       exp(-0.5*(th-k(3)-3*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)-2*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)-1*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)     ).^2/k(2))...  
                      +exp(-0.5*(th-k(3)+1*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)+2*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)+3*pi).^2/k(2)));  
    elseif nargout == 2
        varargout{1} = k(1)*(...
                       exp(-0.5*(th-k(3)-3*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)-2*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)-1*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)     ).^2/k(2))...  
                      +exp(-0.5*(th-k(3)+1*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)+2*pi).^2/k(2))...  
                      +exp(-0.5*(th-k(3)+3*pi).^2/k(2)));  
        varargout{2} = k(2).^0.5;
    end
    
 return;

 
            