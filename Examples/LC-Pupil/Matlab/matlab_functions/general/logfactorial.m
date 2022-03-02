function f = logfactorial(N)

f = zeros(size(N));

for i = 1:size(N,1)
    for j = 1:size(N,2)
        f(i,j) = sum(log(1:N(i,j)));
    end
end