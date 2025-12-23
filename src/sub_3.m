% sub 3: show TFR data on graphs for each channel
%
% input: 
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})
%
% The result would be saved in
% {prj_dir}/result/sub3/{group_name}_{condition}_{channnel}.jpg

set_path;
num_type = 4;
main_channels = {'Pz'};
conditions = {'ff', 'fs', 'sf', 'ss'};

data_dir = fullfile(prj_dir, 'result', 'v4');
res_dir = fullfile(prj_dir, 'result', 'sub3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v4
load(fullfile(data_dir, 'spectr_nov.mat')); % include spectr_nov(4x1 spectrum data)
load(fullfile(data_dir, 'spectr_exp.mat')); % include spectr_exp(4x1 spectrum data)
 
% nov
for i = 1:length(conditions)
    for j = 1:length(main_channels)
        disp(['--- start imaging: nov, ', conditions{i}, ', ', main_channels{j}]);
        hfig = my_singleplot_TFR(spectr_nov{i}, main_channels{j}, [0.0, 1.6], conditions{i}(2));
        saveas(hfig, fullfile(res_dir, ['nov_', conditions{i}, '_', main_channels{j}, '.jpg']));
        close(hfig);
    end
end

% exp
for i = 1:length(conditions)
    for j = 1:length(main_channels)
        disp(['--- start imaging: exp, ', conditions{i}, ', ', main_channels{j}]);
        hfig = my_singleplot_TFR(spectr_exp{i}, main_channels{j}, [0.0, 1.6], conditions{i}(2));
        saveas(hfig, fullfile(res_dir, ['exp_', conditions{i}, '_', main_channels{j}, '.jpg']));
        close(hfig);
    end
end