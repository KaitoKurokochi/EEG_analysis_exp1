% statistics: cluster-based permutation test of ERP for each condition 
% data is trial x time x amplitude ERP data
% compare between groups

config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% neighbours
load(fullfile(prj_dir, 'src', 'neighbours.mat'));

%% statistics - erp cbpt
for ci = 1:length(conditions)
    % read data
    disp('--- loading ERP data ---');
    % exp ERP
    load(fullfile(data_dir, ['exp_', conditions{ci}, '.mat'])); % include data
    data_exp = data;
    clear data;
    % nov ERP
    load(fullfile(data_dir, ['nov_', conditions{ci}, '.mat'])); % include data
    data_nov = data;
    clear data;

    % statistics
    cfg = [];
    cfg.latency          = [0.0 0.6];
    cfg.method           = 'montecarlo';
    cfg.statistic        = 'indepsamplesT'; 
    cfg.correctm         = 'cluster';
    cfg.numrandomization = 10000;
    cfg.neighbours       = neighbours;
    % design
    n_trl_exp = size(data_exp.trial, 2);
    n_trl_nov = size(data_nov.trial, 2);
    cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
    cfg.ivar   = 1;
    stat = ft_timelockstatistics(cfg, data_exp, data_nov);

    % save data
    save(fullfile(res_dir, [conditions{ci}, '.mat']), 'stat', '-v7.3');
end

%% figure result - time x amp for all channels
clear;
config;

data_erp_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt');
res_dir = fullfile(prj_dir, 'result', 'fig_stat_erp_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for ci = 1:length(conditions)
    % read ERP data
    disp('--- loading ERP data ---');
    % exp ERP
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); % include data
    data_exp = data;
    clear data;
    % nov ERP
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); % include data
    data_nov = data;
    clear data;

    % read stat data 
    disp('--- loading stat data ---');
    load(fullfile(data_stat_dir, [conditions{ci}, '.mat'])); % include stat

    % calculate mean ERP
    cfg = [];
    cfg.latency = [0.0 0.6];
    data_exp = ft_timelockanalysis(cfg, data_exp);
    data_nov = ft_timelockanalysis(cfg, data_nov);

    % add mask 
    data_exp.mask = stat.mask;

    % figure
    cfg        = [];
    cfg.layout = 'easycapM11.mat';
    cfg.maskparameter = 'mask';
    cfg.maskstyle     = 'box';
    cfg.comment = ['Blue: ', conditions{ci}, ' (Exp), Red: Novice'];
    cfg.showlabels = 'yes';
    cfg.maskfacealpha = '0.2';

    fig = figure('Position', [100, 100, 1600, 1200]);
    ft_multiplotER(cfg, data_exp, data_nov);
    title(['ERP CBPT - ', conditions{ci}]);

    % save data and close figure 
    saveas(fig, fullfile(res_dir, [conditions{ci}, '.jpg']));
    % close(fig);
end