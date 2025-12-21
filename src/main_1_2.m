% main_1_2: segment-base pre-processing (rm noise channels, interpolate
% removed channels, baseline-correlation)
% read data as below 
% - result/v1_1/{pname}_{i}.mat (include data_v1_1) 
% saves data as below
% - result/v1_2/{pname}_{i}.mat: pre-processed data (data_v1_2)

set_path;

data_dir = fullfile(prj_dir, 'result', 'v1_1');
res_dir = fullfile(prj_dir, 'result', 'v1_2');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

data_fnames = {dir(fullfile(data_dir, '*.mat')).name};

%%
for i = 1:length(data_fnames)
    load(fullfile(data_dir, data_fnames{i})); % include data_v1_1

    id = erase(data_fnames{i}, '.mat');
    disp(['--- id: ', id, ', start processing ---']);

    % remove noise channel
    % cfg          = [];
    % cfg.method   = 'summary';
    % data_noise_channel_removed = ft_rejectvisual(cfg, data_v1_1);

    % interpolate removed channels

    % baseline correlation 
    cfg = [];
    cfg.demean           = 'yes';
        cfg.baselinewindow   = [-0.2 0];
    data_v1_2 = ft_preprocessing(cfg, data_v1_1);
    
    % save 
    save(fullfile(res_dir, [id, '.mat']), 'data_v1_2', '-v7.3');
end