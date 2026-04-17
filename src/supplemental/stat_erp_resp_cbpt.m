% statistics: cluster-based permutation test of ERP response-lock data for each condition 
% data is trial x time x amplitude ERP data
% compare between groups
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'erp_res_lock'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_erp_resp_lock_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% neighbours
load(fullfile(prj_dir, 'src', 'neighbours.mat'));
cond = 'go';

disp('--- loading ERP data ---');
% exp ERP
load(fullfile(data_dir, ['exp_', cond, '.mat'])); % include data
data_exp = data; clear data;
% nov ERP
load(fullfile(data_dir, ['nov_', cond, '.mat'])); % include data
data_nov = data; clear data;

% statistics
cfg = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_indepsamplesT'; 
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.01;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 3;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 10000;
cfg.neighbours       = neighbours;
% design
n_trl_exp = size(data_exp.trial, 2);
n_trl_nov = size(data_nov.trial, 2);
cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
cfg.ivar   = 1;
stat = ft_timelockstatistics(cfg, data_exp, data_nov);

% save data
save(fullfile(res_dir, [cond, '.mat']), 'stat', '-v7.3');

%% fig