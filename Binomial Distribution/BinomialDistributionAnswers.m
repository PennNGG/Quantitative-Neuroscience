% Bionmial Distributions
% Answers to exercises
%
% Created 09/21/18 by Joshua I Gold

%% Exercise 1
n = 10;                       % number of available quanta
p = 0.2;                      % release probabilty 
k = 0:10;                     % possible values of k (measured events)
probs = binopdf(k,n,p)        % array of probabilities of obtaining those values

%% Exercise 2
n = 14;                       % number of available quanta
k = 8;                        % measured number of released quanta
prob1  = binopdf(k,n,0.1)     % probabilty of obtaining k if release p = 0.1
prob2  = binopdf(k,n,0.2)     % probabilty of obtaining k if release p = 0.2
prob3  = binopdf(k,n,0.3)     % probabilty of obtaining k if release p = 0.3
prob4  = binopdf(k,n,0.4)     % probabilty of obtaining k if release p = 0.4
prob5  = binopdf(k,n,0.5)     % probabilty of obtaining k if release p = 0.5
prob6  = binopdf(k,n,0.6)     % probabilty of obtaining k if release p = 0.6 ** MOST LIKELY
prob7  = binopdf(k,n,0.7)     % probabilty of obtaining k if release p = 0.7
prob8  = binopdf(k,n,0.8)     % probabilty of obtaining k if release p = 0.8
prob9  = binopdf(k,n,0.9)     % probabilty of obtaining k if release p = 0.9
prob10 = binopdf(k,n,1.0)     % probabilty of obtaining k if release p = 1.0

%% Exercise 3
n = 14+14;                    % number of available quanta
k = 8+5;                      % measured number of released quanta
prob1 = binopdf(k,n,0.1)      % probabilty if release p = 0.1
ps = 0:0.1:1.0;               % deciles of release probabilities
probs = binopdf(k,n,ps);      % array of probabilities of obtaining k for different ps
ps(probs==max(probs))         % find release probability with max likelihood

%% Exercise 4
measured_releases = [0	1	2	3	4	5	6	7	8	9	10	11	12	13	14];
counts = [0	0	3	10	19	26	16	16	5	5	0	0	0	0	0];
N = sum(counts);
ps = 0:0.1:1.0;               % deciles of release probabilities
probs = binopdf(sum(counts.*measured_releases),N*14,ps);      % array of probabilities of obtaining k for different ps
ps(probs==max(probs))         % find release probability with max likelihood

% use binofit
phat = binofit(sum(counts.*measured_releases),N*14)

%% Exercise 5
n = 14;                       % number of available quanta
k = 7;                        % measured number of released quanta
ps = 0:0.1:1.0;               % deciles of release probabilities
probs = binopdf(k,n,ps);      % array of probabilities of obtaining k for different ps
ps(probs==max(probs))         % find release probability with max likelihood
null_p = 0.3;                 % Null hypothesis p
prob = binopdf(k,n,null_p)    % p>0.05, so cannot rule out that we would have gotten this measurement by chance under the null hypothesis

%% Bonus exercise
% The data table
data = [ ...
   4.0 615 206 33 2 0 0; ...
   3.5 604 339 94 11 2 0; ...
   0.0 332 126 21 1 0 0; ...
   2.0 573 443 154 28 2 0; ...
   6.5 172 176 89 12 1 0; ...
   3.0 80 224 200 32 4 0];

xs = 0:5; % x-axis

% For each session
num_sessions = size(data, 1);
for ii = 1:num_sessions 
   
   % Compute relevant variables
   nx = data(ii,2:end); % the count data
   N  = sum(nx); % the total number of trials
   m  = sum(nx(2:end).*xs(2:end))/N;  % mean
   v  = sum((xs-m).^2.*nx)/N;  % variance
   p  = 1 - (v/m); % release probabilty
   n  = m/p; % available quanta per trial

   % Set up the plot
   subplot(1, num_sessions, ii); cla reset; hold on;
   bar(xs+0.5, nx./N, 'FaceColor', 'k');

   % Compute the binomial probabilities according to the equations at the
   % top of p. 762
   binomialCounts = zeros(size(xs));
   binomialCounts(1) = sum(nx).*(1-p).^n;   
   for jj = 2:length(binomialCounts)
       binomialCounts(jj) = binomialCounts(jj-1).*(m-p.*(jj-2))/((jj-1).*(1-p));
   end
   binomialCounts = round(binomialCounts);

   % Normalize for pdf and plot
   plot(xs+0.5, binomialCounts./sum(binomialCounts), 'ro-', 'MarkerFaceColor', 'r', 'LineWidth', 2);

   % If you want to compute Chi-2 goodness-of-fit,  k-1 degrees of freedom
   % A little bit of a cheat -- assume all bins contribute even when
   % binomialCounts=0 (because nx is always zero then, too)
   % pb = 1-chi2cdf(nansum((nx-binomialCounts).^2./binomialCounts), length(binomialCounts)-1);   

   % Get Possion pdf
   pps = poisspdf(xs, m);
   plot(xs+0.5, pps, 'bo-', 'MarkerFaceColor', 'b', 'LineWidth', 2);

   % If you want to compute Chi-2 goodness-of-fit, k-1 degrees of freedom
   % poissonCounts = round(pps.*N);
   % pp = 1-chi2cdf(nansum((nx-poissonCounts).^2./poissonCounts), length(poissonCounts)-1);

   % Show titles,labels, legend
   axis([0 5 0 1]);
   set(gca, 'FontSize', 12);
   h=title({sprintf('Temp=%.1f', data(ii,1)); sprintf('p=%.2f', p)});
   set(h, 'FontWeight', 'normal');
   if ii == 1
      xlabel('Number of Events')
      ylabel('Probability')
      legend('data', 'binomial', 'poisson');
   else
      set(gca, 'YTickLabel', '');
   end
end