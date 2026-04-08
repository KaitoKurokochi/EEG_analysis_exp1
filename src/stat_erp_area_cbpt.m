% statistics: cluster-based permutation test of ERP for each condition
% divided by anatomical area (based on Koessler 2009)

clear;
config;

data_erp_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
res_dir      = fullfile(prj_dir, 'result', 'stat_erp_area_cbpt');

if ~exist(res_dir, 'dir'); mkdir(res_dir); end

% load shared resources
load(fullfile(prj_dir, 'src', 'neighbours.mat'));    % neighbours
load(fullfile(prj_dir, 'src', 'area_map.mat'));      % area_map

% build area name -> channel list mapping from area_map
chan_names  = fieldnames(area_map);
area_names  = cellfun(@(c) area_map.(c), chan_names, 'UniformOutput', false);
area_list   = unique(area_names);  % unique area names

% statistics - erp cbpt
for ci = 1:length(conditions)
    disp(['=== Condition: ', conditions{ci}, ' ===']);

    % load trial-level ERP data
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); data_nov_all = data; clear data;

    for ai = 1:length(area_list)
        area  = area_list{ai};
        chans = chan_names(strcmp(area_names, area));  % channels belonging to this area
        disp(['  ', area, '  (', num2str(length(chans)), ' channels)']);

        % use only channels present in data
        valid_chans = intersect(chans, data_exp_all.label);
        if isempty(valid_chans)
            warning('No valid channels for %s in condition %s. Skipping.', area, conditions{ci});
            continue;
        end

        % channel selection and average across channels
        cfg_sel             = [];
        cfg_sel.channel     = valid_chans;
        cfg_sel.latency     = [0.0 0.5];
        cfg_sel.avgoverchan = 'yes';
        data_exp = ft_selectdata(cfg_sel, data_exp_all);
        data_nov = ft_selectdata(cfg_sel, data_nov_all);

        % rename label to area name
        data_exp.label = {area};
        data_nov.label = {area};

        % neighbours: single virtual channel has no neighbours
        nb_area = struct('label', {area}, 'neighblabel', {{}});

        % CBPT
        cfg                  = [];
        cfg.latency          = [0.0 0.5];
        cfg.method           = 'ft_statistics_montecarlo';
        cfg.statistic        = 'ft_statfun_indepsamplesT';
        cfg.correctm         = 'cluster';
        cfg.clusteralpha     = 0.01;
        cfg.clustertail      = 0;
        cfg.clusterstatistic = 'maxsum';
        cfg.clusterthreshold = 'nonparametric_common';
        cfg.minnbchan        = 0;  % single channel, no neighbours required
        cfg.tail             = 0;
        cfg.alpha            = 0.025;
        cfg.numrandomization = 10000;
        cfg.neighbours       = nb_area;
        cfg.computeprob      = 'yes';
        n_exp = size(data_exp.trial, 2);
        n_nov = size(data_nov.trial, 2);
        cfg.design = [ones(1, n_exp), 2*ones(1, n_nov)];
        cfg.ivar   = 1;
        stat = ft_timelockstatistics(cfg, data_exp, data_nov);
        stat.area      = area;
        stat.condition = conditions{ci};
        stat.channels  = valid_chans;
        save(fullfile(res_dir, [conditions{ci}, '_', area, '.mat']), 'stat', '-v7.3');
    end
end

%% figure: ERP per area with significance mask
clear;
config;

data_erp_dir  = fullfile(prj_dir, 'result', 'erp_group_cond');
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_area_cbpt');
res_dir       = fullfile(prj_dir, 'result', 'fig_stat_erp_area_cbpt');
if ~exist(res_dir, 'dir'); mkdir(res_dir); end

load(fullfile(prj_dir, 'src', 'area_map.mat'));  % area_map
chan_names = fieldnames(area_map);
area_names = cellfun(@(c) area_map.(c), chan_names, 'UniformOutput', false);
area_list  = unique(area_names);

for ci = 1:length(conditions)
    disp(['=== Condition: ', conditions{ci}, ' ===']);

    % load trial-level ERP data
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); data_nov_all = data; clear data;

    for ai = 1:length(area_list)
        area      = area_list{ai};
        stat_file = fullfile(data_stat_dir, [conditions{ci}, '_', area, '.mat']);

        if ~exist(stat_file, 'file')
            warning('Stat file not found for %s, condition %s. Skipping.', area, conditions{ci});
            continue;
        end

        load(stat_file);  % loads: stat

        valid_chans = stat.channels;
        if isempty(valid_chans); continue; end

        % channel average
        cfg_sel             = [];
        cfg_sel.channel     = valid_chans;
        cfg_sel.latency     = [0.0 0.5];
        cfg_sel.avgoverchan = 'yes';
        data_exp = ft_selectdata(cfg_sel, data_exp_all);
        data_nov = ft_selectdata(cfg_sel, data_nov_all);

        % compute mean ERP across trials
        data_exp = ft_timelockanalysis([], data_exp);
        data_nov = ft_timelockanalysis([], data_nov);

        % rename label and attach mask
        data_exp.label = {area};
        data_nov.label = {area};
        data_exp.mask  = stat.mask;  % 1 x time

        % plot
        fig = figure('Visible', 'off');

        cfg               = [];
        cfg.channel       = area;
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'box';
        cfg.maskfacealpha = 0.2;
        cfg.linewidth     = 1.5;
        cfg.linecolor     = 'br';
        cfg.title         = [strrep(area, '_', ' '), ' - ', conditions{ci}];

        ft_singleplotER(cfg, data_exp, data_nov);

        h = findobj(gca, 'Type', 'line');
        if length(h) >= 2
            legend(h(end:-1:1), {'Exp', 'Nov'}, 'Location', 'eastoutside');
        end

        xlabel('Time (s)');
        ylabel('Amplitude (uV)');
        grid on;
        set(gca, 'FontSize', 14);

        save_name = fullfile(res_dir, [conditions{ci}, '_', area, '.jpg']);
        saveas(fig, save_name);
        close(fig);

        disp(['  ', area, ' saved.']);
    end
end