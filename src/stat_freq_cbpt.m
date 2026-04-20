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
        for t = 0:0.05:0.5
            % statistics
            cfg = [];
            cfg.channel          = {'all', '-EOG'};
            cfg.parameter        = 'powspctrm';
            cfg.method           = 'ft_statistics_montecarlo';
            cfg.statistic        = 'ft_statfun_indepsamplesT';
            cfg.correctm         = 'cluster';
            cfg.clusteralpha     = 0.01;
            cfg.clustertail      = 0;
            cfg.clusterstatistic = 'maxsum';
            cfg.clusterthreshold = 'nonparametric_common';
            cfg.minnbchan        = 2;
            cfg.tail             = 0;
            cfg.alpha            = 0.025; % for two-sided test
            cfg.numrandomization = 10000;
            cfg.latency          = [t-0.001, t+0.001]; % t, around 2ms;
            cfg.frequency        = bands{bi, 1};
            cfg.numrandomization = 10000;
            cfg.neighbours       = neighbours;
            cfg.computeprob      = 'yes';
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
        for t = 0:0.05:0.5
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

times = 0:0.05:0.5;
n_times = length(times);

% prevent any figure from becoming visible (ft_topoplotTFR may call figure internally)
set(0, 'DefaultFigureVisible', 'off');

for ci = 1:length(conditions)
    % read data
    disp('--- loading freq data ---');
    load(fullfile(freq_data_dir, ['exp_', conditions{ci}, '.mat'])); % include freq
    freq_exp = freq;
    clear freq;
    load(fullfile(freq_data_dir, ['nov_', conditions{ci}, '.mat'])); % include freq
    freq_nov = freq;
    clear freq;

    for bi = 1:length(bands)
        fig = figure('Position', [0 0 n_times*180 220]);

        % pre-calculate subplot positions with room for colorbar
        sp_pos = zeros(n_times, 4);
        for ti = 1:n_times
            ax = subplot(1, n_times, ti, 'Parent', fig);
            pos = get(ax, 'Position');
            pos(3) = pos(3) * 0.85;
            sp_pos(ti,:) = pos;
            delete(ax);
        end

        for ti = 1:n_times
            t = times(ti);

            % extract data (band, time)
            cfg = [];
            cfg.frequency = bands{bi, 1};
            cfg.latency   = [t-0.001, t+0.001];
            freq_exp_b_t = ft_selectdata(cfg, freq_exp);
            freq_nov_b_t = ft_selectdata(cfg, freq_nov);

            % calculate average
            cfg = [];
            cfg.keeptrials = 'no';
            freq_exp_b_t_avg = ft_freqdescriptives(cfg, freq_exp_b_t);
            freq_nov_b_t_avg = ft_freqdescriptives(cfg, freq_nov_b_t);

            % calculate difference
            cfg = [];
            cfg.operation = 'x1 - x2';
            cfg.parameter = 'powspctrm';
            freq_diff = ft_math(cfg, freq_exp_b_t_avg, freq_nov_b_t_avg); % pos: exp, neg: nov

            % load stat data
            load(fullfile(stat_data_dir, [conditions{ci}, '_', bands{bi, 2}, '_', num2str(t*1000), '.mat']));

            % draw into temporary figure (ft_topoplotTFR doesn't work well inside subplot directly)
            tmp_fig = figure();
            cfg = [];
            cfg.colorbar           = 'no';
            cfg.layout             = 'easycapM11.mat';
            cfg.colormap           = 'jet';
            cfg.zlim               = [-vals.mx_abs(bi), vals.mx_abs(bi)];
            cfg.comment            = 'no';
            cfg.title              = ' ';
            cfg.highlight          = 'on';
            cfg.highlightchannel   = find(stat.mask);
            cfg.highlightsymbol    = '*';
            cfg.highlightcolor     = [0 0 0];
            cfg.highlightsize      = 6;
            ft_topoplotTFR(cfg, freq_diff);

            % copy axes into main figure and reposition
            new_ax = copyobj(gca, fig);
            set(new_ax, 'Position', sp_pos(ti,:));
            title(new_ax, sprintf('%d ms', round(t*1000)));
            close(tmp_fig);
        end

        % add colorbar on the far right
        ax_cb = axes('Parent', fig, 'Position', [0.94, 0.15, 0.01, 0.7], 'Visible', 'off');
        colormap(ax_cb, jet);
        set(ax_cb, 'CLim', [-vals.mx_abs(bi), vals.mx_abs(bi)]);
        cb = colorbar(ax_cb);
        cb.Position = [0.94, 0.15, 0.02, 0.7];

        saveas(fig, fullfile(res_dir, [conditions{ci}, '_', bands{bi, 2}, '.jpg']));
        close(fig);
    end
end

set(0, 'DefaultFigureVisible', 'on');