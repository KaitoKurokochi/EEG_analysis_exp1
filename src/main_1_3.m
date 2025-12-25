% main_1_3: segment-base pre-processing (run ICA)
% read data as below 
% - result/v1_2/{pname}_{i}.mat (include data_v1_2) 
% saves data as below
% - result/v1_3/{pname}_{i}.mat: pre-processed data (data_v1_3)

set_path;

data_dir = fullfile(prj_dir, 'result', 'v1_2');
res_dir = fullfile(prj_dir, 'result', 'v1_3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

data_fnames = {dir(fullfile(data_dir, '*.mat')).name};

for i = 1:length(data_fnames)
    load(fullfile(data_dir, data_fnames{i})); % include data_v1_2

    id = erase(data_fnames{i}, '.mat');
    disp(['--- id: ', id, ', start processing ---']);

    % ICA 
    disp('--- ICA ---');
    [data_v1_3, ica_result] = my_autoica(data_v1_2, id);
    
    % save 
    save(fullfile(res_dir, [id, '.mat']), 'data_v1_3', '-v7.3');
    save(fullfile(res_dir, [id, '_ica_result.mat']), 'ica_result', '-v7.3');
end