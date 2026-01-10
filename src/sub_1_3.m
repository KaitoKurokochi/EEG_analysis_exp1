% sub_1_3: show TFR data after ICA
%
% input: 
% - result/v1_3/{pname}-{segment_num}.mat: include data_v1_3
%
% The result would be saved in
% {prj_dir}/result/sub3/{pname}-{segment_num}_power.jpg
% {prj_dir}/result/sub3/{pname}-{segment_num}_topo.jpg

config;

data_dir = fullfile(prj_dir, 'result', 'v1_3');
res_dir = fullfile(prj_dir, 'result', 'sub_1_3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end
 
for i = 1:length(groups)
    for j = 1:12
        for k = 1:5
            id = [groups{i}, num2str(j), '-', num2str(k)];
            
            fname = fullfile(data_dir, [id, '.mat']);
            if ~exist(fname, 'file')
                continue;
            end

            disp('loading...');
            load(fname); % include data_v1_3
            
            disp(['--- id: ', id, ', start processing ---']);

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
            freq = ft_freqanalysis(cfg, data_v1_3);
            
            % fig: time x frequency power
            hFig = my_spectr_power_plot(freq);
            saveas(hFig, fullfile(res_dir, [id, '_power.jpg']));
            close(hFig);
            
            % fig: frequency band topo map
            hFig = my_freq_band_topomap(freq);
            saveas(hFig, fullfile(res_dir, [id, '_topo.jpg']));
            close(hFig);
        end
    end
end