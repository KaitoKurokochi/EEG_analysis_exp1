% fig_freq_per_subj_topo.m
% Per-participant TFR topomaps (go / nogo / nogo-go diff) across time.
% Z-axis is shared across all participants within each frequency band.
% Requires result/freq_per_subj/ from stat_freq_diff_cbpt.m Section 1.

%% Section 1: compute shared color limits
clear;
config;

subj_dir = fullfile(prj_dir, 'result', 'freq_per_subj');
res_dir  = fullfile(prj_dir, 'result', 'fig_freq_per_subj_topo');
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

bands = { ...
    [4  7],   'Theta'; ...
    [7  13],  'alpha'; ...
    [13 30],  'beta'; ...
    [30 45],  'Low_gamma'; ...
    [60 90],  'High_gamma'};
n_bands = size(bands, 1);

times = 0:0.05:0.5;

mx_abs_cond = zeros(1, n_bands);
mx_abs_diff = zeros(1, n_bands);

for gi = 1:length(groups)
    for pi = 1:12
        fname = fullfile(subj_dir, [groups{gi}, num2str(pi), '.mat']);
        if ~exist(fname, 'file'), continue; end
        fprintf('limits: %s%d\n', groups{gi}, pi);
        s = load(fname);

        cfg_avg            = [];
        cfg_avg.keeptrials = 'no';

        for bi = 1:n_bands
            for t = times
                cfg_sel           = [];
                cfg_sel.frequency = bands{bi, 1};
                cfg_sel.latency   = [t - 0.001, t + 0.001];

                avg_go   = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, s.freq_go));
                avg_nogo = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, s.freq_nogo));
                avg_diff = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, s.freq_diff));

                mx_abs_cond(bi) = max(mx_abs_cond(bi), max(abs(avg_go.powspctrm(:))));
                mx_abs_cond(bi) = max(mx_abs_cond(bi), max(abs(avg_nogo.powspctrm(:))));
                mx_abs_diff(bi) = max(mx_abs_diff(bi), max(abs(avg_diff.powspctrm(:))));
            end
        end
    end
end

vals.bands       = bands;
vals.mx_abs_cond = mx_abs_cond;
vals.mx_abs_diff = mx_abs_diff;
save(fullfile(res_dir, 'val.mat'), 'vals', '-v7.3');
disp('Color limits saved.');

%% Section 2: generate figures
% Output: result/fig_freq_per_subj_topo/{group}{pi}_{band}.png
%   Row 1: Go
%   Row 2: NoGo
%   Row 3: Go - NoGo
%   Columns: 0, 50, 100, ..., 500 ms
clear;
config;

subj_dir = fullfile(prj_dir, 'result', 'freq_per_subj');
res_dir  = fullfile(prj_dir, 'result', 'fig_freq_per_subj_topo');
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

load(fullfile(res_dir, 'val.mat'));

bands = { ...
    [4  7],   'Theta'; ...
    [7  13],  'alpha'; ...
    [13 30],  'beta'; ...
    [30 45],  'Low_gamma'; ...
    [60 90],  'High_gamma'};
n_bands = size(bands, 1);

times   = 0:0.05:0.5;
n_times = length(times);

topo_sz  = 220;
label_w  = 80;
title_h  = 40;
header_h = 34;
cb_w     = 55;
pad      = 8;

fig_w_px = label_w + n_times * topo_sz + cb_w + pad;
fig_h_px = title_h + header_h + 3 * topo_sz + pad;

cfg_avg            = [];
cfg_avg.keeptrials = 'no';

for gi = 1:length(groups)
    for pi = 1:12
        subj_id = [groups{gi}, num2str(pi)];
        fname   = fullfile(subj_dir, [subj_id, '.mat']);
        if ~exist(fname, 'file'), continue; end
        fprintf('--- %s ---\n', subj_id);
        s = load(fname);

        for bi = 1:n_bands
            band_name = bands{bi, 2};
            zlim_cond = [-vals.mx_abs_cond(bi), vals.mx_abs_cond(bi)];
            zlim_diff = [-vals.mx_abs_diff(bi),  vals.mx_abs_diff(bi)];

            topo_imgs = cell(3, n_times);
            for ti = 1:n_times
                t = times(ti);

                cfg_sel           = [];
                cfg_sel.frequency = bands{bi, 1};
                cfg_sel.latency   = [t - 0.001, t + 0.001];

                avg_go   = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, s.freq_go));
                avg_nogo = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, s.freq_nogo));
                avg_diff = ft_freqdescriptives(cfg_avg, ft_selectdata(cfg_sel, s.freq_diff));
                avg_diff.powspctrm = -avg_diff.powspctrm; % flip to Go - NoGo

                row_data  = {avg_go,    avg_nogo,   avg_diff};
                row_zlims = {zlim_cond, zlim_cond,  zlim_diff};

                for r = 1:3
                    fig_tmp = figure('Visible', 'off', 'Units', 'pixels', ...
                        'Position', [0 0 topo_sz topo_sz]);
                    cfg_t           = [];
                    cfg_t.colorbar  = 'no';
                    cfg_t.layout    = 'easycapM11.mat';
                    cfg_t.colormap  = 'jet';
                    cfg_t.zlim      = row_zlims{r};
                    cfg_t.comment   = 'no';
                    cfg_t.title     = ' ';
                    cfg_t.highlight = 'off';
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

            row_labels = {'Go', 'NoGo', 'Go - NoGo'};
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
                'String', sprintf('%s – %s band', subj_id, band_name), ...
                'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'FontSize', 13, 'FontWeight', 'bold');

            cb_l   = (label_w + n_times*topo_sz + 4) / fig_w_px;
            cb_w_n = (cb_w - 8) / fig_w_px;
            zlims_cb = {zlim_cond, zlim_cond, zlim_diff};
            for r = 1:3
                b_cb  = (pad + (3-r)*topo_sz) / fig_h_px;
                h_cb  = topo_sz / fig_h_px;
                ax_cb = axes('Position', [cb_l, b_cb, cb_w_n, h_cb], 'Visible', 'off'); %#ok<LAXES>
                colormap(ax_cb, jet(256));
                clim(ax_cb, zlims_cb{r});
                colorbar(ax_cb, 'Position', [cb_l, b_cb, cb_w_n, h_cb]);
            end

            out_path = fullfile(res_dir, [subj_id, '_', band_name, '.png']);
            exportgraphics(fig, out_path, 'Resolution', 150);
            close(fig);
            fprintf('  saved: %s_%s\n', subj_id, band_name);
        end
    end
end

disp('Done.');
