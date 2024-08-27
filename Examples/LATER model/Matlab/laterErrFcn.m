function err = laterErrFcn(fits) 

global reciprocalRTs


err = -sum(log(normpdf(reciprocalRTs, fits(1)/fits(2), 1/fits(2))));
