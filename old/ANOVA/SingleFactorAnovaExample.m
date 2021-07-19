function AnovaCode1
%some sample data to practice calculating some values critical for ANOVA
%testing

%Here are the results from a group of NGG students randomly assigned
% to 4 different neuroenhancers groups and asked to take an IQ test. the
% NaN means there isn't any data..Importantly, you can do an ANOVA with
% different numbers of data point in each group. Obviously, equal numbers
% are better and more is better but that won't limit you.

NGG=[60.8 68.7 102.6 87.9;  %columns are the 4 different neuroenhancers
     57 67.7 102.1 84.2;    %rows are data
     65 74 100.2 83.1;      %NaN means there isn't a data point
     58.6 66.3 96.5 85.7;
     61.7 69.8 NaN 90.4];
 
 k=size(NGG,2); %number of columns or the number of experimental groups
 
 n(1:k)=sum(~isnan(NGG(:,1:k))); 
 
 N=sum(sum(~isnan(NGG))); %search matrix to find where there are not NaN [not a number] 
                         %return logical index [1 or 0] if there isn't a
                         %NaN and then add up the indices in the
                         %matrix..need to do double sum because it is a 2-d
                         %matrix
                         %
                         %else you could have added up each element in n
                         
  Xij(1:k)=nansum(NGG(:,1:k)); %matlab thing. need 'nansum' to add values that have NaN
  
  meanX(1:k)=nanmean(NGG(:,1:k)); %same thing..need 'nanmean'
  
  sumXij2_div_by_n(1:k)=Xij(1:k).^2./n(1:k); %take each Xij, square it, and divide by the number of observations in the group
  
  sum_of_sumXij2_div_by_n=sum(sumXij2_div_by_n); %take the sum of what you just calculated for each group
  
  totalDF=N-1;
  groupDF=k-1;
  errorDF=N-k;
  
  sumXij =nansum(nansum(NGG)); %just add up all the values
  sumXij2=nansum(nansum(NGG.^2)); %square each value and add it up
  
  C=sumXij^2/N;
  
  totalSS=sumXij2-C; %total sum of squares
  groupSS=sum_of_sumXij2_div_by_n-C; %group sum of squares
  
  errorSS=totalSS-groupSS;
  
  groupMS=groupSS/groupDF;
  errorMS=errorSS/errorDF;
  
  F=groupMS/errorMS;
  
  p=fpval(F,groupDF,errorDF);
  
  disp(['Reject H0: p = ' num2str(p)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = fpval(x,df1,df2)
%FPVAL F distribution p-value function.
%   P = FPVAL(X,V1,V2) returns the upper tail of the F cumulative distribution
%   function with V1 and V2 degrees of freedom at the values in X.  If X is
%   the observed value of an F test statistic, then P is its p-value.
%
%   The size of P is the common size of the input arguments.  A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   See also FCDF, FINV.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.

%   Copyright 2010 The MathWorks, Inc. 


if nargin < 3, 
    error(messYearsExperience('stats:fpval:TooFewInputs')); 
end

xunder = 1./max(0,x);
xunder(isnan(x)) = NaN;
p = fcdf(xunder,df2,df1);
end



