function CorrelationFun()
close all
%first the data, dipole moment and volume
DipoleMoment=[10.4 10.8 11.1 10.2 10.3 10.2 10.7 10.5 10.8 11.2 10.6 11.4];
Volume=[7.4 7.6 7.9 7.2 7.4 7.1 7.4 7.2 7.8 7.7 7.8 8.3];

n=length(DipoleMoment); %alternatively, you can calculate n=length(Volume)
SumX=sum(DipoleMoment); %sum up all X values
SumX2=sum(DipoleMoment.^2);  %the sum of each X squared
Sumx2=SumX2-SumX^2/n; %the sum of the square of the difference between (each X and mean X);

SumY=sum(Volume); %sum up all Y values
MeanY=mean(Volume); %find the mean Y value
SumXY=sum(DipoleMoment.*Volume); %the sum of the product of each X and Y values
Sumxy=SumXY-SumX*SumY/n; %the sum of the product of the difference between each X value minus the
SumY2=sum(Volume.^2); %the sum of each Y squared
Sumy2=SumY2-SumY^2/n;

r=Sumxy/sqrt(Sumx2*Sumy2);
disp(['r = ' num2str(r)]);

%Is this a significant correlation value
sr=sqrt((1-r^2)/(n-2));
disp(['standard error of r = ' num2str(sr)]);
Tval=r/sr;

prob = 1-tcdf(Tval,n-2); %n-2 is the degrees of freedom
disp(['p of H0:r=0 is ' num2str(prob)])

%is this r value different than r=0.75 
zm=0.5*log((1+r)/(1-r));
zr=0.5*log((1+0.75)/(1-0.75));
Z=(zm-zr)/sqrt(1/(n-3));
prob = 1-tcdf(Z/2,inf);
disp(['p of H0:r=0.75 is ' num2str(prob)])


%estimate power: That is, p(reject H0|H1 is true)
v=n-2;
zm=0.5*log((1+r)/(1-r));

tcrit=tinv(1-0.05/2,n-2);
rcrit=sqrt(tcrit^2/(tcrit^2+(n-2)));
zr=0.5*log((1+rcrit)/(1-rcrit));

Zb=(zm-zr)*sqrt(n-3);
power=normcdf(Zb);
disp(['The power of the test of H0:r=0 is ' num2str(power)])




%calculate the n needed to ensure that H0 (r=0) is rejected 99% of the time
%when |r|>= 0.5 at a 0.05 level of significance
Often = 0.01; %we want to reject H0 (1-often)% of the time [here, 99%]
rho=0.5; % when r >=0.5
AlphaValue=0.05; % and the hypothesis is tested at AlphaValue of significance
Zb=tinv(1-Often,inf);
Za=tinv(1-AlphaValue/2,inf);
zeta=0.5*log((1+rho)/(1-rho));
SampleSize=round(((Zb+Za)/zeta)^2+3);
disp(['To reject H0:r=0 99% of the time, when r=0.5 and alpha=0.05, we need n>=' num2str(SampleSize)])

