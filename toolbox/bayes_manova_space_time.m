function [res] = bayes_manova_space_time (ptm,st_regions)
% Bayesian MANOVA over space-time region
% FORMAT [res] = bayes_manova_space_time (ptm,st_regions)
%
% ptm 
% st_regions{i}     definition of ith space-time region
%
% res               .logbf(i,j) is the log Bayes Factor
%                   in favour of the alternative for test j
%                   in space-time region i 
%                   j=1,2,3 for main 1, main 2, interaction resp.

tims = ptm.t;

% Subtract grand mean
N = size(ptm.Y,2);
Y = ptm.Y - ptm.grand_mean*ones(1,N);

%dt = ptm.temporal_resolution;
dt = 16;

% [N x r] IV data matrix
Xmat = ptm.D';
Nobs = size(Xmat,1);

options.s0 = ptm.s0; % Prior SD

R = length(st_regions);
for r = 1:R
    S = st_regions{r};
    ind = find(ptm.t >= S.times(1) & ptm.t <= S.times(2));
    tind = ind(1:dt:end);

    % Assume all electrodes for now
    C = ptm_contrast_range (ptm.d,ptm.dS,tind);

    % [N x d] DV data matrix
    Ymat = (C'*Y)';
    size(Ymat)

    % Assume 2-by-2 design for now *************
    X0 = ones(Nobs,1);
    model(1).X = [Xmat*[1 1 -1 -1]',X0];
    model(2).X = [Xmat*[1 -1 1 -1]',X0];
    model(3).X = [Xmat*[1 -1 -1 1]',X0];

    mlm_null = mlm_nw (Ymat,X0,options);
    % Test for main effects and interactions
    for test = 1:3
        mlm = mlm_nw (Ymat,model(test).X,options);
        logbf(r,test) = mlm.logev-mlm_null.logev;
    end
end

res.logbf = logbf;