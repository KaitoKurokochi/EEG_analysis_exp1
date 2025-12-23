function [hfig] = my_singleplot_TFR(spectr, channel, opt)
% input: 
%     spectr(struct): EEG spectrum data in fieldtrip format
%     channels(str): channel name to show on the graph 
%     graph_option(str): graph line option, 'f': fastball, 's': slider,
%     'fs': both
    if nargin < 3
        opt = '';
    end

    % figure TFR for selected channels
    cfg = [];
    cfg.baseline     = [-0.2 -0.0];
    cfg.baselinetype = 'absolute';
    cfg.maskstyle    = 'saturation';
    cfg.layout       = 'easycapM10.mat';
    cfg.channel = channel;
    
    hfig = figure();
    ft_singleplotTFR(cfg, spectr); title(strcat(['TFR: ', channel]));
    hold on;
    xline(0, '-r', 's2 start');
    if contains(opt, 'f')
        xline(0.5, '-r', 's2 end (fastball)'); % vertical line 
    end
    if contains(opt, 's')
        xline(0.57, '-r', 's2 end (slider)'); % vertical line 
    end
    hold off;
end
