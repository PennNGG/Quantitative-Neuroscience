function ldat_ = logist_formatData(cohs, Lcoh, Lcor)
%
% converts selection arrays to a matrix
% used by logist_fit
%
% input: 
%   cohs ... list of unique coherences (cols of Lcoh)
%   Lcoh ... selection array of coherences
%   Lcor ... selection array of correct trials
% 
% returns:
%  ldat ... [1 cohs(usu signed) choice(0 or 1)] x trials
%

ldat_  = [ones(size(Lcoh, 1), 2) Lcor];
for ii = 1:length(cohs)
    ldat_(Lcoh(:, ii), 2) = cohs(ii)/100;
end
