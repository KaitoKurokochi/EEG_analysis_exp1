function [spectr] = my_calc_spectr(data, channel)
% input: 
%     data(struct): EEG data in fieldtrip format
% output: 
%     spectr(struct): EEG spectrum data in fieldtrip format
     
    % freq analysis
    cfg              = [];
    cfg.channel      = channel;
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.foi          = 1:0.5:30; % start:step:end
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % length of time window = 0.5 sec
    cfg.toi          = -1.0:0.025:1.5; 
    cfg.keeptrials   = 'yes';
    spectr = ft_freqanalysis(cfg, data); 
end


