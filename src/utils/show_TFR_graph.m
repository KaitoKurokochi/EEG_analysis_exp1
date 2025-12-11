function [] = show_TFR_graph(data)
    %% TFR analysis 
    % freq analysis
    cfg              = [];
    cfg.output       = 'pow'; % output = power 
    cfg.channel      = 'all';
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.foi          = 2:2:30;                         % analysis 2 to 30 Hz in steps of 2 Hz
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
    cfg.toi          = -1.0:0.05:1.5;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
    
    spectr = ft_freqanalysis(cfg, data); 

    %% plot [freq x power] graph
    channel_indices = ~cellfun(@(x) strcmp(x, 'EOG'), spectr.label);
    pow_to_plot = nanmean(spectr.powspctrm(channel_indices, :, :), 3);
    
    figure;
    plot(spectr.freq, pow_to_plot');
    xlabel('Frequency (Hz)');
    ylabel('absolute power (uV^2)');

    %% figure [time x freq] graph for all channel
    cfg = [];
    cfg.baseline     = [-0.2 -0.0];
    cfg.channel      = 'all';
    cfg.baselinetype = 'absolute';
    cfg.showlabels   = 'yes';
    cfg.layout       = 'easycapM11.mat';
    figure; ft_multiplotTFR(cfg, spectr);
end

