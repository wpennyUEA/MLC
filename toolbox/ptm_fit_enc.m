function [ptm]  = ptm_fit_enc (X)
% Convert cell-based data matrix into trajectory based data matrix
% FORMAT [ptm]  = ptm_fit_enc (X)
%
% INPUTS:
% X{i,c}    is a [d_S x d_T] matrix of data
%           from subject i, condition c
%           .rem_sub_effects 1 to remove subject effects (default is 0)
%
% OUTPUTS:
% ptm       
%           .Y      [d x N] trajectory data matrix
%           .D      [M x N] design matrix with M experimental conditions
%           .dS     number of sensors
%           .dT     number of time points
%

[NS,NC] = size(X);
[dS,dT] = size(X{1,1});
d = dS*dT;

N = NS*NC;
M = size(X,2);

% Assumes n has inner loop over trials/subjects and outer loop over conditions
Y=zeros(d,N);
D = zeros(M,N);
n = 1;
for c=1:NC
    Yalt{c} = zeros(d,NS);
    for i=1:NS
        Y(:,n) = X{i,c}(:);
        D(c,n) = 1;
        n = n+1;
    end
end

% Get Factor labels from conditions labels
svm_label{1} = D(1,:)+D(2,:)+2*(D(3,:)+D(4,:)); 
svm_label{2} = D(1,:)+D(3,:)+2*(D(2,:)+D(4,:)); 
ptm.svm_label = svm_label;

% Create output data structure
ptm.D = D;
ptm.grand_mean = mean(Y,2);
ptm.Y  = Y;
ptm.dS = dS;
ptm.dT = dT;
ptm.d = d;



