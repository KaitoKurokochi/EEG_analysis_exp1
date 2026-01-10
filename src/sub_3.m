% sub_3: showing average ERP graph for each condition, each group
%
% input: 
% - result/v3/{group}.mat: v3 of {pname} (include data_v3)

config;

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'sub_3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v3
disp('--- loading v3 data ---');

load(fullfile(data_dir, 'nov.mat')); % include data_v3
data_nov = data_v3;
clear data_v3;

load(fullfile(data_dir, 'exp.mat')); % include data_v3
data_exp = data_v3;
clear data_v3;

% graph plot - nov
for i = 1:num_type
    for j = 1:length(main_channels)
        cfg         = [];
        cfg.channel = main_channels{j};

        fig = figure;
        ft_singleplotER(cfg, data_nov{i, 1});

        hold on;
        xlabel('Time (s)');
        ylabel('Potential (\muV)');
        title(['ERP at channel: ' cfg.channel]);
        line([-1.5 2.0], [0 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['nov_', conditions{i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

% graph plot - exp
for i = 1:num_type
    for j = 1:length(main_channels)
        cfg         = [];
        cfg.channel = main_channels{j};

        fig = figure;
        ft_singleplotER(cfg, data_exp{i, 1});

        hold on;
        xlabel('Time (s)');
        ylabel('Potential (\muV)');
        title(['ERP at channel: ' cfg.channel]);
        line([-1.5 2.0], [0 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['exp_', conditions{i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

% graph plot - comparison 
for i = 1:num_type
    for j = 1:length(main_channels)
        cfg         = [];
        cfg.channel = main_channels{j};
        
        fig = figure;
        ft_singleplotER(cfg, data_exp{i}, data_nov{i});
        
        hold on;
        xlabel('Time (s)');
        ylabel('Potential (\muV)');
        title(['ERP at channel: ' cfg.channel]);
        line([-1.5 2.0], [0 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
        legend({'Expert', 'Novice'});
        hold off;
        
        saveas(fig, fullfile(res_dir, [conditions{1, i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

% graph plot - comparison, xlim = [0.0 {(end of s2)}]
for i = 1:num_type
    for j = 1:length(main_channels)
        cfg         = [];
        cfg.channel = main_channels{j};
        if strcmp(conditions{j}, 'ff') || strcmp(conditions{j}, 'sf')
            cfg.xlim = [0.0 0.5];
        elseif strcmp(conditions{j}, 'fs') || strcmp(conditions{j}, 'ss')
            cfg.xlim = [0.0 0.57];
        end
        
        fig = figure;
        ft_singleplotER(cfg, data_exp{i}, data_nov{i});
        
        hold on;
        xlabel('Time (s)');
        ylabel('Potential (\muV)');
        title(['ERP at channel: ' cfg.channel]);
        line([-1.5 2.0], [0 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
        legend({'Expert', 'Novice'});
        hold off;
        
        saveas(fig, fullfile(res_dir, [conditions{1, i}, '_', main_channels{j}, '_lim.jpg']));
        close(fig);
    end
end