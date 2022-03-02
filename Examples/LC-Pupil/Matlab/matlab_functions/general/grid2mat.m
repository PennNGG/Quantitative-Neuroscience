function mat_ = grid2mat(grid, ns, rows, cols)
% function mat_ = grid2mat(grid, ns, rows, cols)
%
% grid is assumed to be 
mat_ = zeros(sum(~isnan(grid(:))), 4);

ind = 1;
for rr = 1:length(rows)
    for cc = 1:length(cols)
        if ~isnan(grid(rr, cc))
            mat_(ind, :) = [cols(cc) rows(rr) grid(rr, cc) ns(rr, cc)];
            ind = ind+1;
        end
    end
end
