% ERP permutation test for each main channel and each condition
% data_v3 has the necessary data 

config;

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'fig_erp_perm_test');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v3
disp('--- loading v3 data ---');

load(fullfile(data_dir, 'nov.mat')); % include data_v3
data_nov = data_v3;
clear data_v3;

load(fullfile(data_dir, 'exp.mat')); % include data_v3
data_exp = data_v3;
clear data_v3;

%% 
avg_exp = cell(1, num_type);
avg_nov = cell(1, num_type);

%% statistics
for i = 1:num_type
    for j = 1:1%length(main_channels)
        % permutation test
        cfg = [];
        cfg.channel = main_channels{j};
        if strcmp(conditions{i}, 'ff') || strcmp(conditions{i}, 'sf')
            cfg.latency = [0 0.5];
        else
            cfg.latency = [0 0.57];
        end
        cfg.method           = 'montecarlo';
        cfg.statistic        = 'indepsamplesT'; 
        cfg.correctm         = 'cluster';
        cfg.numrandomization = 10000;
        % trial design 
        n_trl_exp = size(data_exp{i}.trial, 2);
        n_trl_nov = size(data_nov{i}.trial, 2);
        cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
        cfg.ivar   = 1; 

        stat = ft_timelockstatistics(cfg, data_exp{i}, data_nov{i});

        % calc avg 
        cfg = [];
        cfg.channel = main_channels{j};
        cfg.keeptrials = 'no';
        if strcmp(conditions{i}, 'ff') || strcmp(conditions{i}, 'sf')
            cfg.latency = [0 0.5];
        else
            cfg.latency = [0 0.57];
        end
        avg_exp{i} = ft_timelockanalysis(cfg, data_exp{i});
        avg_nov{i} = ft_timelockanalysis(cfg, data_nov{i});

        % add mask
        avg_exp{i}.mask = stat.mask;
        avg_nov{i}.mask = stat.mask;
    end
end

%% figure 
for i = 1:num_type
    for j = 1:1%length(main_channels)
        fig = figure();

        cfg = [];
        cfg.interactive   = 'no';
        % line
        cfg.channel = main_channels{j};
        cfg.linecolor = 'rb';
        cfg.linewidth = 2;
        % box
        cfg.parameter = 'avg';
        cfg.maskparameter = 'mask';
        cfg.maskstyle = 'box';
        cfg.maskfacealpha = 0.3;
        ft_singleplotER(cfg, avg_exp{i}, avg_nov{i});

        % plot options
        % title(sprintf('ERP Average (Cond: %s, Chan: %s)', ...
        %     conditions{i}, main_channels{j}));
        set(gca, 'FontSize', 20);
        title([]);
        xlabel('Time (s)');
        ylabel('Amplitude (\muV)');
        lines = findobj(gca, 'Type', 'line');
        legend([lines(2) lines(1)], {'Experienced', 'Non-Experienced'}, 'Location', 'southwest', 'FontSize', 12);
        grid on;

        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '.svg']));
        close(fig);
    end
end