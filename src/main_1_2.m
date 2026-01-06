% main_1_2: segment-base pre-processing (manually remove noise channels and
% trials)
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

for i = 1:length(data_fnames)
    load(fullfile(data_dir, data_fnames{i})); % include data_v1_1

    id = erase(data_fnames{i}, '.mat');
    disp(['--- id: ', id, ', start processing ---']);

    % visual inspection 
    cfg = [];
    cfg.viewmode = 'vertical';
    ft_databrowser(cfg, data_v1_1);

    % remove noise channel manually
    cfg          = [];
    cfg.method   = 'summary';
    cfg.metric  = 'max';
    data_v1_2 = ft_rejectvisual(cfg, data_v1_1);

    % save 
    save(fullfile(res_dir, [id, '.mat']), 'data_v1_2', '-v7.3');
end