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
% Layout per band x condition (one PNG each):
%   Row 1: Exp power
%   Row 2: Nov power
%   Row 3: Exp - Nov diff  (* = significant channels from CBPT)
%   Columns: 0, 50, 100, ..., 500 ms
clear;
config;

stat_data_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt');
freq_data_dir = fullfile(prj_dir, 'result', 'freq_group_cond');
res_dir       = fullfile(prj_dir, 'result', 'fig_stat_freq_cbpt_topo');
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

load(fullfile(stat_data_dir, 'val.mat'));

bands = { ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',       [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]};
n_bands = size(bands, 1);

times   = 0:0.05:0.5;
n_times = length(times);

% layout constants (pixels)
topo_sz  = 220;
label_w  = 80;
title_h  = 40;
header_h = 34;
cb_w     = 55;
pad      = 8;

fig_w_px = label_w + n_times * topo_sz + cb_w + pad;
fig_h_px = title_h + header_h + 3 * topo_sz + pad;

% compute per-band color limits for Exp and Nov rows
disp('--- computing color limits ---');
mx_abs_grp = zeros(1, n_bands);
for ci = 1:length(conditions)
    load(fullfile(freq_data_dir, ['exp_', conditions{ci}, '.mat'])); freq_exp = freq; clear freq;
    load(fullfile(freq_data_dir, ['nov_', conditions{ci}, '.mat'])); freq_nov = freq; clear freq;
    for bi = 1:n_bands
        for t = times
            cfg_sel           = [];
            cfg_sel.frequency = bands{bi, 1};
            cfg_sel.latency   = [t-0.001, t+0.001];
            cfg_avg            = [];
            cfg_avg.keeptrials = 'no';
            avg_exp = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_exp));
            avg_nov = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_nov));
            mx_abs_grp(bi) = max(mx_abs_grp(bi), max(abs(avg_exp.powspctrm(:))));
            mx_abs_grp(bi) = max(mx_abs_grp(bi), max(abs(avg_nov.powspctrm(:))));
        end
    end
end

disp('--- creating figures ---');
for ci = 1:length(conditions)
    load(fullfile(freq_data_dir, ['exp_', conditions{ci}, '.mat'])); freq_exp = freq; clear freq;
    load(fullfile(freq_data_dir, ['nov_', conditions{ci}, '.mat'])); freq_nov = freq; clear freq;

    for bi = 1:n_bands
        zlim_grp  = [-mx_abs_grp(bi),  mx_abs_grp(bi)];
        zlim_diff = [-vals.mx_abs(bi),  vals.mx_abs(bi)];

        % capture topomaps into images (off-screen)
        topo_imgs = cell(3, n_times);
        for ti = 1:n_times
            t = times(ti);

            cfg_sel           = [];
            cfg_sel.frequency = bands{bi, 1};
            cfg_sel.latency   = [t-0.001, t+0.001];
            cfg_avg            = [];
            cfg_avg.keeptrials = 'no';
            avg_exp  = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_exp));
            avg_nov  = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_nov));
            cfg_math           = [];
            cfg_math.operation = 'x1 - x2';
            cfg_math.parameter = 'powspctrm';
            freq_diff = ft_math(cfg_math, avg_exp, avg_nov);

            s = load(fullfile(stat_data_dir, ...
                [conditions{ci}, '_', bands{bi, 2}, '_', num2str(t*1000), '.mat']));

            row_data  = {avg_exp,      avg_nov,      freq_diff};
            row_zlims = {zlim_grp,     zlim_grp,     zlim_diff};
            row_masks = {logical([]),  logical([]),   s.stat.mask};

            for r = 1:3
                fig_tmp = figure('Visible', 'off', 'Units', 'pixels', ...
                    'Position', [0 0 topo_sz topo_sz]);
                cfg_t          = [];
                cfg_t.colorbar = 'no';
                cfg_t.layout   = 'easycapM11.mat';
                cfg_t.colormap = 'jet';
                cfg_t.zlim     = row_zlims{r};
                cfg_t.comment  = 'no';
                cfg_t.title    = ' ';
                if any(row_masks{r}(:))
                    cfg_t.highlight        = 'on';
                    cfg_t.highlightchannel = find(row_masks{r});
                    cfg_t.highlightsymbol  = '*';
                    cfg_t.highlightcolor   = [0 0 0];
                else
                    cfg_t.highlight = 'off';
                end
                ft_topoplotTFR(cfg_t, row_data{r});
                topo_imgs{r, ti} = print(fig_tmp, '-RGBImage');
                close(fig_tmp);
            end
        end

        % resize to exact topo_sz
        for r = 1:3
            for ti = 1:n_times
                topo_imgs{r, ti} = imresize(topo_imgs{r, ti}, [topo_sz, topo_sz]);
            end
        end

        % assemble composite figure
        fig = figure('Visible', 'off', 'Units', 'pixels', ...
            'Position', [0, 0, fig_w_px, fig_h_px]);

        for r = 1:3
            for c = 1:n_times
                l = (label_w + (c-1)*topo_sz) / fig_w_px;
                b = (pad      + (3-r)*topo_sz) / fig_h_px;
                w = topo_sz / fig_w_px;
                h = topo_sz / fig_h_px;
                ax = axes('Position', [l, b, w, h]); %#ok<LAXES>
                image(ax, topo_imgs{r, c});
                axis(ax, 'off');
            end
        end

        % time labels
        for c = 1:n_times
            l = (label_w + (c-1)*topo_sz) / fig_w_px;
            b = (pad + 3*topo_sz)          / fig_h_px;
            annotation(fig, 'textbox', [l, b, topo_sz/fig_w_px, header_h/fig_h_px], ...
                'String', sprintf('%d ms', round(times(c)*1000)), ...
                'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'FontSize', 9);
        end

        % row labels
        row_labels = {'Exp', 'Nov', 'Exp - Nov'};
        for r = 1:3
            b = (pad + (3-r)*topo_sz) / fig_h_px;
            annotation(fig, 'textbox', [0, b, label_w/fig_w_px, topo_sz/fig_h_px], ...
                'String', row_labels{r}, 'EdgeColor', 'none', 'Rotation', 90, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', 11, 'FontWeight', 'bold');
        end

        % title
        annotation(fig, 'textbox', ...
            [label_w/fig_w_px, (pad+header_h+3*topo_sz)/fig_h_px, ...
             n_times*topo_sz/fig_w_px, title_h/fig_h_px], ...
            'String', sprintf('%s band – %s', bands{bi,2}, conditions{ci}), ...
            'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', 13, 'FontWeight', 'bold');

        % colorbars (Exp/Nov share one zlim, Diff has its own)
        cb_l     = (label_w + n_times*topo_sz + 4) / fig_w_px;
        cb_w_n   = (cb_w - 8) / fig_w_px;
        zlims_cb = {zlim_grp, zlim_grp, zlim_diff};
        for r = 1:3
            b_cb  = (pad + (3-r)*topo_sz) / fig_h_px;
            h_cb  = topo_sz / fig_h_px;
            ax_cb = axes('Position', [cb_l, b_cb, cb_w_n, h_cb], 'Visible', 'off'); %#ok<LAXES>
            colormap(ax_cb, jet(256));
            clim(ax_cb, zlims_cb{r});
            colorbar(ax_cb, 'Position', [cb_l, b_cb, cb_w_n, h_cb]);
        end

        out_path = fullfile(res_dir, [conditions{ci}, '_', bands{bi,2}, '.png']);
        exportgraphics(fig, out_path, 'Resolution', 150);
        close(fig);
        fprintf('Saved: %s\n', out_path);
    end
end

disp('Done.');