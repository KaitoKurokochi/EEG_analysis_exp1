% cluster-based permutation test on time-frequency data
% cite -> https://www.fieldtriptoolbox.org/tutorial/stats/cluster_permutation_freq/

config;

data_dir = fullfile(prj_dir, 'result', 'freq_cleaned'); 
res_dir = fullfile(prj_dir, 'result', 'stat_cluster_based_permutest');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v4
disp('--- loading cleaned data ---');
load(fullfile(data_dir, 'freq_nov.mat')); % include freq_nov_cleaned
load(fullfile(data_dir, 'freq_exp.mat')); % include freq_exp_cleaned

%% data statistics 
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);
        
        cfg = [];
        cfg.method      = 'montecarlo';  % permutation test
        cfg.statistic   = 'ft_statfun_indepsamplesT'; % group comparison
        cfg.tail = 0; 
        cfg.alpha = 0.025; 
        cfg.clustertail = 0;
        cfg.correctm    = 'cluster';
        cfg.clusteralpha = 0.01;
        cfg.clusterstatistic = 'maxsum';
        cfg.numrandomization = 10000; 

        % design config -> 
        n_exp = size(freq_exp_cleaned{i, j}.powspctrm, 1); 
        n_nov = size(freq_nov_cleaned{i, j}.powspctrm, 1); 
        design = zeros(1, n_exp + n_nov);
        design(1, 1:n_exp) = 1;
        design(1, n_exp+1:end) = 2;

        cfg.design      = design;
        cfg.ivar        = 1;               
        
        stat = ft_freqstatistics(cfg, freq_exp_cleaned{i, j}, freq_nov_cleaned{i, j});
        save(fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '.mat']), 'stat', '-v7.3');
    end
end