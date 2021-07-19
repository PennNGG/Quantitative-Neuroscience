function dvar_ = ddPow4_dv(fits, data, grain)
% function dvar_ = ddPow4_dv(fits, data, grain)
%
%   fits:
%       fits(1) ... A      (coh scale)
%       fits(2) ... M      (coh exponent)
%       fits(3) ... N      (time exponent)
%       fits(4) ... lambda ("lapse")
%
%   data columns are:
%       data(1)   ... coh (%)
%       data(2)   ... time (s)
%       data(3)   ... dot dir (-1/1)
%

if nargin < 3 || isempty(grain)
    grain = 0.01;
end

R0 = 10;
S1 = (R0 + fits(1).*data(:,1).^fits(2)).*data(:,2).^fits(3);
S2 = R0.*data(:,2).^fits(3);

mu = S1 - S2;
sd = sqrt(0.3.*(S1+S2));

for i = 1:length(mu)
    if sd(i) == 0
        dvar(i) = 0;
    else
        diffax                = mu(i)-5.*sd(i):grain:mu(i)+5.*sd(i);
        sample_pdf            = normpdf(diffax,mu(i),sd(i));
        sample_pdf(diffax<0)  = 0;
        dvar(i)               = trapz(diffax,diffax.*(sample_pdf/(1-normcdf(0, mu(i), sd(i)))));
        % trapz(diffax,diffax.*(sample_pdf/trapz(diffax,sample_pdf)));
    end
end

dvar_ = exp(dvar)./(1 + exp(dvar));
