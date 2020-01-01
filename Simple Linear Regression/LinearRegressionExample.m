function LinearRegressionExample
%Non-neuroscience example to show how to linear regression
close all

%First, the data. These are the wing lengths of 13 birds at different YearsExperiences
YearsExperience=[3 4 5 6 8 9 10 11 12 14 15 16 17]; %this is the X variable
Volume=[1.4 1.5 2.2 2.4 3.1 3.2 3.2 3.9 4.1 4.7 4.5 5.2 5]; %this is the Y variable


%Let's calculate the slope and intercept of the regression line
%
% Calculate the slope first
% I am including easy ways to calculate the different vlaues
n=length(YearsExperience); %alternatively, you can calculate n=length(Volume)
SumX=sum(YearsExperience); %sum up all X values
MeanX=mean(YearsExperience); %find the mean X value
SumX2=sum(YearsExperience.^2);  %the sum of each X squared
Sumx2=SumX2-SumX^2/n; %the sum of the square of the difference between (each X and mean X);

SumY=sum(Volume); %sum up all Y values
MeanY=mean(Volume); %find the mean Y value
SumXY=sum(YearsExperience.*Volume); %the sum of the product of each X and Y values
Sumxy=SumXY-SumX*SumY/n;%the sum of the product of the difference between each X value minus the
SumY2=sum(Volume.^2);%the sum of each Y squared
%mean X value and each Y value minus its mean

b=Sumxy/Sumx2; %the slope

%
% Now the intercept
a=MeanY-b*MeanX;


%let's plot out the data
figure(1); clf; hold on;
plot(YearsExperience,Volume,'.','Markersize',35,'color',[.5 .5 .5]);
xlabel('Experience (years)','fontname','Georgia','fontsize', 12);
ylabel('Volume (cm^3)','fontname','Georgia','fontsize', 12);
set(gca,'fontname','Georgia','fontsize',12);% make pretty

%now the regression line
Xline=[3 17];
Ypred=b*Xline+a;
plot(Xline,Ypred,'-','color',[0 0 0 ],'linewidth',4)

suptitle(['Volume_p_r_e_d = ' num2str(a) '+' num2str(b) 'YearsExperience'])

%let's test the null hypothesis that b (slope)=0;
df=n-2; %degrees of freedom
totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
regressionSS=Sumxy^2/Sumx2;
residualSS=totalSS-regressionSS;
Fstat=regressionSS/(residualSS/df);
prob=fpval(Fstat,1,n-2); % significance probability for regression
text(4,5,['(Fstat based) p of H0:b=0 is ' num2str(prob)],'fontname','Georgia','fontsize',12)

%let's use a t-test to test the null hypothesis that b=0
syx=sqrt((residualSS/df));
sb=sqrt(syx^2/Sumx2);%sb is essentially the standard error of the regression slope
Tval=(b-0)/sb;
prob = 1-tcdf(Tval,n-2); %n-2 is the degrees of freedom
text(4,4.8,['(Tstat based) p of H0:b=0 is ' num2str(prob)],'fontname','Georgia','fontsize',12)


%calculate 95% confidence intervals
t=-1*tinv(.05/2,n-2); %n-2 is the degrees of freedom
L1=b-t*sb; %lower CI
L2=b+t*sb; %upper CI
a1=MeanY-L1*MeanX; %intercept for lower CI
a2=MeanY-L2*MeanX; %intercept for upper CI
plot(Xline,L1*Xline+a1,'--','color',[.75 .75 .75 ],'linewidth',2)
plot(Xline,L2*Xline+a2,'--','color',[.75 .75 .75 ],'linewidth',2)
text(4,4.2,['95% CI in grey dashed lines'],'fontname','Georgia','fontsize',12)

%let's calculate r2 (coefficient of determination)
totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
regressionSS=Sumxy^2/Sumx2;
r2=regressionSS/totalSS;
text(4,4.5,['r^2=' num2str(r2)],'fontname','Georgia','fontsize',12)
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
% Let's repeat all of this but add 4 different levels of noise to see how
% things get affected

%First, the data. These are the wing lengths of 13 birds at different YearsExperiences
YearsExperience=[3 4 5 6 8 9 10 11 12 14 15 16 17]; %this is the X variable
Volume=[1.4 1.5 2.2 2.4 3.1 3.2 3.2 3.9 4.1 4.7 4.5 5.2 5]; %this is the y variable

h=figure(2); clf; hold on;
set(h,'position',[136 25 1197 780]);
maxY=[];
for i=1:4
    
    subplot(2,2,i); hold on; %just choose the plot    

    Volume=Volume +i*randn(1,length(Volume)); %add noise to data
    maxY(i)=max(Volume); %store max value to make axes the same
    
    %Let's calculate the slope and intercept of the regression line
    %
    % Calculate the slope first
    % I am including easy ways to calculate the different vlaues
    n=length(YearsExperience); %alternatively, you can calculate n=length(Volume)
    SumX=sum(YearsExperience); %sum up all X values
    MeanX=mean(YearsExperience); %find the mean X value
    SumX2=sum(YearsExperience.^2);  %the sum of each X squared
    Sumx2=SumX2-SumX^2/n; %the sum of the square of the difference between (each X and mean X);

    SumY=sum(Volume); %sum up all Y values
    MeanY=mean(Volume); %find the mean Y value
    SumXY=sum(YearsExperience.*Volume); %the sum of the product of each X and Y values
    Sumxy=SumXY-SumX*SumY/n;%the sum of the product of the difference between each X value minus the
    SumY2=sum(Volume.^2);%the sum of each Y squared
    %mean X value and each Y value minus its mean

    b=Sumxy/Sumx2; %the slope

    %
    % Now the intercept
    a=MeanY-b*MeanX;

    %let's plot out the data
    plot(YearsExperience,Volume,'.','Markersize',35,'color',[.5 .5 .5]);
    xlabel('Experience (years)','fontname','Georgia','fontsize', 12);
    ylabel('Volume','fontname','Georgia','fontsize', 12);
    set(gca,'fontname','Georgia','fontsize',12);% make pretty

    %now the regression line
    Xline=[3 17];
    Ypred=b*Xline+a;
    plot(Xline,Ypred,'-','color',[0 0 0 ],'linewidth',4)
    title(['Volume_p_r_e_d = ' num2str(a) '+' num2str(b) 'YearsExperience'])


    %let's calculate r2 (coefficient of determination)
    totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
    regressionSS=Sumxy^2/Sumx2;
    r2(i)=regressionSS/totalSS;
    

    %let's test the null hypothesis that b (slope)=0;
    df=n-2; %degrees of freedom
    residualSS=totalSS-regressionSS;
    Fstat=regressionSS/(residualSS/df);
    prob(i)=fpval(Fstat,1,n-2); % significance probability for regression

    
    %calculate 95% confidence intervals
    t=-1*tinv(.05/2,n-2); %n-2 is the degrees of freedom
    L1=b-t*sb; %lower CI
    L2=b+t*sb; %upper CI
    a1=MeanY-L1*MeanX; %intercept for lower CI
    a2=MeanY-L2*MeanX; %intercept for upper CI
    plot(Xline,L1*Xline+a1,'--','color',[.75 .75 .75 ],'linewidth',2)
    plot(Xline,L2*Xline+a2,'--','color',[.75 .75 .75 ],'linewidth',2)
end

for i =1:4
    subplot(2,2,i);
    axis([2 18 1 max(maxY)+0.5]); %make all axes the same
    text(4,max(maxY)+0.5-.5,['(Fstat based) p of H0:b=0 is ' num2str(prob(i))],'fontname','Georgia','fontsize',12)
    text(4,max(maxY)+0.5-1,['r^2= ' num2str(r2(i))],'fontname','Georgia','fontsize',12)
end

figure(2);suptitle('Regression effects with increasing noise')

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


