function [res] = bayes_manova_time_series(ptm)
% Bayesian MANOVA at each time point
% FORMAT [res] = bayes_manova_time_series(ptm)
%
% ptm 
%
% res

tims = ptm.t;

% Subtract grand mean
N = size(ptm.Y,2);
Y = ptm.Y - ptm.grand_mean*ones(1,N);

man.d = ptm.d;
man.dS = ptm.dS;
man.D = ptm.D;
man.Y = Y;

%-------------------------------------------------------------------------
%  Calibration

ind = find (tims < 0);
man.samples = ind([1:4:length(ind)]);

man.s0 = 1;
max_val = -Inf;
step = 0.5;
its = 1; max_its = 16;
while its <= max_its
    logbf = bayes_manova_period (man);
    max_val = max(max(logbf));
    disp(sprintf('Calibrating: s0 = %1.4f, max_logBF = %1.2f',man.s0,max_val));
    if max_val < 0
        last_val = man.s0;
        man.s0 = (1-step)*man.s0;
    else
        step = step/2;
        man.s0 = (1-step)*last_val;
    end
    its = its+1;
end

man.s0 = last_val;

%-------------------------------------------------------------------------
% Run over whole time series

samples = ptm.samples;
man.samples = samples;
[res.logbf, res.Psi_OffDiag] = bayes_manova_period (man);

res.tims = tims;
res.samples = samples;
res.fname = ptm.fname;
res.s0 = man.s0;
