% pre-processing 3: segment-base pre-processing (run ICA)
% read data as below 
% - result/prepro2/{pname}_{i}.mat 
% saves data as below
% - result/prepro3/{pname}_{i}.mat: pre-processed data

config;

data_dir = fullfile(prj_dir, 'result', 'prepro2');
res_dir = fullfile(prj_dir, 'result', 'prepro3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

data_fnames = {dir(fullfile(data_dir, '*.mat')).name};

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