function [ptm] = get_DM_data (factor2)
% FORMAT [ptm] = get_DM_data (factor2)
%
% Factor 1 is group (with levels young old)
% Factor 2 is 'DM' with levels Semantic, Episodic
%          or 'Perspective' with levels Past, Present, Future

% For now, treat within-subject factor as a between-subject factor
% For now, have N=26 in both groups
%

load tanguay_ERP_format

%load smoothed_tanguay_ERP_format

switch factor2,
    case 'DM'
        conds = [1,2];
        E = spm_make_contrasts([2,2]);
        f2_name={'semantic','episodic'};
        fname = {'Group','Memory Type'};

    case 'Perspective'
        conds = [3,4,5];
        E = spm_make_contrasts([2,3]);
        
        f2_name = {'past','present','future'};
        fname = {'Group','Perspective'};
end

NS = 26;

levels = [2,2];
E(2).name = 'Group';
E(3).name = factor2;
E(4).name = ['Group x ',factor2];

f1_name={'young','old'};
k = 1;n=1;
for g = 1:2
    % factor 1
    ind=find(group==g);
    %NS = length(ind);
    
    for j = 1:length(conds)
        % factor 2
        c = conds(j);
        cond_name{k} = [f1_name{g},'-',f2_name{j}];
        for i=1:NS
            sub = ind(i);
            erp = erp_data{sub};
            X{i,k} = erp.y{c};
            svm_label{1}(n)=g;  % Factor 1 label
            svm_label{2}(n)=j;  % Factor 2 label
            n = n+1;
        end
        k = k+1;
    end
end

[X,res_std] = erp_baseline_correct (X,erp.t);

X = stm_scale_data (X);

ptm = ptm_fit_enc (X);

ptm.t = erp.t; % peristimulus time (ms)
ptm.cname = cond_name; % condition names
dS = length(erp.channels); 
for j = 1:dS,
    ptm.chan_label{j} = erp.channels(j).label;
    ptm.channels = erp.channels;
end
ptm.S = S; % 2D positions of channels

ptm.svm_label = svm_label;
ptm.E = E;
ptm.levels = levels;
ptm.fname = fname;
