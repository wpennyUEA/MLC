function [mlm]  = mlm_nw (Y,X,options)
% Multivariate Linear Model with Normal-Wishart Prior
% FORMAT [mlm]  = mlm_nw (Y,X,options)
%
% Y             [N x M] matrix of dependent variables
% X             [N x K] matrix of indepenent variables
% options       .Psi_0  Prior over observation noise
%               .alpha_0 
%               .s0    V_0 = s0^2*eye(K)
%
% mlm   output data structure

[N,M] = size(Y);
[Nc,K] = size(X);
if ~(Nc==N)
    disp('Error in mlm_nw: Matrices X and Y have incompatible dimensions');
    return
end

try Psi_0 = options.Psi_0; catch Psi_0 = eye(M); end
try alpha_0 = options.alpha_0; catch alpha_0 = 1; end
try s0 = options.s0; catch s0 = 1; end

mlm = [];

%--------------------------------------------------------------------------
% Priors 
B_0 = zeros(K,M); % Prior mean
V_0 = s0^2*eye(K);

% Note that we need alpha_0 = M+2 or greater to have a well-defined prior

%--------------------------------------------------------------------------
% Parameters of Posteriors

B_hat = inv(X'*X)*X'*Y;
E_hat = Y - X*B_hat;
S = E_hat'*E_hat;

iV_0 = inv(V_0);
V_n = inv(iV_0 + X'*X);
B_n = V_n*(iV_0*B_0 + X'*Y);

B_e = B_hat-B_0;
Psi_n = Psi_0 + S + B_e'*V_n*B_e;

alpha_n = alpha_0 + N;

%--------------------------------------------------------------------------
% Model Evidence

terms(1) = 0.5*M*(spm_logdet(V_n)-spm_logdet(V_0));
logdetPsi_n = spm_logdet(Psi_n);
terms(2) = 0.5*alpha_0*spm_logdet(Psi_0) - 0.5*alpha_n*logdetPsi_n;
terms(3) = gammaln(0.5*alpha_n) - gammaln(0.5*alpha_0);
terms(4) = -0.5*M*N*log(pi);
logev = sum(terms);

%--------------------------------------------------------------------------
% Create output structure

mlm.logev = logev;
mlm.logev_terms = terms;

mlm.Psi_0 = Psi_0;
mlm.V_0 = V_0;
mlm.alpha_n = alpha_n;
mlm.Psi_n = Psi_n;
mlm.V_n = V_n;
mlm.B_n = B_n;
mlm.B_hat = B_hat;

mlm.logdetPsi_n = logdetPsi_n;


