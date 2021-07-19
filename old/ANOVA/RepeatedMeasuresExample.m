function AnovaCode4
%some sample data to practice calculating some values critical for ANOVA
%testing for a repeated measures ANOVA

%Here are the results from a group of NGG students who each took each of
%the 3 neuroenhancers and then took an IQ test.
%each row of the data set is an IQ value for each of 7 NGG students and
%columns is the IQ value as a function of neuroenhancer
%

NGG=[164 152 178;
    202 181 222 ;
    143 136 132 ;
    210 194 216 ;
    228 219 245 ;
    173 159 182 ;
    161 157 165 ];

i=size(NGG,2); %number of drugs
j=size(NGG,1); %number of students

Xij=sum(sum(NGG)); % add it all up
squaredXij=sum(sum(NGG.^2)); %add up squares

C=Xij^2/(i*j);

totalSS=squaredXij-C;

subjectsSS=0;
for n=1:j
  subjectsSS=sum(NGG(n,:))^2+subjectsSS; %could do this by hand but easier to this way b/c of the number of students
end
subjectsSS=subjectsSS/i-C;

withinsubjectsSS=totalSS-subjectsSS;

drugsSS=(sum(NGG(:,1))^2+sum(NGG(:,2))^2+sum(NGG(:,3))^2)/j-C;

remainderSS=withinsubjectsSS-drugsSS;


%let's calculate F and p values now...

%Sleep main effect
drugsMS=drugsSS/(i-1);
remainderMS=remainderSS/((i-1)*(j-1));
F=drugsMS/remainderMS;
p=fpval(F,i-1,(i-1)*(j-1));
disp(['Probability of rejecting H0: the mean IQ test is the same in all NGG students on all 3 drugs; p = ' num2str(p)])


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



