% Sample analysis script for fitting data to a piecewise linear model and
% testing whether the model provides a better fit than a simple linear
% model
%
% Created 09/2017 by Joshua I Gold
% University of Pennsylvania

% Start with some data from the Nusbaum lab. 
data = [ ...
   38.0000   18.4466
   38.0000   17.9669
   29.0000   17.2414
   28.0000   16.1663
   24.0000   16.1399
   22.0000   15.5148
   20.0000   15.7480
   20.0000   15.2439
   10.0000   19.3424
    2.0000   43.4783
    4.0000   32.0000
    6.0000   20.2703
   43.0000   18.3997
   36.0000   17.8660
   29.0000   17.2516
   27.0000   16.2357
   24.0000   15.9893
   23.0000   16.1630
   22.0000   15.6139
   19.0000   14.7401
   16.0000   16.9851
    2.0000   35.7143
    5.0000   22.6244
   35.0000   17.9120
   38.0000   17.6909
   28.0000   17.2733
   26.0000   16.2703
   24.0000   15.6556
   22.0000   14.8448
   19.0000   15.2856
   18.0000   15.1643
   18.0000   14.1732
   14.0000   16.5680
    5.0000   22.5225
   39.0000   18.2328
   38.0000   18.7377
   29.0000   16.7824
   28.0000   17.7215
   23.0000   15.4674
   23.0000   15.3743
   19.0000   15.5865
   18.0000   15.7205
   17.0000   14.7186
    2.0000   30.7692
    2.0000   27.0270
    4.0000   25.4777
    6.0000   25.0000
   44.0000   18.0106
   37.0000   16.9027
   30.0000   16.1117
   25.0000   16.1603
   22.0000   15.6695
   20.0000   14.8810
   19.0000   14.8554
   18.0000   15.5844
   13.0000   15.5502
    2.0000   40.0000
    5.0000   26.4550
   41.0000   17.7489
   38.0000   17.2492
   29.0000   16.8311
   24.0000   16.2382
   22.0000   15.4603
   21.0000   15.4185
   18.0000   15.0502
   18.0000   14.9378
   16.0000   14.9254
   11.0000   17.6565
    2.0000   25.3165
    4.0000   22.2222
    8.0000   19.9005
   47.0000   17.5047
   37.0000   17.2414
   30.0000   16.4745
   26.0000   15.3392
   23.0000   15.2926
   19.0000   15.2733
   18.0000   15.1643
   17.0000   14.0148
   15.0000   15.0451
    5.0000   25.3807
    2.0000   31.7460
    5.0000   23.1481
   13.0000   21.3465
   47.0000   16.9065
   34.0000   16.8400
   28.0000   16.2791
   25.0000   14.9165
   21.0000   14.6444
   19.0000   14.9606
   18.0000   14.7905
   17.0000   13.7207
   14.0000   15.7658
    4.0000   20.3046
   11.0000   20.4082
   46.0000   16.7761
   35.0000   16.6587
   26.0000   15.2314
   25.0000   14.9790
   21.0000   14.4429
   19.0000   14.6718
   18.0000   14.1066
   17.0000   14.2498
   13.0000   15.6438
    3.0000   23.6220
    4.0000   27.3973
    9.0000   17.9283
   52.0000   17.3218
   38.0000   15.3102
   29.0000   15.1278
   25.0000   13.9978
   21.0000   15.0322
   19.0000   14.1897
   17.0000   14.1785
   15.0000   14.0713
    6.0000   19.6721
    2.0000   21.0526
    5.0000   19.2308
    8.0000   17.9775
   47.0000   15.8570
   38.0000   15.2733
   28.0000   14.3663
   24.0000   14.0023
   21.0000   14.8410
   18.0000   13.8355
   17.0000   14.0962
   16.0000   14.0105
   14.0000   13.7795];

% for convenience, make two separate vectors for x and y values
xs = data(:,1);
ys = data(:,2);

% Fit to the piecewise model. First we choose the function and set the
% lower and upper bounds on the parameters.. this can be a bit arbirary,
% here we're just picking big absolute values to avoid edge effects. The
% upper and lower bound vectors are arguments to fmincon and must be the
% same length as the parameter vector.
fun   = @linearPiecewise4;
lb    = [-1000 -1000 -1000 -1000]; 
ub    = [ 1000  1000  1000  1000];

% A critical part of fitting is to start with a good guess. Here we just
% divide the data in two and fit two lines, and use those as our initial
% guesses... that seems to work well with this data set, but may not always
% be the best procedure
L1    = xs<median(xs);
B1    = lscov([xs(L1) ones(sum(L1),1)], ys(L1));
B2    = lscov([xs(~L1) ones(sum(~L1),1)], ys(~L1));
inits = [B1(1) B1(2) B2(1) B2(2)];
    
% do the fit with the full model
[fitsFull,semsFull,SSEFull] = leastSquaresFit(ys, xs, fun, inits, lb, ub);

% now fit using the NULL model -- just a line. There are lots of ways in
% matlab to do this, here we use lscov. Note that we need to give it an 
% array of ones to fit to a two-parameter line.
A        = [xs ones(size(xs))];
fitsNull = lscov(A, ys);

% get sum-squqred error (SSE) of the fit
SSENull = sum((ys-A*fitsNull).^2);
        
% get some stats -- p<alpha means that we reject the Null (simpler) model
% according to the criterion set by alpha (often 0.05 or 0.01)
F   = ((SSENull-SSEFull)./(2))./(SSEFull./(length(xs)-2));
np1 = length(fitsFull);
np0 = length(fitsNull);
p   = 1-fcdf(F, np1-np0, length(xs)-np1);

% show some stuff
disp(sprintf('fits:'))
disp(fitsFull)
disp(sprintf('F=%.3f, p=%.3f', F, p))
    
% plot the data and the fits
figure
hold on
plot(xs, ys, 'ko');
xax = linspace(min(xs), max(xs), 500);
plot(xax, feval(fun, fitsFull, xax), 'k-');
set(gca, 'FontSize', 12);
xlabel('IC spikes/burst')
ylabel('IC intraburst firing frequency')
