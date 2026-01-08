% sub_1_2: segment-base pre-processing (manually remove noise channels and
% trials)
%
% This program is to redo the same thing to main_1_2 for a segment that is not
% correctly cleaned
%
% read data as below 
% - result/v1_1/{pname}_{i}.mat (include data_v1_1) 
% saves data as below
% - result/v1_2/{pname}_{i}.mat: pre-processed data (data_v1_2)

config;
id = 'nov12-5';

data_dir = fullfile(prj_dir, 'result', 'v1_1');
res_dir = fullfile(prj_dir, 'result', 'v1_2');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

fname = fullfile(data_dir, [id, '.mat']);
disp('loading...');
load(fname); % include data_v1_1

disp(['--- id: ', id, ', start processing ---']);

% visual inspection v1_1
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_v1_1);

% calc freq
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 1:0.5:30; % start:step:end
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % length of time window = 0.5 sec
cfg.toi          = -1.0:0.025:1.5; 
cfg.keeptrials   = 'yes';
freq = ft_freqanalysis(cfg, data_v1_1);

% fig: time x frequency power
hFig = my_spectr_power_plot(freq);
saveas(hFig, fullfile(res_dir, [id, '_power_before.jpg']));
close(hFig);

% fig: frequency band topo map
hFig = my_freq_band_topomap(freq);
saveas(hFig, fullfile(res_dir, [id, '_topo_before.jpg']));
close(hFig);

% remove noise channel manually
cfg          = [];
cfg.method   = 'summary';
data_v1_2 = ft_rejectvisual(cfg, data_v1_1);

% check data after noise channel removal 
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 1:0.5:30; % start:step:end
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % length of time window = 0.5 sec
cfg.toi          = -1.0:0.025:1.5; 
cfg.keeptrials   = 'yes';
freq = ft_freqanalysis(cfg, data_v1_2);

% fig: time x frequency power
hFig = my_spectr_power_plot(freq);
saveas(hFig, fullfile(res_dir, [id, '_power_after.jpg']));
close(hFig);

% fig: frequency band topo map
hFig = my_freq_band_topomap(freq);
saveas(hFig, fullfile(res_dir, [id, '_topo_after.jpg']));
close(hFig);

% save 
save(fullfile(res_dir, [id, '.mat']), 'data_v1_2', '-v7.3');

