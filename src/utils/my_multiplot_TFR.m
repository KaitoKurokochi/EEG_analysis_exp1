function [] = my_multiplot_TFR(spectr)
% input: 
%     spectr(struct): EEG spectrum data in fieldtrip format

    % figure [time x freq] graph for all channel
    cfg = [];
    cfg.baseline     = [-0.2 -0.0];
    cfg.channel      = 'all';
    cfg.baselinetype = 'absolute';
    cfg.showlabels   = 'yes';
    cfg.layout       = 'easycapM11.mat';
    figure; ft_multiplotTFR(cfg, spectr);
end

