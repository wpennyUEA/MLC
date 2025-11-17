function [X,tims,erp,sim] = gen_interaction_data (sim)
% Generate simulated data containing an interaction
% FORMAT [X,tims,erp,sim] = gen_interaction_data (sim)
%
% sim       .C  number of levels of two factors (default is [2 2])
% sim       .itype type of interaction
%               'spatial' - factor 2 changes what electrodes contain
%                           difference in factor 1 variable
%               'temporal' - factor 2 changes what time difference in
%                           factor 1 variable occurs
%           .crossover     - 1 for crossover interaction
%

try C = sim.C; catch C = [2 2]; end
try itype = sim.itype; catch itype = 'temporal'; end
try crossover = sim.crossover; catch crossover = 1; end

load tanguay_ERP_format 

% Load Tanguay ERPs from young group, condition 1 (semantic)
ind=find(group==1); % Young
Ns = length(ind);
[ds,dt] = size(erp_data{1}.y{1});

ds = sim.ds;

% Define C(1) patterns
pact = sim.sparsity; % proportion of activated electrodes
sel = zeros(ds,C(1));
for k = 1:C(1)
    sr = floor(0.5*ds);
    el_ind = [1:sr]+(k-1)*sr;
    sel(el_ind,k) = rand(sr,1) < pact;
end

%snr = 0.25*2/C(2);  % reduce SNR in proportion to #levels of 2nd factor
snr = 2*2/C(2);  % reduce SNR in proportion to #levels of 2nd factor
noise_sd = 1/snr;

erp = erp_data{1};

if sim.spatial_cov
    [tmp,C_spatial] = spatial_precision_matrix (S);
    C_spatial = noise_sd*C_spatial;
else
    C_spatial = noise_sd*eye(ds);
end

tims = erp.t;
T = tims(end);

% Define C(1) times of maximal difference
dt = 800/(C(1)+1);
t0 = [1:C(1)]*dt;

%figure
for k = 1:C(1)
    z = (tims(:)-t0(k))/(0.05*T);

    [tmp,ind] = min(abs(tims-t0(k)));
    t0_ind(k) = ind;
   
    yy(:,k) = exp(-z.^2);
    % subplot(C(1),1,k)
    % plot(tims,yy(:,k));
    % grid on
end

for j = 1:C(1) % factor 1 changes slowest
    for k = 1:C(2)  % factor 2
        if crossover
            if j==1
                f(j,k) = k;
            elseif j==2
                f(j,k) = C(2)-k + 1;
            end
        else
            f(j,k) = k;
        end
    end
end


% Loop over levels of each factor

n = 1;

c = 1;
for j = 1:C(1) % factor 1 changes slowest
    for k = 1:C(2)  % factor 2
        % if crossover
        %
        % end

        switch itype
            case 'spatial-fixed'
                mu_spatial(:,c) = 0.001*randn(ds,1) + sel(:,1)*f(j,k);
                y = yy(:,1); % temporal profile not dependent of factor 1
            case 'spatial-fixed-nointer'
                mu_spatial(:,c) = 0.001*randn(ds,1) + sel(:,1)*k;
                y = yy(:,1); % temporal profile not dependent of factor 1
            case 'spatial-var'
                mu_spatial(:,c) = 0.001*randn(ds,1) + sel(:,j)*f(j,k);
                y = yy(:,1); % temporal profile not dependent of factor 1
            case 'temporal'
                mu_spatial(:,c) = 0.001*randn(ds,1) + sel(:,1)*f(j,k);
                y = yy(:,j); % temporal profile dependent of factor 1
        end
        for s = 1:Ns
            svm_label{1}(n)=j;  % Factor 1 label
            svm_label{2}(n)=k;  % Factor 2 label
            n = n + 1;
            for i = 1:length(tims)
                mu_ci = mu_spatial(:,c)*y(i);
                %X{s,c}(:,i) = grand_mean_cond1(:,i) + spm_normrnd(mu_ci,noise_sd*eye(ds),1);
                X{s,c}(:,i) = spm_normrnd(mu_ci,C_spatial,1);
            end
        end
        c = c + 1;  % experimental condition
    end
end

C = c-1;
sim.mu_spatial = mu_spatial;
sim.t0 = t0;
sim.t0_ind = t0_ind;
sim.noise_sd = noise_sd;
sim.yy = yy;
sim.f = f;
sim.svm_label = svm_label;
sim.f1 = {'Y','O'};
sim.f2 = {'A','B'}
sim.fname = {'Group','Drug'};
c = 1;
for i = 1:2
    for j = 1:2
        sim.cname{c} = [sim.f1{i},' ',sim.f2{j}];
        c = c+1;
    end
end

[X,ms] = stm_scale_data (X);

erp.S = S; % spatial positions of channels
sim.E = spm_make_contrasts(sim.C);
sim.C_spatial = C_spatial;
