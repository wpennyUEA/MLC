function [C] = ptm_contrast_range (d,ds,tind)
% Make contrast for all temporal indices
% FORMAT [C] = ptm_contrast_range (d,ds,tind)
%
% d          trajectory dimension
% ds         number of sensors
% tind       [k x 1] vector of temporal indices
%
% C          [d x p] contrast matrix with p = k*ds

for i = 1:length(tind)
    t = tind(i);
    Ct = ptm_contrast_time(d,ds,t);
    if i == 1
        C = Ct;
    else
        C = [C,Ct];
    end
end
