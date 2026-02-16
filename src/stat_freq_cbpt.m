% statistics: cluster-based permutation test of freq for each condition 
% data is trial x time x amplitude frequency data
% compare between groups

config;

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_freq_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% neighbours
load(fullfile(prj_dir, 'src', 'neighbours.mat'));

%% 
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

    % statistics
    cfg = [];
    cfg.latency          = [0.0 0.6];
    cfg.method           = 'montecarlo';
    cfg.statistic        = 'indepsamplesT'; 
    cfg.correctm         = 'cluster';
    cfg.numrandomization = 10000;
    cfg.neighbours       = neighbours;
    % design
    n_trl_exp = size(freq_exp.cumtapcnt, 1);
    n_trl_nov = size(freq_nov.cumtapcnt, 1);
    cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
    cfg.ivar   = 1;
    stat = ft_freqstatistics(cfg, freq_exp, freq_nov);

    % save data
    save(fullfile(res_dir, [conditions{ci}, '.mat']), 'stat', '-v7.3');
end