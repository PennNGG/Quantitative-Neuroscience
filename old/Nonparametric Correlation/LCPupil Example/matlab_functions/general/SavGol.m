function [NamesCoefs, NamesTerms, XPow, YPow, SG] = SavGol(nOrder,nSize)
% Compute Savitzky-Golay coefficients
% John Krumm, Microsoft Research, August 2001
% Requires MatLabSymbolic Math Toolbox
% On return:
% NamesCoefs(i,:) gives the name of coefficient i, e.g. a23
% NamesTerms(i,:) gives the name of the polynomial term i, e.g. (x^2)(y^3)
% XPow(i) and YPow(i) give exponents on x and y for coefficient i
% SG(:,:,i) gives the nSize x nSize filter for computing coefficient i

% Set up polynomial terms for a given order
Terms = [];
NamesCoefs = [];
NamesTerms = [];
XPow = [];
YPow = [];
syms x y real;
for j=0:nOrder
    for i=0:nOrder-j
        % NamesTerms and NamesCoefs each must have strings all the same length
        % Each string in NamesCoefs is 3 characters long
        % Each string in NamesTerms is 10 characters long
        % There will be a problem if nOrder >= 10
        NamesCoefs = [NamesCoefs; sprintf('a%1d%1d',i,j)]; % must all be same length
        if (i>0 & j>0)
            NamesTerms = [NamesTerms; sprintf('(x^%d)(y^%d)',i,j)];
        end
        if (i>0 & j==0)
            NamesTerms = [NamesTerms; sprintf('(x^%d) ',i)];
        end
        if (i==0 & j>0)
            NamesTerms = [NamesTerms; sprintf('(y^%d) ',j)];
        end
        if (i==0 & j==0)
        NamesTerms = [NamesTerms; sprintf('1 ')];
        end
        Terms = [Terms; (x^i)*(y^j)];
        XPow = [XPow; i];
        YPow = [YPow; j];
    end
end

% Compute A matrix for a nSize x nSize window
A = [];
for y = -(nSize-1)/2:(nSize-1)/2 % important to loop through in same scan order as image patch pixels
    for x = -(nSize-1)/2:(nSize-1)/2
        %sprintf ('%f %f',x,y)
        A = [A; subs(Terms')];
    end
end

% Compute coefficient matrix
C = inv(A'*A)*A';

% Pull out coefficients
SG = [];
[nTerms, nDum] = size(Terms);
for i=1:nTerms
    SG(:,:,i) = reshape(C(i,:),[nSize,nSize]);
end

% Print
%for i=1:nTerms
%     NamesCoefs(i,:)
%     NamesTerms(i,:)
%     SG(:,:,i)
%end

 