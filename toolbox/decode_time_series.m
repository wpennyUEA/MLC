function [res] = decode_time_series(ptm,options)
% Decoding over time
% FORMAT [res] = decode_time_series(ptm,options)
%
% ptm
% options
%           
% res

try svm_label = options.svm_label; catch svm_label=[]; end
try svm = options.svm; catch svm=0; end
try method = options.method; catch method = 'fitcnb'; end
try V = options.V; catch V = size(ptm.D,2); end
try run_svd = options.run_svd; catch run_svd=0; end

tims = ptm.t;

% Subtract grand mean
N = size(ptm.Y,2);
Y = ptm.Y - ptm.grand_mean*ones(1,N);

samples = ptm.samples;
% Classify multivariate spatial activity as a function of time
for k = 1:length(samples)
    i = samples(k);

    C = ptm_contrast_time(ptm.d,ptm.dS,i);
    
    disp(sprintf('Time point %d out of %d',k,length(samples)))
    
    A = C'*Y;

    if run_svd
        [Utmp,Stmp,Vtmp]=svd(A,0);
        W = Utmp(:,1:8);
        A = W'*A;
    end

    % get labels if necessary
    if isempty(svm_label)
        for m = 1:Menc.M
            ind = find(ptm.gamma(m,:)==1);
            for j = 1:length(ind)
                label{ind(j)} = int2str(m);
            end
        end
    else
        for j = 1:length(svm_label)
            label{j} = int2str(svm_label(j));
        end
    end

    Aproj = A;
    if strcmp(method,'bsr')
        R = bsr_classify(Aproj',svm_label(:),V); 
    else
        R = svm_classify(Aproj',label,V,method); 
    end
    corr = sum(diag(R.CM));
    tot = sum(sum(R.CM));
    incorr = tot-corr;
    res.svm_corr(k) = (corr+1)/(tot+1);

    % Brodersen approach to confidence intervals
    alpha_level=0.1;
    res.svm_corr_lower(k) = spm_invBcdf(0.5*alpha_level,corr+1,incorr+1);
    res.svm_corr_upper(k) = spm_invBcdf(1-0.5*alpha_level,corr+1,incorr+1);

    if isfield(R,'Nsel')
        res.Nsel(k) = R.Nsel;
        disp(sprintf('t = %d: pcorr = %1.2f [%1.2f %1.2f], Nsel = %1.2f',ptm.t(i),res.svm_corr(k),res.svm_corr_lower(k),res.svm_corr_upper(k),R.Nsel));
    end

end

res.tims = tims;
res.samples = samples;
