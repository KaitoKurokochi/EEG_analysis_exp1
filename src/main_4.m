% main_4: create spectrum data
% read data as below
% - result/v3/{group}.mat: v3 of {group} (include data_v3)
% save data as below
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})

set_path;
num_type = 4;
main_channels = {'Fz', 'Pz', 'Cz'};

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'v4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v3
load(fullfile(data_dir, 'nov.mat'));
data_nov = data_v3;
load(fullfile(data_dir, 'exp.mat'));
data_exp = data_v3;

%% data -> TFR
% nov
spectr_nov = cell(num_type, length(main_channels));
for i = 1:num_type
    for j = 1:length(main_channels)
        spectr_nov{i, j} = my_calc_spectr(data_nov{i}, main_channels{j});
    end
end

% exp
spectr_exp = cell(num_type, length(main_channels));
for i = 1:num_type
    for j = 1:length(main_channels)
        spectr_exp{i, j} = my_calc_spectr(data_exp{i}, main_channels{j});
    end
end

%%
save(fullfile(res_dir, 'spectr_nov.mat'), 'spectr_nov', '-v7.3');
save(fullfile(res_dir, 'spectr_exp.mat'), 'spectr_exp', '-v7.3');
