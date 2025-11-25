%% define path  
vhdr_file = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov12\Kurokochi_Exp1_2025-11-25_11-09-15.vhdr"; % adjust for each participants 
result_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\nov12"; % adjust for each participants 

%% check the dataset
cfg = [];
cfg.dataset             = vhdr_file;
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);

%% read data and filtering 
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfilttype = 'fir';
cfg.bpfreq     = [1 30];
cfg.continuous  = 'yes'; 
cfg.dataset = vhdr_file;

disp('--- filtering ---')
data_filtered = ft_preprocessing(cfg);

%% trial def and clipping
cfg = [];
cfg.trialfun = 'mytrialfun';
cfg.headerfile = vhdr_file;
cfg_trial_info = ft_definetrial(cfg);

disp('--- clipping ---');
data_clipped = ft_redefinetrial(cfg_trial_info, data_filtered);

%% data browsing 
cfg = [];
cfg.channel = 'Cz';
cfg.ylim = [-1.0 1.0];
ft_databrowser(cfg, data_clipped);

disp("finish processing")

