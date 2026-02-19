% statistics: cluster-based permutation test of freq for each condition 
% data is trial x time x amplitude frequency data
% compare between groups

clear;
config;

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% neighbours
load(fullfile(prj_dir, 'src', 'neighbours.mat'));

% stat 
for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    % exp freq
    load(fullfile(data_dir, ['exp_', conditions{ci}, '_bl_db.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    % nov ERP
    load(fullfile(data_dir, ['nov_', conditions{ci}, '_bl_db.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    % each band
    for bi = 1:length(bands)
        % statistics
        cfg = [];
        cfg.latency          = [0.0 0.6];
        cfg.frequency        = bands{bi, 1};
        cfg.method           = 'montecarlo';
        cfg.statistic        = 'indepsamplesT'; 
        cfg.correctm         = 'cluster';
        cfg.numrandomization = 10000;
        cfg.neighbours       = neighbours;
        % design
        n_trl_exp = size(freq_exp.powspctrm, 1);
        n_trl_nov = size(freq_nov.powspctrm, 1);
        cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
        cfg.ivar   = 1;
        stat = ft_freqstatistics(cfg, freq_exp, freq_nov);
    
        % save data
        save(fullfile(res_dir, [conditions{ci}, '_', bands{bi, 2}, '.mat']), 'stat', '-v7.3');
    end
end

%% figure - time x freq
clear;
config;

stat_data_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt'); % set data dir
freq_data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); 
res_dir = fullfile(prj_dir, 'result', 'fig_stat_freq_cbpt_tfr'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% stat 
for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    % exp freq
    load(fullfile(freq_data_dir, ['exp_', conditions{ci}, '_bl_db.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    % nov ERP
    load(fullfile(freq_data_dir, ['nov_', conditions{ci}, '_bl_db.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    % calculate mean of freq
    cfg = [];
    cfg.keeptrials = 'no';
    freq_exp = ft_freqdescriptives(cfg, freq_exp);
    freq_nov = ft_freqdescriptives(cfg, freq_nov);

    % calculate difference
    cfg = [];
    cfg.operation = 'x1 - x2';
    cfg.parameter = 'powspctrm';
    freq_diff = ft_math(cfg, freq_exp, freq_nov); % pos: exp, neg: nov

    % each band
    for bi = 1:length(bands)
        % select band 
        cfg = [];
        cfg.frequency   = bands{bi, 1};
        freq_diff_b = ft_selectdata(cfg, freq_diff);

        % load mask
        load(fullfile(stat_data_dir, [conditions{ci}, '_', bands{bi, 2}, '.mat'])); % include stat
        freq_diff_b.mask = stat.mask;

        % figure
        cfg = [];
        cfg.layout        = 'easycapM11.mat';
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'opacity';
        cfg.maskalpha     = 0;
        cfg.zlim      = 'maxabs';
        cfg.colorbar  = 'yes';

        fig = figure('Position', [100, 100, 1600, 1200]);
        ft_multiplotTFR(cfg, freq_diff_b);
        title([conditions{ci}, ' : ', bands{bi, 2}, ' (pos: exp, neg: nov)']);

        % save
        saveas(fig, fullfile(res_dir, [conditions{ci}, '_', bands{bi, 2}, '.jpg']));
        close(fig);
    end
end

%% figure - topo
clear;
config;

stat_data_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt'); % set data dir
freq_data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); 
res_dir = fullfile(prj_dir, 'result', 'fig_stat_freq_cbpt_topo'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% stat 
for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    % exp freq
    load(fullfile(freq_data_dir, ['exp_', conditions{ci}, '_bl_db.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    % nov ERP
    load(fullfile(freq_data_dir, ['nov_', conditions{ci}, '_bl_db.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    % calculate mean of freq
    cfg = [];
    cfg.keeptrials = 'no';
    freq_exp = ft_freqdescriptives(cfg, freq_exp);
    freq_nov = ft_freqdescriptives(cfg, freq_nov);

    % calculate difference
    cfg = [];
    cfg.operation = 'x1 - x2';
    cfg.parameter = 'powspctrm';
    freq_diff = ft_math(cfg, freq_exp, freq_nov); % pos: exp, neg: nov

    % each band
    for bi = 1:length(bands)
        % load mask
        load(fullfile(stat_data_dir, [conditions{ci}, '_', bands{bi, 2}, '.mat'])); % include stat

        for t = 0:0.05:0.55
            % select latency
            cfg = [];
            cfg.latency     = [t, t+0.05]; % t ~ 50ms
            cfg.frequency   = bands{bi, 1};
            freq_diff_b_t = ft_selectdata(cfg, freq_diff);

            cfg = [];
            cfg.latency     = [t, t+0.05]; % t ~ 50ms
            stat_b_t = ft_selectdata(cfg, stat);

            % add mask 
            freq_diff_b_t.mask = stat_b_t.mask;

            % figure
            cfg = [];
            cfg.layout        = 'easycapM11.mat';
            cfg.maskparameter = 'mask';
            cfg.maskstyle     = 'opacity';
            cfg.maskalpha     = 0;
            cfg.zlim      = 'maxabs';
            cfg.colorbar  = 'yes';
    
            fig = figure;
            ft_topoplotTFR(cfg, freq_diff_b_t);
            title([conditions{ci}, ' : ', bands{bi, 2}, ', ' num2str(t*1000), '-', num2str((t+0.05)*1000), ' (pos: exp, neg: nov)']);

            % save
            saveas(fig, fullfile(res_dir, [conditions{ci}, '_', bands{bi, 2}, '_', num2str(t*1000), '_', num2str((t+0.05)*1000), '.jpg']));
            close(fig);
        end
    end
end