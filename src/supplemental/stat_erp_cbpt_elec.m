% stat_erp_cbpt_elec: cluster-based permutation test of ERP per electrode
% For each condition x electrode, collect all trials and compare exp vs nov.
% Temporal clustering only (single channel, no spatial neighbours required).

clear;
config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
res_dir  = fullfile(prj_dir, 'result', 'stat_erp_cbpt_elec');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for ci = 1:length(conditions)
    disp(['=== Condition: ', conditions{ci}, ' ===']);

    load(fullfile(data_dir, ['exp_', conditions{ci}, '.mat'])); data_exp_all = data; clear data;
    load(fullfile(data_dir, ['nov_', conditions{ci}, '.mat'])); data_nov_all = data; clear data;

    for chi = 1:length(data_exp_all.label)
        chan = data_exp_all.label{chi};
        disp(['  Channel: ', chan]);

        % select single channel and time window
        cfg_sel          = [];
        cfg_sel.channel  = {chan};
        cfg_sel.latency  = [0.0 0.5];
        data_exp = ft_selectdata(cfg_sel, data_exp_all);
        data_nov = ft_selectdata(cfg_sel, data_nov_all);

        % dummy neighbours for single channel (no spatial clustering)
        nb = struct('label', chan, 'neighblabel', {{}});

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
        cfg.minnbchan        = 0;
        cfg.tail             = 0;
        cfg.alpha            = 0.025;
        cfg.numrandomization = 10000;
        cfg.neighbours       = nb;
        cfg.computeprob      = 'yes';
        n_exp = size(data_exp.trial, 2);
        n_nov = size(data_nov.trial, 2);
        cfg.design = [ones(1, n_exp), 2*ones(1, n_nov)];
        cfg.ivar   = 1;
        stat = ft_timelockstatistics(cfg, data_exp, data_nov);
        stat.channel   = chan;
        stat.condition = conditions{ci};

        save(fullfile(res_dir, [conditions{ci}, '_', chan, '.mat']), 'stat', '-v7.3');
    end
end

%% figure: ERP per electrode with significance mask
clear;
config;

data_erp_dir  = fullfile(prj_dir, 'result', 'erp_group_cond');
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt_elec');
res_dir       = fullfile(prj_dir, 'result', 'fig_stat_erp_cbpt_elec');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

alpha = 0.05;

for ci = 1:length(conditions)
    disp(['=== Condition: ', conditions{ci}, ' ===']);

    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); data_nov_all = data; clear data;

    for chi = 1:length(data_exp_all.label)
        chan      = data_exp_all.label{chi};
        stat_file = fullfile(data_stat_dir, [conditions{ci}, '_', chan, '.mat']);

        if ~exist(stat_file, 'file')
            warning('Stat file not found for %s, condition %s. Skipping.', chan, conditions{ci});
            continue;
        end

        load(stat_file); % loads: stat

        % check if any significant cluster exists
        has_sig = false;
        if ~isempty(stat.posclusters) && any([stat.posclusters.prob] < alpha)
            has_sig = true;
        end
        if ~isempty(stat.negclusters) && any([stat.negclusters.prob] < alpha)
            has_sig = true;
        end

        % select channel and compute mean ERP
        cfg_sel         = [];
        cfg_sel.channel = {chan};
        cfg_sel.latency = [0.0 0.5];
        data_exp = ft_selectdata(cfg_sel, data_exp_all);
        data_nov = ft_selectdata(cfg_sel, data_nov_all);
        data_exp = ft_timelockanalysis([], data_exp);
        data_nov = ft_timelockanalysis([], data_nov);

        % attach significance mask
        data_exp.mask = stat.mask; % 1 x time logical

        % plot
        fig = figure('Visible', 'off');

        cfg               = [];
        cfg.channel       = chan;
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'box';
        cfg.maskfacealpha = 0.2;
        cfg.linewidth     = 1.5;
        cfg.linecolor     = 'br';
        cfg.title         = [chan, ' - ', conditions{ci}];

        ft_singleplotER(cfg, data_exp, data_nov);

        h = findobj(gca, 'Type', 'line');
        if length(h) >= 2
            legend(h(end:-1:1), {'Exp', 'Nov'}, 'Location', 'eastoutside');
        end

        xlabel('Time (s)');
        ylabel('Amplitude (uV)');
        grid on;
        set(gca, 'FontSize', 14);

        if has_sig
            title([chan, ' - ', conditions{ci}, ' *']);
        end

        save_name = fullfile(res_dir, [conditions{ci}, '_', chan, '.jpg']);
        saveas(fig, save_name);
        close(fig);

        disp(['  ', chan, ' saved.']);
    end
end
