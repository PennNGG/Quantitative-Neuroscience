function qdat_ = quick_formatData2(cohs, Lcoh, Lcor)
%
% converts selection arrays to a matrix
% used by quick_fit
%
% input: 
%   cohs ... list of unique coherences (cols of Lcoh)
%   Lcoh ... selection array of coherences
%   Lcor ... selection array of correct trials
% 
% returns:
%  qdat ... [cohs fraction_correct num_trials] x cohs
%

Lz = cohs == 0;
cohs(Lz)    = [];
Lcoh(:, Lz) = [];

qdat_ = zeros(length(cohs), 3);
for ii = 1:length(cohs)
    ss = sum(Lcoh(:, ii));
    if ss
        qdat_(ii, :) = [ ...
            cohs(ii), ...
            sum(Lcor & Lcoh(:, ii))/sum(Lcoh(:, ii)), ...
            sum(Lcoh(:, ii))];
    else
        qdat_(ii, :) = [cohs(ii), 0, 0];
    end            
end
