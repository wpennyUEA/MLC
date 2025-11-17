function [ptm, results] = get_reward_data (R)
% FORMAT [ptm, results] = get_reward_data (R)
%
% R
%           .sub       subject number
%           .drf       data reduction factor e.g. 8
%
% Factor 1 is 'RPE sign' with values of NEG and POS
% Factor 2 is 'RPE magnitude' with values of LOW and HIGH

sub = R.sub;
drf = R.drf;

dname = ['C:\Users\bzv17fbu\uea\data\reward-prediction-errors\700ms-feedback-version2\subj-data\'];

fname = [dname,'sub-',int2str(sub)];
load (fname);

[dS,dT] = size(D.Y{1});

factor1 = 'RPEsign';
f1_name={'Neg','Pos'};
factor2 = 'RPEmag';
f2_name={'Small','Large'};

levels = [2,2];
E = spm_make_contrasts(levels);

ptm.fname{1} = factor1;
ptm.fname{2} = factor2;

E(2).name = factor1;
E(3).name = factor2;
E(4).name = [factor1,' x ',factor2];

% Median split for low/high magnitude
abs_rpe_med = median(abs(D.rpe));

m = 1;
Y = [];
% Factor 1
for i1 = 1:2
    % Factor 2
    for i2 = 1:2
        switch m
            case 1,
                ind = find(D.rpe<0 & (abs(D.rpe) < abs_rpe_med));
            case 2
                ind = find(D.rpe<0 & (abs(D.rpe) >= abs_rpe_med));
            case 3
                ind = find(D.rpe>=0 & abs(D.rpe) < abs_rpe_med);
            case 4
                ind = find(D.rpe>=0 & abs(D.rpe) >= abs_rpe_med);
        end

        Ycond = [];
        for j = 1:length(ind)
            % Add trajectories to data matrix
            n = ind(j);
            Ycond = [Ycond,D.Y{n}(:)];  
        end

        % average drf consecutive trials
        S = floor(length(ind)/drf);
        Ycond = Ycond(:,1:S*drf);  % ignore last trial that don't make up a drf block
        Rmat = kron(eye(S),ones(drf,1))/drf;
        Yadd = Ycond*Rmat;
        ncond = size(Yadd,2);
        Y = [Y,Yadd];

        dc = ones(ncond,1);
        if m == 1
            DM = dc;
        else
            DM = blkdiag(DM,dc);
        end

        cond_name{m} = [f1_name{i1},'-',f2_name{i2}];
        m = m +1;
    end
end
DM = DM';
N = size(DM,2);

% Get Factor labels from conditions labels
svm_label{1} = DM(1,:)+DM(2,:)+2*(DM(3,:)+DM(4,:)); 
svm_label{2} = DM(1,:)+DM(3,:)+2*(DM(2,:)+DM(4,:)); 

% figure;plot(svm_label{1},'r');
% hold on
% plot(svm_label{2},'b');


% Get Baseline signal
tims = D.t;
ind = find(tims<0);
imax = max(ind);

my = zeros(dS,1);
for i = 1:imax
    base_ind = (i-1)*dS+[1:dS];
    my = my + mean(Y(base_ind,:),2);
end
my = my/imax;
Ybaseline = kron(ones(dT,1),my)*ones(1,N);

% figure
% subplot(2,2,1)
% imagesc(Y);
% title('Original')
% colorbar
% 
% subplot(2,2,2)
% imagesc(Ybaseline);
% title('Baseline')
% colorbar
% 
% % Baseline correct
Y = Y - Ybaseline;

% subplot(2,2,3)
% imagesc(Y);
% title('Baseline Corrected')
% colorbar

% Scale data
ms = mean(std(Y));
Y = Y/ms;

ptm.M = size(DM,1);
ptm.d = dS*dT;
ptm.grand_mean = mean(Y,2);
ptm.Y = Y;
ptm.D = DM;
ptm.dS = dS;
ptm.dT = dT;
ptm.t = tims; % peristimulus time (ms)

ptm.cname = cond_name; % condition names
for j = 1:dS,
    ptm.chan_label{j} = D.channels(j).label;
    ptm.channels = D.channels;
end
ptm.S = D.S; % 2D positions of channels

ptm.svm_label = svm_label;
ptm.E = E;
ptm.levels = levels;

