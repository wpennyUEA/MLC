function [cmeans] = plot_condition_means (ptm)
% Plot condition means
% FORMAT [cmeans] = plot_condition_means (ptm)
%
% ptm
%
% cmeans    .ymin, .ymax, .mu_mat{m},  for m = 1..M

Y = ptm.Y;
D = ptm.D;
ds = ptm.dS;
dt = ptm.dT;

% Adjust data to zero overall grand mean
[tmp,N] = size(ptm.Y);
Y = ptm.Y - ptm.grand_mean*ones(1,N);

% Estimate means
M = size(D,1);
for m = 1:M
    ind = find(D(m,:)==1);
    N(m) = length(ind);
    mu_traj(:,m) = mean(Y(:,ind),2);
end

for m = 1:M
    mu_mat{m} = reshape(mu_traj(:,m),ds,dt);
end
    
ymax = max(max(mu_traj));
ymin = min(min(mu_traj));

rm = ceil(sqrt(M));
figure
for m = 1:M
    subplot(rm,rm,m)
    imagesc(ptm.t,[1:ds],mu_mat{m},[ymin ymax])
    title(ptm.cname{m})
    colorbar
    if m==1 | m ==3
        ylabel('Electrode')
    end
    if m==3 | m==4
        xlabel('Time (ms)')
    end
end





        