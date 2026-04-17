l% statistics: cluster-based permutation test of ERP for each condition 
% divided by BA (cite:
% https://www.sciencedirect.com/science/article/pii/S1053811909001475)

clear;
config;

data_erp_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
res_dir      = fullfile(prj_dir, 'result', 'stat_erp_ba_cbpt');
 
if ~exist(res_dir, 'dir'); mkdir(res_dir); end
 
% load shared resources
load(fullfile(prj_dir, 'src', 'neighbours.mat'));   % neighbours
load(fullfile(prj_dir, 'src', 'chan_ba_map.mat'));  % include ba_map
% build BA number -> channel list mapping from ba_map
chan_names = fieldnames(ba_map);
ba_nums    = cellfun(@(c) ba_map.(c), chan_names);  % BA number for each channel
ba_list    = unique(ba_nums);                        % unique BA numbers

% statistics - erp cbpt
for ci = 1:length(conditions)
    disp(['=== Condition: ', conditions{ci}, ' ===']);
 
    % load trial-level ERP data
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); data_nov_all = data; clear data;
 
    for bi = 1:length(ba_list)
        ba    = ba_list(bi);
        chans = chan_names(ba_nums == ba);  % channels belonging to this BA
        disp(['  BA', num2str(ba), '  (', num2str(length(chans)), ' channels)']);

        % use only channels present in data
        valid_chans = intersect(chans, data_exp_all.label);
        if isempty(valid_chans)
            warning('No valid channels for BA%d in condition %s. Skipping.', ba, conditions{ci});
            continue;
        end
    
        % channel selection and average across channels
        cfg_sel              = [];
        cfg_sel.channel      = valid_chans;
        cfg_sel.latency      = [0.0 0.5];
        cfg_sel.avgoverchan  = 'yes';
        data_exp = ft_selectdata(cfg_sel, data_exp_all);
        data_nov = ft_selectdata(cfg_sel, data_nov_all);
        
        % rename label to BA name
        data_exp.label = {['BA', num2str(ba)]};
        data_nov.label = {['BA', num2str(ba)]};
    
        % neighbours: single virtual channel has no neighbours
        nb_ba = struct('label', {['BA', num2str(ba)]}, 'neighblabel', {{}});

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
        cfg.neighbours       = nb_ba;
        cfg.computeprob      = 'yes';
        n_exp = size(data_exp.trial, 2);
        n_nov = size(data_nov.trial, 2);
        cfg.design = [ones(1, n_exp), 2*ones(1, n_nov)];
        cfg.ivar   = 1;
        stat = ft_timelockstatistics(cfg, data_exp, data_nov);
        stat.ba        = ba;
        stat.condition = conditions{ci};
        stat.channels  = valid_chans;
        save(fullfile(res_dir, [conditions{ci}, '_ba', num2str(ba), '.mat']), 'stat', '-v7.3');
    end
end

%% figure: ERP per BA with significance mask
clear;
config;

data_erp_dir  = fullfile(prj_dir, 'result', 'erp_group_cond');
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_ba_cbpt');
res_dir       = fullfile(prj_dir, 'result', 'fig_stat_erp_ba_cbpt');
if ~exist(res_dir, 'dir'); mkdir(res_dir); end

load(fullfile(prj_dir, 'src', 'chan_ba_map.mat')); % ba_map
chan_names = fieldnames(ba_map);
ba_nums    = cellfun(@(c) ba_map.(c), chan_names);
ba_list    = unique(ba_nums);

for ci = 1:length(conditions)
    disp(['=== Condition: ', conditions{ci}, ' ===']);

    % load trial-level ERP data
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); data_nov_all = data; clear data;

    for bi = 1:length(ba_list)
        ba        = ba_list(bi);
        stat_file = fullfile(data_stat_dir, [conditions{ci}, '_ba', num2str(ba), '.mat']);

        if ~exist(stat_file, 'file')
            warning('Stat file not found for BA%d, condition %s. Skipping.', ba, conditions{ci});
            continue;
        end

        load(stat_file); % loads: stat

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
        ba_label           = {['BA', num2str(ba)]};
        data_exp.label     = ba_label;
        data_nov.label     = ba_label;
        data_exp.mask      = stat.mask; % 1 x time

        % plot
        fig = figure('Visible', 'off');

        cfg               = [];
        cfg.channel       = ba_label{1};
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'box';
        cfg.maskfacealpha = 0.2;
        cfg.linewidth     = 1.5;
        cfg.linecolor     = 'br';
        cfg.title         = ['BA', num2str(ba), ' - ', conditions{ci}];

        ft_singleplotER(cfg, data_exp, data_nov);

        h = findobj(gca, 'Type', 'line');
        if length(h) >= 2
            legend(h(end:-1:1), {'Exp', 'Nov'}, 'Location', 'eastoutside');
        end

        xlabel('Time (s)');
        ylabel('Amplitude (uV)');
        grid on;
        set(gca, 'FontSize', 14);

        save_name = fullfile(res_dir, [conditions{ci}, '_ba', num2str(ba), '.jpg']);
        saveas(fig, save_name);
        close(fig);

        disp(['  BA', num2str(ba), ' saved.']);
    end
end

