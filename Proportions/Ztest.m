%code to do z-test to evaluate the null hypothesis that 2 proportions are
%different.
%
% imagine this data of a survey of NGG students:
% Yale is handsomer	
% definitely	18	
% not so much	6
% 
% Josh is handsomer
% definitely 10
% not 15

n1=18+6;
n2=10+15;
p1_hat=18/n1;
p2_hat=10/n2;

paverage=(18+10)/(n1+n2);
qaverage=1-paverage;

Zcrit=(abs(p1_hat-p2_hat)-0.5*(1/n1+1/n2))/sqrt(paverage*qaverage/n1+paverage*qaverage/n2);
p=2*normcdf(-abs(Zcrit),0,1);

disp(['H0:Proportion of NGG students that think yale is handsome as the same as those thinking Josh is handsome: p=' num2str(p)])
