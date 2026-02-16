% fig_erp_group_cond_chan: show ERP data (multiple channels)
% ERP data for each group, condition
% show mean data over trials with muliplotER

config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
res_dir = fullfile(prj_dir, 'result', 'fig_erp_group_cond_chan');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% 
for gi = 1:length(groups)
    for ci = 1:length(conditions) 
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat'])); % include data
            
        fig = figure('Position', [100, 100, 1600, 1200], 'Visible', 'off');
        % multiplot
        cfg = [];
        cfg.layout        = 'easycapM11.lay';
        cfg.linewidth     = 1.0;
        ft_multiplotER(cfg, data);

        saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.jpg']));
        close(fig);
    end
end