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

% bands
bands = { ...
    % [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]};

% stat 
for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    % exp freq
    load(fullfile(data_dir, ['exp_', conditions{ci}, '.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    % nov ERP
    load(fullfile(data_dir, ['nov_', conditions{ci}, '.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    % each band, each time
    for bi = 1:length(bands)
        for t = 0:0.05:0.55
            % statistics
            cfg = [];
            cfg.channel          = {'all', '-EOG'};
            cfg.parameter        = 'powspctrm';
            cfg.method           = 'ft_statistics_montecarlo';
            cfg.statistic        = 'ft_statfun_indepsamplesT';
            cfg.correctm         = 'cluster';
            cfg.clusteralpha     = 0.05;
            cfg.clusterstatistic = 'maxsize';
            cfg.clusterthreshold = 'nonparametric_common';
            cfg.minnbchan        = 2;
            cfg.tail             = 0;
            cfg.clustertail      = 0;
            cfg.alpha            = 0.05;
            cfg.correcttail      = 'alpha';
            cfg.numrandomization = 10000;
            cfg.latency          = [t-0.001, t+0.001]; % t, around 2ms;
            cfg.frequency        = bands{bi, 1};
            cfg.numrandomization = 10000;
            cfg.neighbours       = neighbours;
            % design
            n_trl_exp = size(freq_exp.powspctrm, 1);
            n_trl_nov = size(freq_nov.powspctrm, 1);
            cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
            cfg.ivar   = 1;
            stat = ft_freqstatistics(cfg, freq_exp, freq_nov);
        
            % save data
            save(fullfile(res_dir, [conditions{ci}, '_', bands{bi, 2}, '_', num2str(t*1000), '.mat']), 'stat', '-v7.3');
        end
    end
end

%% get maxmin of frequency power
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% bands
bands = { ...
    % [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]};

mx_abs = zeros(1, length(bands));
mx = -inf(1, length(bands));
mn = inf(1, length(bands));
for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    % exp freq
    load(fullfile(data_dir, ['exp_', conditions{ci}, '.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    % nov ERP
    load(fullfile(data_dir, ['nov_', conditions{ci}, '.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    % each band, each time
    for bi = 1:length(bands)
        for t = 0:0.05:0.55
            % extract data (band, time) 
            cfg = [];
            cfg.frequency   = bands{bi, 1};
            cfg.latency     = [t-0.001, t+0.001]; % t, around 2ms;
            freq_exp_b_t = ft_selectdata(cfg, freq_exp);
            freq_nov_b_t = ft_selectdata(cfg, freq_nov);

            % calculate average
            freq_exp_b_t_avg = ft_freqdescriptives([], freq_exp_b_t);
            freq_nov_b_t_avg = ft_freqdescriptives([], freq_nov_b_t);

            % calculate difference
            cfg = [];
            cfg.operation = 'x1 - x2';
            cfg.parameter = 'powspctrm';
            freq_diff = ft_math(cfg, freq_exp_b_t_avg, freq_nov_b_t_avg); % pos: exp, neg: nov

            mx_abs(bi) = max(mx_abs(bi), max(abs(freq_diff.powspctrm(:))));
            mx(bi) = max(mx(bi), max(freq_diff.powspctrm(:)));
            mn(bi) = min(mn(bi), min(freq_diff.powspctrm(:)));
        end
    end
end

vals = [];
vals.bands = bands;
vals.mx_abs = mx_abs;
vals.mx = mx;
vals.mn = mn;

save(fullfile(res_dir, 'val.mat'), 'vals', '-v7.3');

%% figure - topo
clear;
config;

stat_data_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt'); % set data dir
freq_data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); 
res_dir = fullfile(prj_dir, 'result', 'fig_stat_freq_cbpt_topo'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

load(fullfile(stat_data_dir, 'val.mat'));
% bands
bands = { ...
    % [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]};

% stat 
for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    % exp freq
    load(fullfile(freq_data_dir, ['exp_', conditions{ci}, '.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    % nov ERP
    load(fullfile(freq_data_dir, ['nov_', conditions{ci}, '.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    % each band, each time
    for bi = 1:length(bands)
        for t = 0:0.05:0.55
            % extract data (band, time) 
            cfg = [];
            cfg.frequency   = bands{bi, 1};
            cfg.latency     = [t-0.001, t+0.001]; % t, around 2ms;
            freq_exp_b_t = ft_selectdata(cfg, freq_exp);
            freq_nov_b_t = ft_selectdata(cfg, freq_nov);

            % calculate average
            cfg = [];
            cfg.keeptrials    = 'no';
            freq_exp_b_t_avg = ft_freqdescriptives(cfg, freq_exp_b_t);
            freq_nov_b_t_avg = ft_freqdescriptives(cfg, freq_nov_b_t);

            % calculate difference
            cfg = [];
            cfg.operation = 'x1 - x2';
            cfg.parameter = 'powspctrm';
            freq_diff = ft_math(cfg, freq_exp_b_t_avg, freq_nov_b_t_avg); % pos: exp, neg: nov

            % load stat data
            load(fullfile(stat_data_dir, [conditions{ci}, '_', bands{bi, 2}, '_', num2str(t*1000), '.mat'])); % include stat

            % figure
            cfg = [];
            cfg.colorbar           = 'yes';
            cfg.layout             = 'easycapM11.mat';
            cfg.colormap           = 'jet';
            cfg.zlim               = [-vals.mx_abs(bi), vals.mx_abs(bi)];
            % diff
            cfg.highlight          = 'on';
            cfg.highlightchannel   = find(stat.mask);
            cfg.highlightsymbol    = '*';
            cfg.highlightcolor     = [0 0 0];
            cfg.highlightsize      = 10;
            cfg.highlightfontsize  = 12;
    
            fig = figure('Visible', 'off');
            ft_topoplotTFR(cfg, freq_diff);
            title([conditions{ci}, ' : ', bands{bi, 2}, ', ' num2str(t*1000) ' (pos: exp, neg: nov)']);

            % save
            saveas(fig, fullfile(res_dir, [conditions{ci}, '_', bands{bi, 2}, '_', num2str(t*1000) '.jpg']));
            close(fig);
        end
    end
end