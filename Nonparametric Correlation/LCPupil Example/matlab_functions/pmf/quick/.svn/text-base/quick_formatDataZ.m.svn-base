function qdat_ = quick_formatDataZ(dat)
%
% converts trial-based data to a matrix
% used by quick_fit. Z means that the two
%   dirs are averaged using z-scores.
%
% input: 
%  dat  ... [coh correct dir] x trials
% 
% returns:
%  qdat ... [cohs pct_correct num_trials] x cohs
%

cbins  = unique(dat(dat(:,1)~=0,1));
qdat_  = nans(length(cbins), 3);

dirs = [-1 1];
Ld   = false(size(dat,1), length(dirs));
for dd = 1:length(dirs)
    Ld(:,dd) = dat(:,3) == dirs(dd);
end

zs = nans(length(dirs),2);
for cc = 1:length(cbins)
  Lc = dat(:,1) == cbins(cc);
  for dd = 1:length(dirs)
      Lcd = Lc & Ld(:,dd);
      if sum(Lcd) > 0
          zs(dd,:) = [sqrt(2)*erfinv(2*sum(dat(Lcd,2))/sum(Lcd)-1) sum(Lcd)];
      else
          zs(dd,:) = [nan 0];
      end
  end
  zavg = sum(prod(zs,2))./sum(zs(:,2));
  qdat_(cc,:) = [cbins(cc) .5+.5*erf(zavg/sqrt(2)) sum(zs(:,2))];
end

