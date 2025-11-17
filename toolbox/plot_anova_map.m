function [Fcorr,F,pval] = plot_anova_map (ptm,t,test,options)
% Make ANOVA map at time t
% FORMAT [Fcorr,F,pval] = plot_anova_map (ptm,t,test,options)
%
% INPUTS:
% ptm       from ptm_fit_enc.m
% t         time point of interest (ms)
% test      test of interest (1,2,3 or main 1, main 2 or interaction)
% options   .alpha     FDR-corrected p-value (default 1 ie. no correction)
%           .plot_BH   1 to plot Benjamini-Hochberg (BH) curves
% 
% OUTPUTS:  
%
% F(:,i)        [dS x 1] vector of F scores for ith test
% pval(:,i)     [dS x 1] vector of p-values for ith test
% Fcorr(:,i)    [dS x 1] vector of F scores for ith test, but with entries
%               zeroed-out if p_FDR > alpha
%
%           i = 1: main effect of factor 1
%           i = 2: main effect of factor 2
%           i = 3: interaction 
%

try alpha = options.alpha; catch alpha = 1; end
try plot_BH = options.plot_BH; catch plot_BH=0; end

% Subtract grand mean before analysis
[tmp,N] = size(ptm.Y);
Y = ptm.Y - ptm.grand_mean*ones(1,N);

% Run sensor-wise ANOVAs at this time point
[tmp,tind]=min(abs(ptm.t-t));

C = ptm_contrast_time(ptm.d,ptm.dS,tind);

A = C'*Y;

K = 2; % Number of factor 2 levels

con(1).c = [1 1 -1 -1]';
con(2).c = [1 -1 1 -1]';
con(3).c = [1 -1 -1 1]';

L = ptm.svm_label;
for s = 1:ptm.dS
    a = A(s,:)';

    for i = 1:3
        glm = glm_test_hypothesis (ptm.D',a,con(i).c);
        F(s,i) = glm.F;
        pval(s,i) = glm.p;
    end

end

Fcorr = F;
if alpha < 1
    % Set F-values to zero if corrected p-value > alpha
    % using Benjamini-Hochberg (BH) procedure  
    s = [1:ptm.dS]';

    [p,pind] = sort(pval(:,test));
    fp = s*(alpha/ptm.dS);

    tmp = find(p<fp);
    ipos = max(tmp);

    if isempty(ipos)
        ipos=0;
    end
    Fcorr(pind(ipos+1:end),test) = 0;

    if plot_BH
        figure;plot(s,p,'o');hold on; plot(s,fp,'r')
    end
end

names = {'Factor 1','Factor 2','Interaction'};
h = figure;
set(h,'Name',sprintf('%s t = %d ms',names{test},t));
plot_scalp_map(Fcorr(:,test),ptm.channels,[],1);


