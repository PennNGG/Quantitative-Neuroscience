function b_ = fitLine2E(xx, sx, yy, sy)
% function b_ = fitLine2E(xx, sx, yy, sy)
%
% See Draper & Smith, 3d edition
%   3.4 Straight line regression when both variables are
%       subject to error
%   esp. p. 92, "Geometric mean functional relationship"

fxy = lscov([ones(size(xx)) xx], yy, diag(sy.^2));
fyx = lscov([ones(size(yy)) yy], xx, diag(sx.^2));
b   = sqrt(fxy(2)*1/fyx(2));
b_  = [mean(yy) - b*mean(xx), b];
