% cluster-based permutation test on time-frequency data
% cite -> https://www.fieldtriptoolbox.org/tutorial/stats/cluster_permutation_freq/

config;

data_dir = fullfile(prj_dir, 'result', 'v4');
res_dir = fullfile(prj_dir, 'result', 'TFR_cluster_based_permutest');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v4
disp('--- loading v4 data ---');
load(fullfile(data_dir, 'spectr_nov.mat')); % include spectr_nov
load(fullfile(data_dir, 'spectr_exp.mat')); % include spectr_exp

%% data statistics 
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);
        
        cfg = [];
        % cfg.latency = [0.0 1.0];
        % if strcmp(conditions{i}, 'ff') || strcmp(conditions{i}, 'sf')
        %     cfg.latency     = [0.0 0.5];
        % else 
        %     cfg.latency     = [0.0 0.57];
        % end
        cfg.method      = 'montecarlo';       
        cfg.statistic   = 'ft_statfun_indepsamplesT'; % group comparison
        cfg.tail = 0;
        cfg.alpha = 0.025; 
        cfg.clustertail = 0;
        cfg.correctm    = 'cluster';
        cfg.clusteralpha = 0.01;
        cfg.clusterstatistic = 'maxsum';
        cfg.numrandomization = 1000;

        % design config -> 
        n_exp = size(spectr_exp{i, j}.powspctrm, 1); 
        n_nov = size(spectr_nov{i, j}.powspctrm, 1); 
        design = zeros(1, n_exp + n_nov);
        design(1, 1:n_exp) = 1;
        design(1, n_exp+1:end) = 2;

        cfg.design      = design;
        cfg.ivar        = 1;               
        
        stat = ft_freqstatistics(cfg, spectr_exp{i, j}, spectr_nov{i, j});
        
        % figure 
        cfg = [];
        % set zlim
        max_abs_val = max(abs(stat.stat(:)));
        cfg.zlim = [-max_abs_val, max_abs_val];
        cfg.parameter = 'stat'; 

        fig = figure();
        ft_singleplotTFR(cfg, stat);
        title(['Permutation - ', conditions{i}, ' ', main_channels{j}, ' (plus: exp, minus: nov)']);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_perm.jpg']));
        close(fig);
    end
end