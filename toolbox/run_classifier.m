function [result] = run_classifier (ptm,R)
% Test main effects using decoder
% FORMAT [result] = run_classifier (ptm,R)
% 
% ptm       PTM data structur from ptm_fit_enc
% R         .method    'fitclinear', 'fitcsvm', 'fitcknn' or 'bsr'
%           .run_svd   1 to reduce dimension to M=8 using SVD
%           .V         number of folds, defaults to leave-one-out if not specified

options.method = R.classifier;
options.run_svd = R.run_svd;
options.V = R.V; 

%figure
for test = 1:2
    options.svm_label = ptm.svm_label{test};
    M = length(unique(options.svm_label));

    res = decode_time_series(ptm,options);

    tims = res.tims(res.samples);

    res.N = size(ptm.Y,2);
    res.V = options.V;
    res.E = ptm.E;
    res.levels = ptm.levels;
    result{test} = res;
end
result{1}.fname = ptm.fname;
