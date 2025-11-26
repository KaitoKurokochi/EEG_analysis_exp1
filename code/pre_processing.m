%% define path - adjust for each participant or segment
define_path;
vhdr_file = fullfile(prj_path, "rawdata/nov12/Kurokochi_Exp1_2025-11-25_11-09-15.vhdr");
result_path = fullfile(prj_path, "result/nov12");

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

