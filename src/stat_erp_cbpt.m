% statistics: cluster-based permutation test of ERP for each condition 
% data is simple trial x time x amplitude data
% compare between groups

config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% neighbours
load(fullfile(prj_dir, 'src', 'neighbours.mat'));

%% 
for ci = 1:num_type
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
    if strcmp(conditions{ci}, 'ff') || strcmp(conditions{ci}, 'sf')
        cfg.latency = [0 0.5];
    else
        cfg.latency = [0 0.57];
    end
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