function [X,ms] = stm_scale_data (X)
% Scale data so that mean SD over all channels and conditions is 1
% FORMAT [X,ms] = stm_scale_data (X)

[S,C]=size(X);

scale_to = 1;

for i=1:S,
    sigma=[];
    for c=1:C
        s = std(X{i,c}');
        sigma = [sigma,s];
    end
    ms = mean(sigma);
    for c=1:C
        X{i,c} = scale_to*X{i,c}/ms;
    end
end


