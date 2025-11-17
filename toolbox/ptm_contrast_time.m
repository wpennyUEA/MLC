function [C] = ptm_contrast_time (d,ds,n)
% Make contrast for single time index n
% FORMAT [C] = ptm_contrast_time (d,ds,n)

C = zeros(d,ds);
start = (n-1)*ds+1;
stop = start+ds-1;
C(start:stop,1:ds) = eye(ds);