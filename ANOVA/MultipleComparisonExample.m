function AnovaCode2

%some test code to do an ANOVA [like we just did {see AnovaCode1.m}] and
%then some post-hoc multiple comparisons.

%let's assume that you have presented k different auditory stimuli to a
%neuron in the auditory cortex and recorded the firing to 5 repeititions of
%each stimulus. Calculate the ANOVA to test the null and then do Tukey
%tests

FiringRate=[28.2 39.6 46.3 41 56.3;
            33.2 40.8 42.1 44.1 54.1;
            36.4 37.9 43.5 46.4 59.4;
            34.6 37.1 48.8 40.2 62.7
            29.1 43.6 43.7 38.6 60
            31 42.4 40.1 36.3 57.3];
          
k=size(FiringRate,2); %number of columns or the number of experimental groups
 
 n(1:k)=sum(~isnan(FiringRate(:,1:k))); 
 
 N=sum(sum(~isnan(FiringRate))); %search matrix to find where there are not NaN [not a number] 
                         %return logical index [1 or 0] if there isn't a
                         %NaN and then add up the indices in the
                         %matrix..need to do double sum because it is a 2-d
                         %matrix
                         %
                         %else you could have added up each element in n
                         
  Xij(1:k)=nansum(FiringRate(:,1:k)); %matlab thing. need 'nansum' to add values that have NaN
  
  meanX(1:k)=nanmean(FiringRate(:,1:k)); %same thing..need 'nanmean'
  
  sumXij2_div_by_n(1:k)=Xij(1:k).^2./n(1:k); %take each Xij, square it, and divide by the number of observations in the group
  
  sum_of_sumXij2_div_by_n=sum(sumXij2_div_by_n); %take the sum of what you just calculated for each group
  
  totalDF=N-1;
  groupDF=k-1;
  errorDF=N-k;
  
  sumXij =nansum(nansum(FiringRate)); %just add up all the values
  sumXij2=nansum(nansum(FiringRate.^2)); %square each value and add it up
  
  C=sumXij^2/N;
  
  totalSS=sumXij2-C; %total sum of squares
  groupSS=sum_of_sumXij2_div_by_n-C; %group sum of squares
  
  errorSS=totalSS-groupSS;
  
  groupMS=groupSS/groupDF;
  errorMS=errorSS/errorDF;
  
  F=groupMS/errorMS;
  
  p=fpval(F,groupDF,errorDF);
  
  disp(['Reject H0: p = ' num2str(p)])
  
  %now do Scheffe...note, you would only do Scheffe is the initial null
  %hypothesis of the ANOVA is accepted
  %
  % First calculate the critical S value: 
    Scrit = sqrt((k-1)*finv(1-0.05,k-1,N-k));
  
  % we want to see if mean_j - mean_i =0 for all groups
  % plot as a pretty table
 
  
  Combos=combnk([1:1:k],2); %find all combination..matlab trick
  for (i=1:length(Combos)) % do pairwise testing all over all combos
    MeanDiff = abs(nanmean(FiringRate(:,Combos(i,1))-nanmean(FiringRate(:,Combos(i,2)))));
    if (MeanDiff > Scrit)
      disp(['Reject H0: mu(' num2str(Combos(i,1)) ')-mu(' num2str(Combos(i,2)) '):'])
    else
      disp(['Accept H0: mu(' num2str(Combos(i,1)) ')-mu(' num2str(Combos(i,2)) '):'])   
    end
  end
  
  
  
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


