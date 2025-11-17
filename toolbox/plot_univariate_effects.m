function [Fcorr] = plot_univariate_effects (ptm,enc_res,options) 
% Create univariate sensor maps at times of largest effects
% FORMAT [Fcorr] = plot_univariate_effects (ptm,enc_res,options) 
%
% ptm           PTM data structure 
% enc_res       encoding results
%
% options
%               .enames        1 to plot electrode names, 0 to not

% Get times of strongest effects
for test = 1:3
    [tmp,ind(test)] = max(enc_res.logbf(:,test));
    t(test) = enc_res.tims(enc_res.samples(ind(test)))
end


for test = 1:3
    Fcorr{test} = plot_anova_map(ptm,t(test),test,options);
end

