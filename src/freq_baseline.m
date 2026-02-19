% freq baseline -> baseline correction of frequency data 
% the time range of the result is [0.0 0.6]
clear;
config; 

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
res_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% sum - ratio version 
% set baseline type
baseline_type = 'sr'; % sr

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']); % incoude data
        disp('loading...');
        load(fname); % include freq

        cfg = [];
        cfg.latency     = [0.0 0.6];
        freq = ft_selectdata(cfg, freq);

        time_sum = sum(freq.powspctrm, 4); % to rep x chan x freq x 1
        freq.powspctrm = freq.powspctrm ./ time_sum;

        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_bl_', baseline_type, '.mat']), 'freq', '-v7.3');
    end
end

%% others
% set baseline type
clear;
config; 

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
res_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

baseline_type = 'db'; % relative, db, zscore

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']); % incoude data
        disp('loading...');
        load(fname); % include freq

        cfg = [];
        cfg.baseline     = [-0.2 0.0];
        cfg.baselinetype = baseline_type;
        freq = ft_freqbaseline(cfg, freq);

        cfg = [];
        cfg.latency     = [0.0 0.6];
        freq = ft_selectdata(cfg, freq);

        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_bl_', baseline_type, '.mat']), 'freq', '-v7.3');
    end
end

%% fig - all channels
clear;
config;

% set baseline type
baseline_type = 'db'; % sr, relative, db, zscore

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_group_cond_band_chan'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '_bl_', baseline_type, '.mat'])); % include freq
        for b = 2:length(bands)
            % figure
            fig = figure('Position', [100, 100, 1600, 1200]);
            % multiplot
            cfg = [];
            cfg.layout           = 'easycapM11.mat';
            cfg.ylim             = [bands{b, 1}(1), bands{b, 1}(2)];
            cfg.zlim             = 'maxabs';
            % cfg.zlim             = bands{b, 3};
            cfg.showlabels       = 'yes';
            ft_multiplotTFR(cfg, freq);
            saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', bands{b, 2}, '_', baseline_type, '.jpg']));
            close(fig);
        end
    end
end

%% fig - topomap
clear;
config;

% set baseline type
baseline_type = 'db'; % sr, relative, db, zscore

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_group_cond_band_topo'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '_bl_', baseline_type, '.mat'])); % include freq

        % for each 50ms
        for t = 0:0.05:0.55
            for b = 2:length(bands)
                t_strt = t;
                t_end = t+0.05;
    
                fig = figure('Position', [100, 100, 800, 600], 'Visible', 'off');
    
                cfg = [];
                cfg.xlim               = [t_strt, t_end]; % time band
                cfg.ylim               = [bands{b, 1}(1), bands{b, 1}(2)]; % freq band
                cfg.zlim               = 'maxabs';
                cfg.colorbar           = 'yes';
                cfg.layout             = 'easycapM11.mat';
                ft_topoplotTFR(cfg, freq);
                saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', bands{b, 2}, '_', num2str(t_strt*1000), '_', num2str(t_end*1000), '_', baseline_type, '.jpg']));
                close(fig);
            end
        end
    end
end