% input: need to set participant's name, vhdrfile name, sequencefile name, savefile name
% - rawdata/{participant}/*.eeg, *.vhdr, *.vmrk
% - rawdata/{participant}/sequence_x.csv
% 
% output 
% - result/{participant}/seg{i}_v1.mat

%% define path
define_path;

%% check the dataset
cfg = [];
cfg.dataset             = vhdr_path;
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);

%% read data and filtering 
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfilttype = 'fir';
cfg.bpfreq     = [1 30];
cfg.continuous  = 'yes'; 
cfg.dataset = vhdr_path;

disp('--- filtering ---')
data = ft_preprocessing(cfg);

%% trial def and clipping
cfg = [];
cfg.trialfun = 'mytrialfun';
cfg.headerfile = vhdr_path;
cfg.sequencefile = sequence_path;
cfg = ft_definetrial(cfg);

disp('--- clipping ---');
data = ft_redefinetrial(cfg, data);

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
cfg.component = [1, 2, 3, 4, 8, 14]; % to be removed component(s)
data = ft_rejectcomponent(cfg, comp, data);

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

%% data saving
save(v1_path, 'data', '-v7.3');