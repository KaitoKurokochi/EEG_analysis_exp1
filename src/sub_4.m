% sub_4: TFR graph
%
% input: 
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})

config;

data_dir = fullfile(prj_dir, 'result', 'v4');
res_dir = fullfile(prj_dir, 'result', 'sub4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v4
disp('--- loading v4 data ---');
load(fullfile(data_dir, 'spectr_nov.mat')); % include spectr_nov
load(fullfile(data_dir, 'spectr_exp.mat')); % include spectr_exp

% TFR graph - nov
for i = 1:num_type
    for j = 1:length(main_channels)
        fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j});

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['nov_', conditions{i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

% TFR graph - exp
for i = 1:num_type
    for j = 1:length(main_channels)
        fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j});

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['exp_', conditions{i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

% TFR graph - nov, xlim
for i = 1:num_type
    for j = 1:length(main_channels)
        if strcmp(conditions{j}, 'ff') || strcmp(conditions{j}, 'sf')
            fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j}, [0.0 0.5]);
        elseif strcmp(conditions{j}, 'fs') || strcmp(conditions{j}, 'ss')
            fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j}, [0.0 0.57]);
        end
        % fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j}, [0.0 0.3]);

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['nov_', conditions{i}, '_', main_channels{j},'_time_lim.jpg']));
        close(fig);
    end
end

% TFR graph - exp, xlim
for i = 1:num_type
    for j = 1:length(main_channels)
        if strcmp(conditions{j}, 'ff') || strcmp(conditions{j}, 'sf')
            fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j}, [0.0 0.5]);
        elseif strcmp(conditions{j}, 'fs') || strcmp(conditions{j}, 'ss')
            fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j}, [0.0 0.57]);
        end
        % fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j}, [0.0 0.3]);

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['exp_', conditions{i}, '_', main_channels{j},'_time_lim.jpg']));
        close(fig);
    end
end

%% run statistics
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start imaging: ', conditions{i}, ', ', main_channels{j}, '---']);
        [fig_perm, fig_zscore, p_POS] = my_fig_statistics(spectr_nov{i, j}, spectr_exp{i, j});

        figure(fig_perm);
        title(['Permutation - ', conditions{i}, ' ', main_channels{j}]);
        saveas(fig_perm, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_perm.jpg']));
        close(fig_perm);

        figure(fig_zscore);
        title(['Z-score - ', conditions{i}, ' ', main_channels{j}]);
        saveas(fig_zscore, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_zscore.jpg']));
        close(fig_zscore);
        break;
    end
    break;
end

%% anlysis using ft_freqstatistics
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);

        % design config -> 
        n_nov = size(spectr_nov{i, j}.powspctrm, 1); 
        n_exp = size(spectr_exp{i, j}.powspctrm, 1); 
        design = zeros(1, n_nov + n_exp);
        design(1, 1:n_nov) = 1;
        design(1, n_nov+1:end) = 2;
        
        cfg = [];
        cfg.method      = 'montecarlo';       
        cfg.statistic   = 'indepsamplesT';    
        cfg.parameter   = 'powspctrm';
        cfg.design      = design;
        cfg.ivar        = 1;               
        
        cfg.correctm    = 'cluster';
        cfg.clusteralpha = 0.05;          
        cfg.clusterstatistic = 'maxsum';
        cfg.numrandomization = 1000;
        
        stat = ft_freqstatistics(cfg, spectr_nov{i, j}, spectr_exp{i, j});
        
        % figure 
        cfg = [];
        cfg.parameter = 'stat'; 
        % cfg.zlim = [-5 5]; 

        fig = figure();
        ft_singleplotTFR(cfg, stat);
        title(['Permutation - ', conditions{i}, ' ', main_channels{j}]);
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_perm.jpg']));
        close(fig);
    end
end



