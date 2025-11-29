% input: need to set participant's name, sequencefile name
% - result/{participant}/*_v1.mat
% 
% output 
% - result/{participant}/v2.mat 

define_path;

%% collect datasets
num_type = 4;
files = dir(fullfile(result_participant_path, '*_v1.mat'));
num_seg = numel(files);
dataset = cell(num_seg, 1);

for i = 1:num_seg
    load(fullfile(result_participant_path, files(i).name));
    dataset{i} = data;
end

%% classify data 
classified_data = cell(1, num_type);

for i = 1:num_seg
    labels = dataset{i}.trialinfo; % 1, 2, 3, 4
    
    for j = 1:num_type
        cfg = [];
        cfg.trials = find(labels == j);
        data = ft_selectdata(cfg, dataset{i});

        if isempty(classified_data{j})
            classified_data{j} = data;
        else 
            cfg = [];
            classified_data{j} = ft_appenddata(cfg, classified_data{j}, data);
        end
    end
end

save(classified_file_name, 'classified_data', '-v7.3');