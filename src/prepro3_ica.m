% pre-processing 3: segment-base pre-processing (run ICA)
% read data as below 
% - result/prepro2/{pname}_{i}.mat 
% saves data as below
% - result/prepro3/{pname}_{i}.mat: pre-processed data

%% config 
config;

data_dir = fullfile(prj_dir, 'result', 'prepro2');
res_dir = fullfile(prj_dir, 'result', 'prepro3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

data_fnames = {dir(fullfile(data_dir, '*.mat')).name};

%% ica 
for i = 1:length(data_fnames)
    load(fullfile(data_dir, data_fnames{i})); % include data

    id = erase(data_fnames{i}, '.mat');
    disp(['--- id: ', id, ', start processing ---']);

    % ICA 
    disp('--- ICA ---');
    [data, ica_result] = my_autoica(data, id);
    
    % save 
    save(fullfile(res_dir, [id, '.mat']), 'data', '-v7.3');
    save(fullfile(res_dir, [id, '_ica_result.mat']), 'ica_result', '-v7.3');
end

%% figure result - all trials on one graph
data_dir = fullfile(prj_dir, 'result', 'prepro3'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_erp_all_trls_prepro3'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% figure trials
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
            % cfg.channel     = {'all', '-Fp1', '-Fp2', '-EOG', '-M1', '-M2'};
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
            close(fig);
        end
    end
end

%% figure result - multiplot on a topomap
data_dir = fullfile(prj_dir, 'result', 'prepro3'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_erp_all_chan_prepro3'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%
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

            fig = figure('Position', [100, 100, 1600, 1200], 'Visible', 'off');
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