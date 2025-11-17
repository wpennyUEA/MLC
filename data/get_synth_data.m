function [ptm] = get_synth_data (sim)
% FORMAT [ptm] = get_synth_data (sim)
%
% sim       .type       'S1', 'S2' or 'S3'
%           .ds         number of electrodes
%           .sparsity   e.g. 0.1 for 10% voxels active


% Generate data from C conditions
sim.C = [2,2];

switch sim.type
    case 'S1'
        sim.itype = 'spatial-fixed-nointer';
        sim.crossover = 1;
        [X,tims,erp,sim] = gen_interaction_data (sim);

    case 'S2'
        sim.itype = 'spatial-fixed';
        sim.crossover = 1;
        [X,tims,erp,sim] = gen_interaction_data (sim);

    case 'S3'
        [X,tims,erp,sim] = gen_heterogeneous_data (sim);

    otherwise
        disp('Unknown simulation type ...')
        return
end

ptm = ptm_fit_enc (X);
ptm.t = tims;
ptm.E = sim.E;
ptm.levels = [2,2];
ptm.cname = sim.cname;
ptm.fname = sim.fname;
ptm.C_spatial = sim.C_spatial;
ptm.channels = erp.channels;