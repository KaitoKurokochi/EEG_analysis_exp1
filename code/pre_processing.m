%% define path - adjust for each participant or segment
define_path;
vhdr_file = fullfile(prj_path, "rawdata/nov12/Kurokochi_Exp1_2025-11-25_11-09-15.vhdr");
sequence_file = fullfile(prj_path, "rawdata/nov12/sequence_1.csv");
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
data_flt = ft_preprocessing(cfg);

%% trial def and clipping
cfg = [];
cfg.trialfun = 'mytrialfun';
cfg.headerfile = vhdr_file;
cfg.sequencefile = sequence_file;
cfg = ft_definetrial(cfg);

disp('--- clipping ---');
data = ft_redefinetrial(cfg, data_flt);

%% ICA 
% perform the independent component analysis (i.e., decompose the data)
cfg        = [];
cfg.channel = {'all', '-EOG'};
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
cfg.runica.pca = 20; % N of comps

disp('--- runica ---');
comp = ft_componentanalysis(cfg, data);

%% Check IC-Label
% plot the components for visual inspection
figure
cfg = [];
cfg.component = 1:20;       % specify the component(s) that should be plotted
cfg.layout    = 'easycapM11.mat'; % specify the layout file that should be used for plotting
% cfg.comment   = 'no';
ft_topoplotIC(cfg, comp);

cfg = [];
cfg.layout = 'easycapM11.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, comp);

%% remove noisy comps 
cfg = [];
cfg.component = []; % to be removed component(s)
data = ft_rejectcomponent(cfg, comp, data);
