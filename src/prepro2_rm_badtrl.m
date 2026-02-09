% main_1_2: segment-base pre-processing (remove bad trls)
% read data as below 
% - result/v1_1/{pname}_{i}.mat (include data_v1_1) 
% saves data as below
% - result/v1_2/{pname}_{i}.mat: pre-processed data (data_v1_2)

config;

data_dir = fullfile(prj_dir, 'result', 'prepro1');
res_dir = fullfile(prj_dir, 'result', 'prepro2');
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

            % avg data over channel 
            cfg = [];
            cfg.avgoverchan = 'yes';
            cfg.channel     = {'all', '-FP1', '-FP2', '-EOG', '-M1', '-M2'};
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
            % % save 
            % save(fullfile(res_dir, [id, '.mat']), 'data_v1_2', '-v7.3');
        end
    end
end
