function [R] = svm_classify(X,Y,V,method)
% V-fold Cross Validation using a Support Vector Machine
% FORMAT [R] = svm_classify(X,Y,V,method)
%
% INPUTS:
% X         [N x d] data matrix
% Y         [N x 1] element string vector of category labels (K different categories)
% V         Number of folds, default = 10
% method    'fitcsvm' for SVM 'fitclinear' (K=2 categories only).
%           'fitclinear' for linear classifier (K=2 categories only).
%           'fitcnb' for Naive Bayes
%           'fitcknn' for k-nearest neighbour (this function uses 5
%           neighbours)
%           default method is 'fitcecoc' for SVM with error correcting
%           output codes
%
% OUTPUTS:
% R     .CM         confusion matrix
%       .corr_rate  correct rate
%       .err_rate   error rate
%
% Requires Matlab's statistics toolbox

try method=method; catch method='fitclinear'; end
try V=V; catch V = 10; end

switch method
    case 'fitclinear'
        cvsvm = fitclinear(X,Y,'Kfold',V);
    case 'fitcsvm'
        cvsvm = fitcsvm(X,Y,'Kfold',V);
    case 'fitcnb'
        cvsvm = fitcnb(X,Y,'Kfold',V);  
    case 'fitcknn'
        cvsvm = fitcknn(X,Y,'Kfold',V,'NumNeighbors',5); 
    otherwise
        disp('Unknown classifier in svm_classify.m')
        return
end

Yhat = kfoldPredict(cvsvm);
R.CM = confusionmat(Y,Yhat);
R.corr_rate = sum(diag(R.CM))/sum(sum(R.CM));
R.err_rate = 1 - R.corr_rate;

