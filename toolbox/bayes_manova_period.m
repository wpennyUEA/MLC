function [logbf, Psi_offdiag] = bayes_manova_period (man)

d = man.d;
dS = man.dS;
D = man.D;
Y = man.Y;
samples = man.samples;

% [N x r] IV data matrix
Xmat = D';

options.s0 = man.s0;

for k = 1:length(samples)
    i = samples(k);

    C = ptm_contrast_time(d,dS,i);

    % [N x d] DV data matrix
    Ymat = (C'*Y)';

    num_sensors = size(Ymat,2);

    % Normalise each observed variable (over all conditions)
    % to have zero mean and unit variance
    % Ymat = zmuv(Ymat);

    % Assume 2-by-2 design for now *************
    Nobs = size(Xmat,1);
    X0 = ones(Nobs,1);
    model(1).X = [Xmat*[1 1 -1 -1]',X0];
    model(2).X = [Xmat*[1 -1 1 -1]',X0];
    model(3).X = [Xmat*[1 -1 -1 1]',X0];

    mlm_null = mlm_nw (Ymat,X0,options);
    % Test for main effects and interactions
    for test = 1:3
        mlm = mlm_nw (Ymat,model(test).X,options);
        logbf(k,test) = mlm.logev-mlm_null.logev;

        Psi_total = 0.5*mlm.alpha_n*(mlm_null.logdetPsi_n - mlm.logdetPsi_n);

        Dnull = diag(diag(mlm_null.Psi_n));
        Dalt = diag(diag(mlm.Psi_n));
        Psi_diag = 0.5*mlm.alpha_n*(spm_logdet(Dnull) - spm_logdet(Dalt));
        Psi_offdiag(k,test) = Psi_total-Psi_diag;
        
    end

end