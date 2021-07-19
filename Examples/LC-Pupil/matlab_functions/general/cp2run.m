function [r,rid] = cp2run(cp)
% Takes changepoint binary vector and converts to run length

N = numel(cp);
r = zeros(N,1);
rid = r;
r(1) = 1;

rN = 1;

for n = 2:N
    if cp(n)
        r(n) = 1;
        rN = rN + 1;
    else
        r(n) = r(n-1)+1;
    end
    
    rid(n) = rN;
    
end