% figure all ERP of each trials (each segment)

config;

data_dir = fullfile(prj_dir, 'result', 'prepro2'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_erp_all_trls_after_cleaned'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% figure trials
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

            % avg data over channel 
            cfg = [];
            cfg.avgoverchan = 'yes';
            cfg.channel     = {'all', '-Fp1', '-Fp2', '-EOG', '-M1', '-M2'};
            data_avg = ft_selectdata(cfg, data);
            
            cfg = [];
            cfg.keeptrials = 'yes'; 
            data_avg = ft_timelockanalysis(cfg, data_avg);

            trl_mtrx = squeeze(data_avg.trial);
            time_axis = data_avg.time;

            fig = figure('visible', 'off');
            plot(time_axis, trl_mtrx); 
            grid on;
            xlabel('Time (s)');
            ylabel('Amplitude');
            title([id, ' ', num2str(size(data.trialinfo, 1)), 'trials']);

            saveas(fig, fullfile(res_dir, [id, '_avg.jpg']));
        end
    end
end