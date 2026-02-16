% fig_erp_group_cond_topo: show ERP data
% ERP data for each group, condition
% show mean data over trials on topomap

config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
res_dir = fullfile(prj_dir, 'result', 'fig_erp_group_cond_topo');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% 
for gi = 1:length(groups)
    for ci = 1:length(conditions) 
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat'])); % include data

        % for each 50ms
        for t = 0:0.05:0.55
            t_strt = t;
            t_end = t+0.05;

            fig = figure('Position', [100, 100, 800, 600], 'Visible', 'off');

            cfg = [];
            cfg.xlim               = [t_strt, t_end];
            cfg.zlim               = 'maxabs';
            % cfg.baseline           = 'yes';
            % cfg.baselinetype       = 'relative';
            cfg.colorbar           = 'yes';
            cfg.layout             = 'easycapM11.mat';
            ft_topoplotER(cfg, data);

            saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', ...
                num2str(t_strt*1000), '_', num2str(t_end*1000), '.jpg']));
            close(fig);
        end
    end
end