% Chi-square test
%
% The chi-square test is used when you have discrete outcomes and want to
% test inferences about proportions of characteristics in the population.
% This test is useful when the sample size is relatively large.
%
% Copyright 2019 by Yale E. Cohen
%   updated 4/25/21 by jig


%this code tests whether the proportion of handsome Yale neurons exceeds
%the false-positive rate of 5% (alpha=0.05)
%
%We will test this as a function of the overall proportion of neurons and
%as a function of the number of neurons.
%
%

N = (10:10:1000);           % number of tested neurons
Proportion = (70:0.5:100);  % proportion of significant handsome neurons
df=1;

for i=1:length(N)
  for j=1:length(Proportion)
    HandsomeYale=Proportion(j)/100*N(i); %i know you can't have fractions of neurons but we will do this here just for fun
    NonHandsomeJosh=N(i)-HandsomeYale;
    TheoreticallyHandsome=.95*N(i);
    TheoreticallyNonHandsome=N(i)-TheoreticallyHandsome;
    
    ChiSquare=(HandsomeYale-TheoreticallyHandsome)/TheoreticallyHandsome+(NonHandsomeJosh-TheoreticallyNonHandsome)^2/TheoreticallyNonHandsome;   
    p(i,j)=1-chi2cdf(ChiSquare,df);
  end
    
end

h=figure(1);clf %plot out and make pretty
set(h,'position',[31 286 691 514])
for i=1:length(N)
  plot(Proportion,p(i,:),'-.-','markersize',15,'color', [1 1 1]/length(N)); hold on
  xlabel('Proportion of significant neurons','fontname','georgia','fontsize',12)
  ylabel('p','fontname','georgia','fontsize',12)
  title('P of finding sig pop of Handsome Yale as a function of neurons','fontname','georgia','fontsize',12)
  set(gca,'fontsize',12);%
end
text(85,.3,['N=' num2str(N(1))])
text(94.5,.25,['N=' num2str(N(end))])
plot([70 100],[0.05 0.05],'-','color',[1 0 0])


% h=figure(2);clf; %if you want to see how p changes with N as a functio of
% %proportion
% set(h,'position',[737 284 620 515])
% for j=1:length(Proportion)
%   plot(N,p(:,j),'--.','markersize',15,'color', [1 1 1]/length(N)); hold on
%   xlabel('Number of neurons')
%   ylabel('p')
% end

