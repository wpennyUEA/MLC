function [] = plot_cman_results (res,w,alpha)
% Plot Classic Manova results
% FORMAT [] = plot_cman_results (res,w,alpha)
%
% res       results
% w         what to plot '-logp' or 'F'
% alpha     alpha level for BH-correction

test_name{1} = ['Main effect of ',res.fname{1}];
test_name{2} = ['Main effect of ',res.fname{2}];
test_name{3} = ['Interaction: ',res.fname{1},' x ',res.fname{2}];

pval_thresh = 0.01;
lp = -log(pval_thresh);
figure
for test = 1:3
   
    tims = res.tims(res.samples);

    subplot(3,1,test)
    switch w
        case 'F'
            plot(tims,res.Fval(:,test))
            ylabel('F')
        otherwise
            plot(tims,-log(res.pval(:,test)))
            hold on
            plot([tims(1) tims(end)],[lp lp],'r')
            ylabel('-log p-value')
    end
    grid on
    xlabel('ms')
    title(test_name{test});

    p = res.pval(:,test);

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

end