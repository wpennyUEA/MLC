function [] = plot_bman_results (res)

test_name{1} = ['Main effect of ',res.fname{1}];
test_name{2} = ['Main effect of ',res.fname{2}];
test_name{3} = ['Interaction: ',res.fname{1},' x ',res.fname{2}];

logbf_thresh = 4.6;
figure
for test = 1:3
   
    tims = res.tims(res.samples);

    subplot(3,1,test)

    plot(tims,res.logbf(:,test))
    grid on
    hold on
    plot([tims(1) tims(end)],[4.6 4.6],'r')
    plot([tims(1) tims(end)],[-4.6 -4.6],'r')

    xlabel('ms')
    ylabel('logBF')
    title(test_name{test});

    g = get(gca);
    ymin = g.YLim(1);
    sig_ind = find(res.logbf(:,test) > 4.6);
    Ns = length(sig_ind);
    plot(tims(sig_ind),ymin*ones(1,Ns),'g*')
end

% figure
% for test = 1:3
% 
%     tims = res.tims(res.samples);
% 
%     subplot(3,1,test)
% 
%     plot(tims,res.Psi_OffDiag(:,test))
%     grid on
%     hold on
%     plot([tims(1) tims(end)],[4.6 4.6],'r')
%     plot([tims(1) tims(end)],[-4.6 -4.6],'r')
% 
%     xlabel('ms')
%     ylabel('logBFC')
%     title(test_name{test});
% 
% end