function [data] = my_preprocessing(data, sequence_path, trialfun)
% eeg pre_processing file
% 1. filtering (1-30Hz)
% 2. define trial 
% 3. baseline correction (-0.2 - 0.0sec)
%   
%   % usage: 
%   [DATA] = my_pre_processing(DATA, SEQUENCE_PATH, TRIALFUN)
%
%   input:
%     DATA: data in fieldtrip format
%     SEQUENCE_PATH: sequence definition path
%     TRIALFUN: trialfun for the data 
%
%   output:
%     DATA: fieldtrip data structure after filtering and defining trials
   
    vhdr = data.cfg.dataset; % use in clipping

    % filtering(1-30Hz)
    disp('--- filtering ---')
    cfg = [];
    cfg.bpfilter    = 'yes';
    cfg.bpfilttype  = 'fir';
    cfg.bpfreq      = [1 30];
    cfg.continuous  = 'yes'; 
    data = ft_preprocessing(cfg, data);

    % define trial and labeling (continous -> segmented) 
    disp('--- trial def ---');
    cfg = [];
    cfg.trialfun = trialfun;
    cfg.headerfile = vhdr;
    cfg.sequencefile = sequence_path;
    cfg = ft_definetrial(cfg);
    data = ft_redefinetrial(cfg, data);

    % baseline correction
    cfg = [];
    cfg.demean           = 'yes';
    cfg.baselinewindow   = [-0.2 0];
    data = ft_preprocessing(cfg, data);
end

