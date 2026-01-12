function [hfig] = my_singleplot_TFR(spectr, channel, xlim)
% input: 
%     spectr(struct): EEG spectrum data in fieldtrip format
%     channels(str): channel name to show on the graph 
%     xlim(cell): time limitation

    % figure TFR for selected channels
    cfg = [];
    cfg.baseline     = [-0.2 -0.0];
    cfg.baselinetype = 'absolute';
    cfg.maskstyle    = 'saturation';
    cfg.layout       = 'easycapM10.mat';
    cfg.channel = channel;
    if nargin >= 3
        cfg.xlim = xlim;
    end
    
    hfig = figure();
    ft_singleplotTFR(cfg, spectr); title(strcat(['TFR: ', channel]));
    hold on;
    xline(0, '-r', 's2 start');
    hold off;
end
