% sub 1: show spectrum data on graphs
%
% The result is saved in {prj_dir}/result/sub1/{participant_id}/xxx.jpg
%
% The graphs made in this program: 
% - {id}_power.jpg : sepctrum power graphs of v1_3
% - {id}_topo.jpg : spectrum topomap graphs of v1_3 

config;

data_dir = fullfile(prj_dir, 'result', 'v1_3');
res_dir = fullfile(prj_dir, 'result', 'sub1');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

data_fnames = {dir(fullfile(data_dir, '*.mat')).name};

for i = 1:length(data_fnames)
    if contains(data_fnames{i}, 'ica_result') 
        continue;
    end

    load(fullfile(data_dir, data_fnames{i})); % include data_v1_3

    id = erase(data_fnames{i}, '.mat');
    disp(['--- id: ', id, ', start processing ---']);

    % calc spectrum
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'all';
    cfg.method       = 'mtmfft';
    cfg.taper        = 'hanning';
    cfg.foi          = 1:0.5:30; % start:step:end
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % length of time window = 0.5 sec
    cfg.toi          = -1.0:0.025:1.5; 
    cfg.keeptrials   = 'yes';
    freq = ft_freqanalysis(cfg, data_v1_3);

    %%
    % fig: time x frequency power
    hFig = my_spectr_power_plot(freq);
    saveas(hFig, fullfile(res_dir, [id, '_power.jpg']));
    close(hFig);

    % fig: frequency band topo map
    hFig = my_freq_band_topomap(freq);
    saveas(hFig, fullfile(res_dir, [id, '_topo.jpg']));
    close(hFig);
end