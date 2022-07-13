function LinearRegressionExercises
%
% Answers to exercises found here: 
%  https://colab.research.google.com/drive/1woS2_MwJBU-LJuT5tlCrB2ve4jv8T3Xk?usp=sharing 
%
% Copyright 2019 by Yale E. Cohen, University of Pennsylvania
%  Updated 07/21/21 by jig

%% Exercise 1
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

% The data: wing lengths of 13 birds at different ages
age=[3 4 5 6 8 9 10 11 12 14 15 16 17]; % this is the X variable
wing_length=[1.4 1.5 2.2 2.4 3.1 3.2 3.2 3.9 4.1 4.7 4.5 5.2 5]; % this is the Y variable

% 1. Plot the relationship between Age and Wing Length.
figure
plot(age, wing_length, 'ko');
xlabel('Age (years)')
ylabel('Wing Length (cm)')

% 2. Calculate and plot the regression line.

% Calculate the slope first
n=length(age); % alternatively, you can calculate n=length(wing_length)
SumX=sum(age); % sum up all X values
MeanX=mean(age); % find the mean X value
SumX2=sum(age.^2);  % the sum of each X squared
Sumx2=SumX2-SumX^2/n; % the sum of the square of the difference between (each X and mean X);

SumY=sum(wing_length); % sum up all Y values
MeanY=mean(wing_length); % find the mean Y value
SumXY=sum(age.*wing_length); % the sum of the product of each X and Y values
Sumxy=SumXY-SumX*SumY/n; %the sum of the product of the difference between each X value minus the
SumY2=sum(wing_length.^2); %the sum of each Y squared

% SLOPE
b=Sumxy/Sumx2; 

% INTERCEPT
a=MeanY-b*MeanX;

% Check against built-in function (also can use fitlm)
coefs = polyfit(age, wing_length, 1);
fprintf('slope = %.2f (%.2f polyfit)\n', b, coefs(1))
fprintf('intercept = %.2f (%.2f polyfit)\n', a, coefs(2))

% Add the regression line to the plot
hold on;
xax = age([1 end]);
plot(xax, b*xax+a,'k-','linewidth',2)
title(sprintf('WingLength_p_r_e_d = %.2f + %.2f Age', a, b))

% Can you reject H0: b=0?

% Using an F-test
k = 2; % number of groups
ndf = k-1; % numerator degrees of freedom
ddf= n-k; % denominator degrees of freedom
totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
regressionSS=Sumxy^2/Sumx2;
residualSS=totalSS-regressionSS;
Fstat=regressionSS/(residualSS/ddf);
prob=1-fcdf(Fstat,ndf,ddf); % significance probability for regression
fprintf('p(Fstat) of H_0:b=0 = %e\n', prob)

% Using a t-test
sb=sqrt(residualSS/ddf/Sumx2); % sb is essentially the standard error of the regression slope
Tval=(b-0)/sb;
prob = 1-tcdf(Tval,ddf); % degrees of freedom is n-k
fprintf('p(Tstat) of H_0:b=0 = %e\n', prob)

% 4. Calculate and plot 95% confidence intervals on the slope of the
% regression
alpha = 0.05;
t=-1*tinv(alpha/2,ddf); % ddf is the degrees of freedom
b05=b-t*sb; % lower CI
b95=b+t*sb; % upper CI
a05=MeanY-b05*MeanX; %intercept for lower CI
a95=MeanY-b95*MeanX; %intercept for upper CI
plot(xax,b05*xax+a05, 'r--', 'linewidth', 2)
plot(xax,b95*xax+a95, 'r--', 'linewidth', 2)
text(4,4.2,'95% CI in red dashed lines','fontname','Georgia','fontsize',12)

% 5. Calculate r2 (coefficient of determination)
totalSS=SumY2-SumY^2/n;    %totalSS is essentially the sum of the square of the difference between (each y and mean Y);
regressionSS=Sumxy^2/Sumx2;
r2=regressionSS/totalSS;
fprintf('r^2=%.4f\n', r2)
 
% 6. Calculate Pearson's r
r = corr([age', wing_length']);
fprintf('r=%.4f, r^2=%.4f\n', r(2,1), r(2,1)^2)

% 7. Add some noise to the data and see how the regression changes. 
figure
NUM_STD = 4;
for nn = 1:NUM_STD % four noise levels
    
    % add Gaussian noise to the observations
    new_lengths = wing_length + max(0, normrnd(0, nn, size(wing_length, 1), size(wing_length, 2)));
    
    % Use fitlm, which returns lots of good stuff
    lm = fitlm(age, new_lengths);
    [p,~,~] = coefTest(lm);
    
    % Show it
    subplot(1, NUM_STD, nn); cla reset; hold on;
    plot(lm);
    xlabel('Age (years)');
    ylabel('Wing Length (cm)');
    title(sprintf('STD=%d, p=%.2f', nn, p))
    axis([0 20 0 12])
end

%% Exercise 2
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
