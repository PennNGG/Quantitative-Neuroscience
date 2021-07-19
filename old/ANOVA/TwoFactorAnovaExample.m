function AnovaCode3
%some sample data to practice calculating some values critical for ANOVA
%testing for a TW0-FACTOR ANOVA

%Here are the results from a group of NGG students randomly assigned
% to 2 different neuroenhancers groups and asked to take an IQ test 
% as a function of sleep. the
%each row of the data set is an IQ value; columns are the 2 different
%neuroenhancers 
%
%Note, you could use the same procedure to calculate N different sleep
%levels and M different neuroenhancers but let's keep it simple with 2 of
%each

NoSleep=[16.5 14.5;
        18.4 11.0;
        12.7 10.8;
        14.0 14.3;
        12.8 10.0];
 
LotSleep=[39.1 32;
          26.2 23.8;
          21.3  28.8;
          35.8  25;
          40.2  29.3];

a= 2; %number of sleep levels
b= size(NoSleep,2); %number of neuroenhancer levels
n= size(LotSleep,1); %number of replicates [data points]
N=a*b*n;
 

Xabn=sum(sum(NoSleep));
Xabn=Xabn+sum(sum(LotSleep)); %add up all the values

squaredXabn=sum(sum(NoSleep.^2));
squaredXabn=squaredXabn+sum(sum(LotSleep.^2)); % add up all the squared values


%Total for no sleep, ind of neuroenhancer
TotalNoSleep=sum(sum(NoSleep));

%Total for lots of sleep, ind of neuroenhancer
TotalLotSleep=sum(sum(LotSleep));

%Total for neuroenhancer 1, ind of sleep
TotalNeuro1=sum(NoSleep(:,1))+sum(LotSleep(:,1));

%Total for neuroenhancer 2, ind of sleep
TotalNeuro2=sum(NoSleep(:,2))+sum(LotSleep(:,2));

C=Xabn^2/N;

totalSS=squaredXabn-C;
totalDF=N-1;

cellsSS=(sum(NoSleep(:,1))^2+sum(NoSleep(:,2))^2+sum(LotSleep(:,1))^2+sum(LotSleep(:,2))^2)/n-C;
cellsDF=a*b-1;

withincellsSS=totalSS-cellsSS;  %error SS

withincellsDF=a*b*(n-1);

SleepSS=(TotalNoSleep^2+TotalLotSleep^2)/(b*n)-C; %main effect 1 SS
SleepDF=a-1;

NeuroenhancerSS=(TotalNeuro1^2+TotalNeuro2^2)/(a*n)-C; %main effect 2 SS
NeuroenhancerDF=b-1;

SleepNeuroenhancerSS=cellsSS-SleepSS-NeuroenhancerSS; %interactionSS
SleepNeuroenhancerDF=SleepDF*NeuroenhancerDF;

%woo! I sm exhausted...let's calculate F and p values now...

%Sleep main effect
groupMS=SleepSS/SleepDF;
errorMS=withincellsSS/withincellsDF;
F=groupMS/errorMS;
p=fpval(F,SleepDF,withincellsDF);
disp(['Probability of rejecting H0: there is no effect of sleep on mean IQ test; p = ' num2str(p)])

%Neuroenhancer main effect
groupMS=NeuroenhancerSS/NeuroenhancerDF;
errorMS=withincellsSS/withincellsDF;
F=groupMS/errorMS;
p=fpval(F,NeuroenhancerDF,withincellsDF);
disp(['Probability of rejecting H0: there is no effect of neuroenhancer on mean IQ test; p = ' num2str(p)])

%SleepxNeuroenhancer main effect
groupMS=SleepNeuroenhancerSS/SleepNeuroenhancerDF;
errorMS=withincellsSS/withincellsDF;
F=groupMS/errorMS;
p=fpval(F,SleepNeuroenhancerDF,withincellsDF);
disp(['Probability of rejecting H0: there is no effect the interaction of sleep and neuroenhancer on mean IQ test; p = ' num2str(p)])



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



