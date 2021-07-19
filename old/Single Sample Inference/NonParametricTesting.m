% Non-parametric testing
%
% To use this tutorial, read the commands and execute the code line-by-line.
%
% Copyright 2019 by Yale E. Cohen, University of Pennsylvania

% Let's set up a toy problem:
%   
NoSleep = [181 183 170 173 174 179 172 175 178 176 158 179 180 172 177]';

%we need to create a vector of the same length with the values to be tested
%by null hypothesis.
M=ones(size(NoSleep))*180; 

% Note his is just to set up code for a one-sample test. If you were doing 
%  a 2-sample test, then replace M with the data from your other population.
%  For example, maybe the IQ values of NGG students when
                                             % they had lots of sleep. The
                                             % code would be exactly the
                                             % same except with the
                                             % replacement of the M vector
                                             %
                                             % Note: if this is a 2 sample
                                             % test, the number of
                                             % observations could be
                                             % different. Here, they are
                                             % the same
                                             %
                                             % Also, the choice of 180 is
                                             % arbitrary and just what we
                                             % are testing for this
                                             % exercise.


%number in each
nNoSleep= numel(NoSleep);
nM = numel(M);
ns = min(nNoSleep,nM);

%sort and rank values
[ranks, tieadj] = tiedrank([NoSleep; M]);
srank = ranks(1:ns);
w = sum(srank);

%two-tail
wmean = ns*(nNoSleep + nM + 1)/2;
tiescor = 2 * tieadj / ((nNoSleep+nM) * (nNoSleep+nM-1));
wvar  = nNoSleep*nM*((nNoSleep + nM + 1) - tiescor)/12;
wc = w - wmean;
z = (wc - 0.5 * sign(wc))/sqrt(wvar);
p = 2*normcdf(-abs(z));
disp(['Probability of rejecting null hypothesis that the median IQ value is not equal to 180  p =' num2str(p)]); 

% a right-tail test
z = (wc - 0.5)/sqrt(wvar);
p = normcdf(-z);
disp(['Probability of rejecting null hypothesis that the median IQ value is greater than 180  p =' num2str(p)]); 

%a left-tail
z = (wc + 0.5)/sqrt(wvar);
p = normcdf(z);
disp(['Probability of rejecting null hypothesis that the median IQ value is less than 180  p =' num2str(p)]); 

disp([' ']);disp([' ']);
disp(['SIGN TEST--with categorical data'])

%Imagine, that on the NGG website, it is stated that 50% of NGG students believe that "Josh is the cat's meow". 
%However, you just don't believe that can be possibly true. So, you conduct
%a survey of 100 current/past NGG students and find that 67 think he is the
%cat's meow. Is this proportion greater than what the website claims?

%remember the sign test looks at the number of positive and negative values
%of the populations or test value. Here, we just need to calculate this for
%the 50% versus the 67%. Essentially, there are the 33 people who think
%that Josh isn't the cats meow.
NumNegative=33;
NumPositive=67; %100-33
n=100;

%two tail:
sgn = min(NumNegative,NumPositive);
p = min(1, 2*binocdf(sgn,n,0.5)); 
disp(['Probability of rejecting null hypothesis that proportion of NGG students thinking Josh is the cat''s meow is 0.5: p=' num2str(p)]);

%right tail
p = binocdf(NumNegative, n, 0.5);
disp(['Probability of rejecting null hypothesis that proportion of NGG students thinking Josh is the cat''s meow is >=0.5: p=' num2str(p)]);

%keft tail
p = binocdf(NumPositive, n, 0.5);
disp(['Probability of rejecting null hypothesis that proportion of NGG students thinking Josh is the cat''s meow is <=0.5: p=' num2str(p)]);
