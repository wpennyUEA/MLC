function [h] = plot_classifier_results (result,alpha)
% Plot p_corr curves with FDR-corrected markers
% FORMAT [h] = plot_classifier_results (result,alpha)
%
% res       from run_classifier
% alpha     significant level
%
% h         handle to figure

test_name{1} = ['Main effect of ',result{1}.fname{1}];
test_name{2} = ['Main effect of ',result{1}.fname{2}];
test_name{3} = ['Interaction: ',result{1}.fname{1},' x ',result{1}.fname{2}];


E = result{1}.E;
levels = result{1}.levels;

h = figure;
for test = 1:2
    M = levels(test);

    res = result{test};
    tims = res.tims(res.samples);

    subplot(2,1,test)
    confplot(tims,res.svm_corr,res.svm_corr-res.svm_corr_lower,res.svm_corr_upper-res.svm_corr,'b-');
    grid on
    hold on

    nr = 1/M;
    plot([tims(1) tims(end)],[nr nr],'r')
    xlabel('ms')
    ylabel('p_{corr}')
    %title(E(test+1).name);
    title(test_name{test})

    % Which time points are significant at FDR-correct at alpha level
    N = res.N;
    p = 1-binocdf(res.svm_corr*N,N,nr);
    p = p(:);

    % Benjamini-Hochberg procedure
    s = [1:length(p)]';
    [p,pind] = sort(p);
    fp = s*(alpha/length(p));

    tmp = find(p<fp);
    ipos = max(tmp);

    if isempty(ipos)
        ipos=0;
        disp(sprintf('Test %d: no significant results at alpha = %1.2f',test,alpha))
    else
        g = get(gca);
        ymin = g.YLim(1);
        sig_ind = pind(1:ipos);
        plot(tims(sig_ind),ymin*ones(1,ipos),'g*')
    end
    

    % plot_BH = 1;
    % if plot_BH
    %     figure;plot(s,p,'o');hold on; plot(s,fp,'r')
    % end

end