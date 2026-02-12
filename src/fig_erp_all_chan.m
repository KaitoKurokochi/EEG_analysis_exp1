% fig_erp_all_chan: show ERP data (multiple channels)

config;

data_dir = fullfile(prj_dir, 'result', 'prepro3'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_erp_all_chan_prepro3'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% 
for i = 1:length(groups)
    for j = 1:12
        for k = 1:5
            id = [groups{i}, num2str(j), '-', num2str(k)];
            
            fname = fullfile(data_dir, [id, '.mat']);
            if ~exist(fname, 'file')
                continue;
            end

            disp('loading...');
            load(fname); % include data
            
            disp(['--- id: ', id, ', start processing ---']);

            fig = figure('Position', [100, 100, 1600, 1200]);
            % multiplot
            cfg = [];
            cfg.layout        = 'easycapM11.lay';
            cfg.linewidth     = 1.0;
            ft_multiplotER(cfg, data);

            saveas(fig, fullfile(res_dir, [id, '.jpg']));
            close(fig);
        end
    end
end