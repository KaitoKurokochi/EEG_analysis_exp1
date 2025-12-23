% main_4: create spectrum data
% read data as below
% - result/v3/{group}.mat: v3 of {group} (include data_v3)
% save data as below
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})

set_path;
num_type = 4;

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'v4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v3
load(fullfile(data_dir, 'nov.mat'));
data_nov = data_v3;
load(fullfile(data_dir, 'exp.mat'));
data_exp = data_v3;

%% data -> TFR
% nov
spectr_nov = cell(num_type, 1);
for i = 1:num_type
    spectr = my_calc_spectr(data_nov{i});
    spectr_nov{i} = spectr;
end
save(fullfile(res_dir, 'spectr_nov.mat'), 'spectr_nov', '-v7.3');

% exp
spectr_exp = cell(num_type, 1);
for i = 1:num_type
    spectr = my_calc_spectr(data_exp{i});
    spectr_exp{i} = spectr;
end
save(fullfile(res_dir, 'spectr_exp.mat'), 'spectr_exp', '-v7.3');

