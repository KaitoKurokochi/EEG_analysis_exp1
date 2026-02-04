% main_4: create spectrum data
% read data as below
% - result/v3/{group}.mat: v3 of {group} (include data_v3)
% save data as below
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})

config;

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'v4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% nov
load(fullfile(data_dir, 'nov.mat'));
data_nov = data_v3;

tfr_pow_nov = cell(num_type, length(main_channels));
for i = 1:num_type
    for j = 1:length(main_channels)
        disp(['--- processing: type ', num2str(i), ', channel ', main_channels{j}, '---']);
        tfr_pow_nov{i, j} = my_calc_spectr(data_nov{i}, main_channels{j});
    end
end

save(fullfile(res_dir, 'tfr_pow_nov.mat'), 'tfr_pow_nov', '-v7.3');

clear data_nov data_v3;

%% exp
load(fullfile(data_dir, 'exp.mat'));
data_exp = data_v3;

tfr_pow_exp = cell(num_type, length(main_channels));
for i = 1:num_type
    for j = 1:length(main_channels)
        disp(['--- processing: type ', num2str(i), ', channel ', main_channels{j}, '---']);
        tfr_pow_exp{i, j} = my_calc_spectr(data_exp{i}, main_channels{j});
    end
end

save(fullfile(res_dir, 'tfr_pow_exp.mat'), 'tfr_pow_exp', '-v7.3');
