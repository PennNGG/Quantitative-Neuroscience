function y = nanrunmedian(z,n)
% running median of z, respecting nan's.  The running median is computed over n
% values left and right of each value of z.  The running median is therefore
% computed over a width of 2*n + 1  samples.  If z is a matrix, the
% operation is performed over each column.
% Usage:  y = nanrunmedian(z,n)

% 5/12/04 jig created from nanrunmean
% 10/15/97 mns wrote it

siz_z = size(z);

if length(siz_z) > 2
  error('input must be vector or matrix')
end
% z = [2 0 1 0 nan 1 0 0 1 3]

if any(size(z)==1)
  % vector
  y = rnanmedV(z,n);
else
  % z is a matrix. Do the operation on each column
  y = nans(size(z));
  for i = 1:siz_z(2)
    c = z(:,i);
    y(:,i) = rnanmedV(c,n);
  end
end
  
function y = rnanmedV(z,n)
siz_z = size(z);			% what is size of vector we hand routine?
z = z(:)';				% force row vector
m = length(z);
% z = [nans(n,1); z; nans(n,1)]';	% pad and transpose to row
q = nans(2*n + 1, length(z)+2*n+1);
% k = -2
for k = -n:n
  j = 1 + k+n;
  q(j,n+k+1:n+k+m) = z;
end
y = nanmedian(q(:,n+1:n+m));	% a row vector
if siz_z(2) == 1
  % we handed the routine a column vector, so return the same
  y = y(:);
end
  
  
