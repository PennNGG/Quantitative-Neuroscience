function p_ = quickPS2_val(cohs, times, r, beta, lambda, c0)% function p_ = quickPS2_val(cohs, times, r, beta, lambda, c0)%%   Computes a Quick (Weibull) function derived explicitly% Assuming probability summation (PS) over time on a constant% stimulus (coherence). In this model, the "vector magnitude"% ||R|| described by Quick (1974) is a temporal integral of the% "response" (r) of one channel, which implies that the% threshold (alpha), which is just ||R||^-1, becomes% alpha = 1/(r*time^(1/beta))%% lambda is the lapse rate. Assumes a guess rate (gamma) of 0.5p_ = 0.5 + (0.5 - lambda) * (1 - exp( -times.*((cohs-c0).*r).^beta));