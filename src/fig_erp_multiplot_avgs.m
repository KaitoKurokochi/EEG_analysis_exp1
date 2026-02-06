% fig_erp_multiplot: 
% read data as below 
% - result/v1_1/{pname}_{i}.mat (include data_v1_1) 
% save ERP multiplot for each trial

config;

data_v1_1_dir = fullfile(prj_dir, 'result', 'v1_1');
data_v1_3_dir = fullfile(prj_dir, 'result', 'v1_3');
res_dir = fullfile(prj_dir, 'result', 'fig_erp_multiplot_avgs');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% all segments 
for i = 1:length(groups)
    for j = 1:12
        for k = 1:5
            id = [groups{i}, num2str(j), '-', num2str(k)];

            fname = fullfile(data_v1_1_dir, [id, '.mat']);
            if ~exist(fname, 'file')
                continue;
            end
            disp('loading...');
            load(fname); % include data_v1_1

            fname = fullfile(data_v1_3_dir, [id, '.mat']);
            if ~exist(fname, 'file')
                continue;
            end
            disp('loading...');
            load(fname); % include data_v1_3
            
            disp(['--- id: ', id, ', start processing ---']);
           
            % multiplot before ICA
            cfg = [];
            cfg.channel       = 'all';
            cfg.showlabels    = 'yes';
            cfg.ylim          = [-5.0 5.0];
            cfg.layout        = 'easycapM11.mat';
            cfg.renderer      = 'painters';

            % fig before ICA
            fig = figure('Position', [100, 100, 1600, 1200]);
            ft_multiplotER(cfg, data_v1_1);
            saveas(fig, fullfile(res_dir, [id, '_before_ICA.jpg']));
            close(fig);
            % fig after ICA
            fig = figure('Position', [100, 100, 1600, 1200]);
            ft_multiplotER(cfg, data_v1_3);
            saveas(fig, fullfile(res_dir, [id, '_after_ICA.jpg']));
            close(fig);
        end
    end
end
