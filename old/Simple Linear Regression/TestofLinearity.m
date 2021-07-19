function TestofLinearity
%Non-neuroscience example to show how to linear regression

close all
%First, the data. These are the wing lengths of 13 birds at different ages
Age=[30 30 30 40 40 40 40 50 50 50 60 60 60 60 60 70 70 70 70 70]; %this is the X variable
Systolic=[108 110 106 125 120 118 119 132 137 134 148 151 146 147 144 162 156 164 158 159]; %this is the y variable

%let's plot out the data
h=figure(1); clf; hold on; set(h,'Position',[440 56 638 742]) %make pretty

subplot(2,1,1); hold on;
plot(Age,Systolic,'.','Markersize',35,'color',[.5 .5 .5]);
xlabel('Age (years)','fontname','Georgia','fontsize', 12);
ylabel('Systolic Blood Pressure (mm Hg)','fontname','Georgia','fontsize', 12);
set(gca,'fontname','Georgia','fontsize',12);% make pretty

%Let's calculate the slope and intercept of the regression line
%
% Calculate the slope first
% I am including easy ways to calculate the different vlaues
n=length(Age); %alternatively, you can calculate n=length(WingLength)
SumX=sum(Age); %sum up all X values
MeanX=mean(Age); %find the mean X value
SumX2=sum(Age.^2);  %the sum of each X squared
Sumx2=SumX2-SumX^2/n; %the sum of the square of the difference between (each X and mean X);

SumY=sum(Systolic); %sum up all Y values
MeanY=mean(Systolic); %find the mean Y value
SumXY=sum(Age.*Systolic); %the sum of the product of each X and Y values
Sumxy=SumXY-SumX*SumY/n;%the sum of the product of the difference between each X value minus the
SumY2=sum(Systolic.^2);%the sum of each Y squared
%mean X value and each Y value minus its mean

b=Sumxy/Sumx2; %the slope

%
% Now the intercept
a=MeanY-b*MeanX;

%now the regression line
Xline=[30 70];
Ypred=b*Xline+a;
plot(Xline,Ypred,'-','color',[0 0 0 ],'linewidth',4)
title(['Systolic_p_r_e_d = ' num2str(a) '+' num2str(b) 'Age'])


%let's test for linearity
amonggroupsSS=0; %the squared sum of each Y value as a functio of each unique X value, divided by the number of measurements - total sum squared divided by total number of observations
UniqueAges=unique(Age);
for(i=1:length (UniqueAges))
  foo=find(Age==UniqueAges(i));
    temp=0;
    for(j=1:length(foo))
      temp=temp+Systolic(foo(j));
    end
    amonggroupsSS=amonggroupsSS+temp^2/length(foo); %as a function of each observation (year; X), sum of Y values divided by number of observations
end
amonggroupsSS=amonggroupsSS-sum(Systolic)^2/length(Systolic); %subtract off the total sum of Y squared divided by total number of Y observations
amonggroupsDF=length(unique(Age))-1; %number of observation ages -1
totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
withingroupsSS=totalSS-amonggroupsSS;
withingroupsDF= length(Systolic)-1-amonggroupsDF;   %total DF - among groups DF
regressionSS=Sumxy^2/Sumx2;
deviationsfromlinearitySS=amonggroupsSS-regressionSS;
deviationsfromlinearityDF=amonggroupsDF-1;
MSdeviationlinearity=deviationsfromlinearitySS/deviationsfromlinearityDF;
MSwithingroups=withingroupsSS/withingroupsDF;
F=MSdeviationlinearity/MSwithingroups;
prob=fpval(F,1,n-2);
text(32,160,['Probability of rejecting H0:regression is linear: ' num2str(prob)],'fontname','Georgia','fontsize',12)

%let's test the null hypothesis that b (slope)=0;
df=n-2; %degrees of freedom
residualSS=totalSS-regressionSS;
Fstat=regressionSS/(residualSS/df);
prob=fpval(Fstat,1,n-2); % significance probability for regression
text(32,155,['(Fstat based) p of H0:b=0 is ' num2str(prob)],'fontname','Georgia','fontsize',12)

%let's calculate r2 (coefficient of determination)
r2=regressionSS/totalSS;
text(32,150,['r^2 = ' num2str(r2) ],'fontname','Georgia','fontsize',12)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     let's look at a situation when H0 is rejected for linearity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Systolic=[108 110 106 125 120 118 119 132 137 134 128 121 126 127 124 102 106 104 108 109]; %this is the y variable


%let's plot out the data
subplot(2,1,2); hold on;
plot(Age,Systolic,'.','Markersize',35,'color',[.5 .5 .5]);
xlabel('Age (years)','fontname','Georgia','fontsize', 12);
ylabel('Systolic Blood Pressure (mm Hg)','fontname','Georgia','fontsize', 12);
set(gca,'fontname','Georgia','fontsize',12);% make pretty

%Let's calculate the slope and intercept of the regression line
%
% Calculate the slope first
% I am including easy ways to calculate the different vlaues
n=length(Age); %alternatively, you can calculate n=length(WingLength)
SumX=sum(Age); %sum up all X values
MeanX=mean(Age); %find the mean X value
SumX2=sum(Age.^2);  %the sum of each X squared
Sumx2=SumX2-SumX^2/n; %the sum of the square of the difference between (each X and mean X);

SumY=sum(Systolic); %sum up all Y values
MeanY=mean(Systolic); %find the mean Y value
SumXY=sum(Age.*Systolic); %the sum of the product of each X and Y values
Sumxy=SumXY-SumX*SumY/n;%the sum of the product of the difference between each X value minus the
SumY2=sum(Systolic.^2);%the sum of each Y squared
%mean X value and each Y value minus its mean

b=Sumxy/Sumx2; %the slope

%
% Now the intercept
a=MeanY-b*MeanX;

%now the regression line
Xline=[30 70];
Ypred=b*Xline+a;
plot(Xline,Ypred,'-','color',[0 0 0 ],'linewidth',4)
title(['Systolic_p_r_e_d = ' num2str(a) '+' num2str(b) 'Age'])


%let's test for linearity
amonggroupsSS=0; %the squared sum of each Y value as a functio of each unique X value, divided by the number of measurements - total sum squared divided by total number of observations
UniqueAges=unique(Age);
for(i=1:length (UniqueAges))
  foo=find(Age==UniqueAges(i));
    temp=0;
    for(j=1:length(foo))
      temp=temp+Systolic(foo(j));
    end
    amonggroupsSS=amonggroupsSS+temp^2/length(foo); %as a function of each observation (year; X), sum of Y values divided by number of observations
end
amonggroupsSS=amonggroupsSS-sum(Systolic)^2/length(Systolic); %subtract off the total sum of Y squared divided by total number of Y observations
amonggroupsDF=length(unique(Age))-1; %number of observation ages -1
totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
withingroupsSS=totalSS-amonggroupsSS;
withingroupsDF= length(Systolic)-1-amonggroupsDF;   %total DF - among groups DF
regressionSS=Sumxy^2/Sumx2;
deviationsfromlinearitySS=amonggroupsSS-regressionSS;
deviationsfromlinearityDF=amonggroupsDF-1;
MSdeviationlinearity=deviationsfromlinearitySS/deviationsfromlinearityDF;
MSwithingroups=withingroupsSS/withingroupsDF;
F=MSdeviationlinearity/MSwithingroups;
prob=fpval(F,1,n-2);
text(32,135,['Probability of rejecting H0:regression is linear: ' num2str(prob)],'fontname','Georgia','fontsize',12)

%let's test the null hypothesis that b (slope)=0;
df=n-2; %degrees of freedom
residualSS=totalSS-regressionSS;
Fstat=regressionSS/(residualSS/df);
prob=fpval(Fstat,1,n-2); % significance probability for regression
text(32,133,['(Fstat based) p of H0:b=0 is ' num2str(prob)],'fontname','Georgia','fontsize',12)

%let's calculate r2 (coefficient of determination)
r2=regressionSS/totalSS;
text(32,130,['r^2 = ' num2str(r2) ],'fontname','Georgia','fontsize',12)


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
    error(message('stats:fpval:TooFewInputs')); 
end

xunder = 1./max(0,x);
xunder(isnan(x)) = NaN;
p = fcdf(xunder,df2,df1);
end


