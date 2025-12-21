% main_4: comparison between groups 
% read data as below
% - result/v3/{group}.mat: v3 of {group} (include data_v3)

set_path;
num_type = 4;

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'v4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v3
load(data_dir, 'nov.mat');
data_nov = data_v3;
load(data_dir, 'exp.mat');
data_exp = data_v3;

%% phase opposition 
main_channels = {'Cz', 'Pz', 'Fz'};
