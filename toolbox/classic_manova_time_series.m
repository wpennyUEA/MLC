function [res] = classic_manova_time_series(ptm)
% Bayesian MANOVA at each time point
% FORMAT [res] = classic_manova_time_series(ptm)
%
% ptm 
%
% res

tims = ptm.t;

Y = ptm.Y;
d = ptm.d;
dS = ptm.dS;

% Subtract grand mean
N = size(Y,2);
Y = Y - ptm.grand_mean*ones(1,N);

% [r x N] IV data matrix
D = ptm.D;

samples = ptm.samples;
for k = 1:length(samples)
    i = samples(k);

    C = ptm_contrast_time(d,dS,i);

    % [d x N] DV data matrix
    A = C'*Y;
    num_sensors = size(A,1);

    [Fval,pval] = classic_manova (D,A,num_sensors);
    for test = 1:3
        res.Fval(k,test) = Fval(test);
        res.pval(k,test) = pval(test);
    end
end
res.samples = samples;
res.tims = tims;
res.fname = ptm.fname;
