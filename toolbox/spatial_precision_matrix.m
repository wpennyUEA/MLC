function [Lambda,C,D] = spatial_precision_matrix (sel_locations)
% Compute spatial precision matrix
% FORMAT [Lambda,C,D] = spatial_precision_matrix (sel_locations)
%
% Lambda    spatial_precision_matrix
% C         covariance matrix
% D         distance matrix

d = size(sel_locations,1);

for i = 1:d
    for k = 1:d
        e = sel_locations(i,:)-sel_locations(k,:);
        
        % L2 norm
        D(i,k) = sqrt(e*e');

        % L1 norm
        %D(i,k) = mean(abs(e));

        C(i,k) = exp(-D(i,k));
        %Lambda(i,k) = exp(D(i,k));
    end
end

Lambda = inv(C);
