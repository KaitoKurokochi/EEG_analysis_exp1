% erp_to_freq: convert ERP data to frequency data
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']); % incoude data
        disp('loading...');
        load(fname); % include data

        % wavelet transform
        cfg = [];
        cfg.method      = 'wavelet';
        cfg.output      = 'pow';
        cfg.keeptrials  = 'yes';
        cfg.foi         = logspace(log10(3),log10(90),30);
        cfg.width       = logspace(log10(3),log10(30),30);
        cfg.toi         = data.time{1}(1) : 0.05 : data.time{1}(end);
        freq = ft_freqanalysis(cfg, data);

        % baseline correction 
        cfg = [];
        cfg.baseline     = [-0.2 0.0];
        cfg.baselinetype = 'db';
        freq = ft_freqbaseline(cfg, freq);

        % save data
        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.mat']), 'freq', '-v7.3');
    end
end

%% fig - topomap
clear;
config;

bands = { ...
    % [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]};

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_group_cond_band_topo'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat'])); % include freq

        % for each 50ms
        for t = 0:0.05:0.55
            for b = 2:length(bands)
                % select data
                cfg = [];
                cfg.latency     = [t, t+0.05]; % t ~ 50ms
                cfg.frequency   = bands{b, 1};
                freq_t_b = ft_selectdata(cfg, freq);

                % set fig
                fig = figure('Position', [100, 100, 800, 600], 'Visible', 'off');
    
                cfg = [];
                cfg.zlim               = 'maxabs';
                cfg.colorbar           = 'yes';
                cfg.layout             = 'easycapM11.mat';
                ft_topoplotTFR(cfg, freq_t_b);
                saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', bands{b, 2}, '_', num2str(t*1000), '_', num2str((t+0.05)*1000), '.jpg']));
                close(fig);
            end
        end
    end
end