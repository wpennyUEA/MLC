clear all
close all

disp('Note that decoding analysis requires the stats toolbox');

%-----------------------------------------------------------------
% Analysis parameters
R.run_decoding = 0;
R.plot_means = 0;
R.run_classic_manova = 0;
R.run_bayes_manova = 1;

R.temporal_resolution = 4; % set to k, to analyse every kth time step
R.V = 10; % Number of cross-validation folds
%R.classifier = 'fitclinear';
R.classifier = 'fitcsvm';
%R.classifier = 'fitcknn';
%R.classifier = 'fitcnb';
R.run_svd = 0;

R.alpha = 0.01; % Benjamini-Hochberg FDR level
%-----------------------------------------------------------------
% Data Set

%data_set = 'DM';  
%data_set = 'Reward';
data_set = 'Synthetic';

st_regions = [];
switch data_set

    case 'Synthetic'
        sim.ds = 61;
        sim.type = 'S3';  % 'S1','S2' or 'S3'
        sim.sparsity = 0.5;
        sim.spatial_cov = 1;

        ptm = get_synth_data (sim);
        data_name = [data_set,'_',sim.type];

    case 'DM'
        ptm = get_DM_data ('DM');
        sim = [];
        data_name = data_set;

    case 'Reward'
        R.drf = 4; % data reduction factor
        %subjects = [6,38,42];
        R.sub = 38; % subject ID
        ptm = get_reward_data (R);
        sim = [];
        data_name = [data_set,'_Sub',int2str(R.sub)];

    otherwise 
        disp('Unknown data set ...')
        return
end

ptm.samples = 1:R.temporal_resolution:ptm.dT;

if R.plot_means
    plot_condition_means (ptm);
end

if R.run_decoding
    class_res = run_classifier (ptm,R);
    plot_classifier_results (class_res,R.alpha);

    % Report times of strongest effects
    for test = 1:2
        C = class_res{test};
        [tmp,ind(test)] = max(C.svm_corr);
        peak_time = C.tims(C.samples(ind(test)));
        disp(sprintf('Main effect of %s: time at peak decoding accuracy = %1.2f',ptm.fname{test},peak_time));
    end
   
    save_str = ['save results/',data_name,'_',R.classifier,'_svd',int2str(R.run_svd),' R sim class_res'];
    eval(save_str);
end

if R.run_classic_manova
    cman_res = classic_manova_time_series (ptm);
    plot_cman_results (cman_res,'-logpval',R.alpha);
    %plot_cman_results (cman_res,'F');

end

if R.run_bayes_manova
    bman_res = bayes_manova_time_series(ptm);
    plot_bman_results (bman_res);

    opt.alpha = 0.05;
    plot_univariate_effects (ptm,bman_res,opt);

    save_str = ['save results/',data_name,'_MLC R sim bman_res'];
    eval(save_str);

end