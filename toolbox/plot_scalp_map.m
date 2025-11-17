function [] = plot_scalp_map (x,channels,in,plot_labels)
% Plot MEG/EEG scalp map
% FORMAT [] = plot_scalp_map (x,channels,in,plot_labels)
%
% x             [D x 1] data vector to plot
% channels      data structure defining scalp space (SPM format)
% in.min        minimum of scale, .max          max of scale
% plot_labels   1 to plot channel labels

try plot_labels=plot_labels; catch plot_labels=0; end

if ~exist('in','var') || isempty(in) == 1
    in = [];
    in.min = min(x(:))-1;
    in.max = max(x(:));
end

Ieeg  = find(strcmp('EEG',{channels.type}));
if isempty(Ieeg)
    Ieeg  = find(strcmp('MEG',{channels.type}));
end
if isempty(Ieeg)
    Ieeg = find(strcmp('MEGGRAD',{channels.type}));
end
if isempty(Ieeg)
    disp('Error in plot_scalp_map:');
    disp('No EEG or MEG data to process !');
    return
end
Ieeg = intersect(Ieeg,find(~[channels.bad]));
                    
posEEG(:,1) = [channels(Ieeg).X_plot2D]';
posEEG(:,2) = [channels(Ieeg).Y_plot2D]';
EEGlabels = {channels(Ieeg).label};

in.ind = Ieeg;
in.type = 'EEG';

plot_scalp_map_details(x,posEEG,EEGlabels,in,plot_labels);