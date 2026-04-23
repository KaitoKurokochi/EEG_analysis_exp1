% stat_freq_diff_cbpt.m
% Supplemental: CBPT testing Group x Condition interaction in frequency power.
% Per participant: TFR(nogo) - TFR(go), then compared 12 exp vs 12 nov.
% go = trialinfo 1 (ff) or 4 (ss); nogo = trialinfo 2 (fs) or 3 (sf).

%% Section 1: compute per-participant TFR and nogo-go differences
clear;
config;

prepro_dir = fullfile(prj_dir, 'result', 'prepro3');
res_dir    = fullfile(prj_dir, 'result', 'freq_per_subj');
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

for gi = 1:length(groups)
    for pi = 1:12
        fprintf('--- %s%d ---\n', groups{gi}, pi);
        data_go   = [];
        data_nogo = [];

        for si = 1:5
            id    = [groups{gi}, num2str(pi), '-', num2str(si)];
            fname = fullfile(prepro_dir, [id, '.mat']);
            if ~exist(fname, 'file'), continue; end

            load(fname); % loads 'data'

            cfg_go        = [];
            cfg_go.trials = find(data.trialinfo == 1 | data.trialinfo == 4);
            if ~isempty(cfg_go.trials)
                tmp = ft_selectdata(cfg_go, data);
                if isempty(data_go)
                    data_go = tmp;
                else
                    data_go = ft_appenddata([], data_go, tmp);
                end
            end

            cfg_nogo        = [];
            cfg_nogo.trials = find(data.trialinfo == 2 | data.trialinfo == 3);
            if ~isempty(cfg_nogo.trials)
                tmp = ft_selectdata(cfg_nogo, data);
                if isempty(data_nogo)
                    data_nogo = tmp;
                else
                    data_nogo = ft_appenddata([], data_nogo, tmp);
                end
            end
        end

        if isempty(data_go) || isempty(data_nogo)
            warning('Skipping %s%d: missing go or nogo data.', groups{gi}, pi);
            continue;
        end

        cfg_freq            = [];
        cfg_freq.method     = 'wavelet';
        cfg_freq.output     = 'pow';
        cfg_freq.keeptrials = 'no';
        cfg_freq.foi        = logspace(log10(3), log10(90), 30);
        cfg_freq.width      = logspace(log10(3), log10(30), 30);
        cfg_freq.toi        = round((data_go.time{1}(1) : 0.05 : data_go.time{1}(end)) * data_go.fsample) / data_go.fsample;

        freq_go   = ft_freqanalysis(cfg_freq, data_go);
        freq_nogo = ft_freqanalysis(cfg_freq, data_nogo);

        cfg_bl              = [];
        cfg_bl.baseline     = [-0.1 0.0];
        cfg_bl.baselinetype = 'db';
        freq_go   = ft_freqbaseline(cfg_bl, freq_go);
        freq_nogo = ft_freqbaseline(cfg_bl, freq_nogo);

        cfg_math           = [];
        cfg_math.operation = 'x1 - x2';
        cfg_math.parameter = 'powspctrm';
        freq_diff = ft_math(cfg_math, freq_nogo, freq_go);

        subj_id = [groups{gi}, num2str(pi)];
        save(fullfile(res_dir, [subj_id, '.mat']), 'freq_go', 'freq_nogo', 'freq_diff', '-v7.3');
        fprintf('  saved: %s\n', subj_id);
    end
end

%% Section 2: CBPT statistics
clear;
config;

subj_dir = fullfile(prj_dir, 'result', 'freq_per_subj');
res_dir  = fullfile(prj_dir, 'result', 'stat_freq_diff_cbpt');
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

load(fullfile(prj_dir, 'src', 'neighbours.mat'));

bands = { ...
    [4  7],   'Theta'; ...
    [7  13],  'alpha'; ...
    [13 30],  'beta'; ...
    [30 45],  'Low_gamma'; ...
    [60 90],  'High_gamma'};
n_bands = size(bands, 1);

freq_diff_exp = cell(1, 12);
freq_diff_nov = cell(1, 12);
for pi = 1:12
    s = load(fullfile(subj_dir, ['exp', num2str(pi), '.mat']));
    freq_diff_exp{pi} = s.freq_diff;
    s = load(fullfile(subj_dir, ['nov', num2str(pi), '.mat']));
    freq_diff_nov{pi} = s.freq_diff;
end

all_diffs = [freq_diff_exp, freq_diff_nov];

for bi = 1:n_bands
    fprintf('--- band: %s ---\n', bands{bi, 2});

    cfg                  = [];
    cfg.channel          = {'all', '-EOG'};
    cfg.parameter        = 'powspctrm';
    cfg.frequency        = bands{bi, 1};
    cfg.avgoverfreq      = 'yes';
    cfg.latency          = [0.0 0.5];
    cfg.method           = 'ft_statistics_montecarlo';
    cfg.statistic        = 'ft_statfun_indepsamplesT';
    cfg.correctm         = 'cluster';
    cfg.clusteralpha     = 0.01;
    cfg.clustertail      = 0;
    cfg.clusterstatistic = 'maxsum';
    cfg.clusterthreshold = 'nonparametric_common';
    cfg.minnbchan        = 3;
    cfg.tail             = 0;
    cfg.alpha            = 0.025;
    cfg.numrandomization = 10000;
    cfg.neighbours       = neighbours;
    cfg.computeprob      = 'yes';
    cfg.design           = [ones(1, 12), 2*ones(1, 12)];
    cfg.ivar             = 1;

    stat = ft_freqstatistics(cfg, all_diffs{:});
    save(fullfile(res_dir, [bands{bi, 2}, '.mat']), 'stat', '-v7.3');
    fprintf('  saved: %s\n', bands{bi, 2});
end

%% Section 3: compute color limits
clear;
config;

subj_dir = fullfile(prj_dir, 'result', 'freq_per_subj');
res_dir  = fullfile(prj_dir, 'result', 'stat_freq_diff_cbpt');

bands = { ...
    [4  7],   'Theta'; ...
    [7  13],  'alpha'; ...
    [13 30],  'beta'; ...
    [30 45],  'Low_gamma'; ...
    [60 90],  'High_gamma'};
n_bands = size(bands, 1);

times = 0:0.05:0.5;

freq_diff_exp = cell(1, 12);
freq_diff_nov = cell(1, 12);
for pi = 1:12
    s = load(fullfile(subj_dir, ['exp', num2str(pi), '.mat']));
    freq_diff_exp{pi} = s.freq_diff;
    s = load(fullfile(subj_dir, ['nov', num2str(pi), '.mat']));
    freq_diff_nov{pi} = s.freq_diff;
end

mx_abs_grp  = zeros(1, n_bands);
mx_abs_diff = zeros(1, n_bands);

for bi = 1:n_bands
    for t = times
        [avg_exp, avg_nov] = compute_group_avgs(freq_diff_exp, freq_diff_nov, bands{bi, 1}, t);

        mx_abs_grp(bi) = max(mx_abs_grp(bi), max(abs(avg_exp.powspctrm(:))));
        mx_abs_grp(bi) = max(mx_abs_grp(bi), max(abs(avg_nov.powspctrm(:))));

        cfg_m           = [];
        cfg_m.operation = 'x1 - x2';
        cfg_m.parameter = 'powspctrm';
        dd = ft_math(cfg_m, avg_exp, avg_nov);
        mx_abs_diff(bi) = max(mx_abs_diff(bi), max(abs(dd.powspctrm(:))));
    end
end

vals.bands       = bands;
vals.mx_abs_grp  = mx_abs_grp;
vals.mx_abs_diff = mx_abs_diff;
save(fullfile(res_dir, 'val.mat'), 'vals', '-v7.3');

%% Section 4: figure - topomap
% Layout per band (one PNG each):
%   Row 1 (Exp):      mean NoGo-Go diff
%   Row 2 (Nov):      mean NoGo-Go diff
%   Row 3 (Exp-Nov):  difference of diffs  (* = significant channels from CBPT)
%   Columns: 0, 50, 100, ..., 500 ms
clear;
config;

stat_dir = fullfile(prj_dir, 'result', 'stat_freq_diff_cbpt');
subj_dir = fullfile(prj_dir, 'result', 'freq_per_subj');
res_dir  = fullfile(prj_dir, 'result', 'fig_stat_freq_diff_cbpt_topo');
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

load(fullfile(stat_dir, 'val.mat'));

bands = { ...
    [4  7],   'Theta'; ...
    [7  13],  'alpha'; ...
    [13 30],  'beta'; ...
    [30 45],  'Low_gamma'; ...
    [60 90],  'High_gamma'};
n_bands = size(bands, 1);

times   = 0:0.05:0.5;
n_times = length(times);

freq_diff_exp = cell(1, 12);
freq_diff_nov = cell(1, 12);
for pi = 1:12
    s = load(fullfile(subj_dir, ['exp', num2str(pi), '.mat']));
    freq_diff_exp{pi} = s.freq_diff;
    s = load(fullfile(subj_dir, ['nov', num2str(pi), '.mat']));
    freq_diff_nov{pi} = s.freq_diff;
end

% layout constants (pixels)
topo_sz  = 220;
label_w  = 80;
title_h  = 40;
header_h = 34;
cb_w     = 55;
pad      = 8;

fig_w_px = label_w + n_times * topo_sz + cb_w + pad;
fig_h_px = title_h + header_h + 3 * topo_sz + pad;

disp('--- creating figures ---');
for bi = 1:n_bands
    band_name = bands{bi, 2};
    zlim_grp  = [-vals.mx_abs_grp(bi),  vals.mx_abs_grp(bi)];
    zlim_diff = [-vals.mx_abs_diff(bi), vals.mx_abs_diff(bi)];

    s = load(fullfile(stat_dir, [band_name, '.mat']));

    topo_imgs = cell(3, n_times);
    for ti = 1:n_times
        t = times(ti);

        [avg_exp, avg_nov] = compute_group_avgs(freq_diff_exp, freq_diff_nov, bands{bi, 1}, t);

        cfg_m           = [];
        cfg_m.operation = 'x1 - x2';
        cfg_m.parameter = 'powspctrm';
        d_dd = ft_math(cfg_m, avg_exp, avg_nov);

        [~, t_idx] = min(abs(s.stat.time - t));
        mask_t = s.stat.mask(:, t_idx);

        row_data  = {avg_exp,     avg_nov,     d_dd};
        row_zlims = {zlim_grp,    zlim_grp,    zlim_diff};
        row_masks = {logical([]), logical([]),  mask_t};

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

    for r = 1:3
        for ti = 1:n_times
            topo_imgs{r, ti} = imresize(topo_imgs{r, ti}, [topo_sz, topo_sz]);
        end
    end

    fig = figure('Visible', 'off', 'Units', 'pixels', ...
        'Position', [0, 0, fig_w_px, fig_h_px]);

    for r = 1:3
        for c = 1:n_times
            l  = (label_w + (c-1)*topo_sz) / fig_w_px;
            b  = (pad      + (3-r)*topo_sz) / fig_h_px;
            ax = axes('Position', [l, b, topo_sz/fig_w_px, topo_sz/fig_h_px]); %#ok<LAXES>
            image(ax, topo_imgs{r, c});
            axis(ax, 'off');
        end
    end

    for c = 1:n_times
        l = (label_w + (c-1)*topo_sz) / fig_w_px;
        b = (pad + 3*topo_sz)          / fig_h_px;
        annotation(fig, 'textbox', [l, b, topo_sz/fig_w_px, header_h/fig_h_px], ...
            'String', sprintf('%d ms', round(times(c)*1000)), ...
            'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', 9);
    end

    row_labels = {'Exp (NoGo-Go)', 'Nov (NoGo-Go)', 'Exp - Nov'};
    for r = 1:3
        b = (pad + (3-r)*topo_sz) / fig_h_px;
        annotation(fig, 'textbox', [0, b, label_w/fig_w_px, topo_sz/fig_h_px], ...
            'String', row_labels{r}, 'EdgeColor', 'none', 'Rotation', 90, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 11, 'FontWeight', 'bold');
    end

    annotation(fig, 'textbox', ...
        [label_w/fig_w_px, (pad+header_h+3*topo_sz)/fig_h_px, ...
         n_times*topo_sz/fig_w_px, title_h/fig_h_px], ...
        'String', sprintf('%s band – NoGo-Go (Group x Condition)', band_name), ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontSize', 13, 'FontWeight', 'bold');

    cb_l   = (label_w + n_times*topo_sz + 4) / fig_w_px;
    cb_w_n = (cb_w - 8) / fig_w_px;
    zlims_cb = {zlim_grp, zlim_grp, zlim_diff};
    for r = 1:3
        b_cb  = (pad + (3-r)*topo_sz) / fig_h_px;
        h_cb  = topo_sz / fig_h_px;
        ax_cb = axes('Position', [cb_l, b_cb, cb_w_n, h_cb], 'Visible', 'off'); %#ok<LAXES>
        colormap(ax_cb, jet(256));
        clim(ax_cb, zlims_cb{r});
        colorbar(ax_cb, 'Position', [cb_l, b_cb, cb_w_n, h_cb]);
    end

    out_path = fullfile(res_dir, [band_name, '.png']);
    exportgraphics(fig, out_path, 'Resolution', 150);
    close(fig);
    fprintf('Saved: %s\n', out_path);
end

disp('Done.');

% -----------------------------------------------------------------------
% local functions
% -----------------------------------------------------------------------

function [avg_exp, avg_nov] = compute_group_avgs(freq_diff_exp, freq_diff_nov, band, t)
    cfg_sel           = [];
    cfg_sel.frequency = band;
    cfg_sel.latency   = [t - 0.001, t + 0.001];

    cfg_avg            = [];
    cfg_avg.keeptrials = 'no';

    avg_exp = avg_at(freq_diff_exp, cfg_sel, cfg_avg);
    avg_nov = avg_at(freq_diff_nov, cfg_sel, cfg_avg);
end

function avg = avg_at(freq_cell, cfg_sel, cfg_avg)
    n   = length(freq_cell);
    tmp = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_cell{1}));
    pwr = tmp.powspctrm;
    for i = 2:n
        tmp2 = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_cell{i}));
        pwr  = pwr + tmp2.powspctrm;
    end
    avg           = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, freq_cell{1}));
    avg.powspctrm = pwr / n;
end
