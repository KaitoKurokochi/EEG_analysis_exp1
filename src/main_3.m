% main_3: group concat
% v2 -> v3 (concat by group) 

% input: all v2 files
% 
% output 
% - result/{participant}/v2.mat 

define_path;

%% get v2.mat (each group)
exp_dirs = dir(fullfile(result_dir, 'exp*'));
nov_dirs = dir(fullfile(result_dir, 'nov*'));

num_nov = numel(nov_dirs);
num_exp = numel(exp_dirs);

data_nov = cell(num_nov, 1);
for i = 1:num_nov
    data_nov{i} = load(fullfile(result_dir, nov_dirs(i).name, v2_fname));
end

data_exp = cell(num_exp, 1);
for i = 1:num_exp
    data_exp{i} = load(fullfile(result_dir, exp_dirs(i).name, v2_fname));
end

%% classify 
num_type = 4;
data_exp_concat = cell(1, num_type);
data_nov_concat = cell(1, num_type);

% nov
for i = 1:num_nov
    for j = 1:num_type
        data = data_nov{i}.classified_data{j};
        if (isempty(data_nov_concat{j}))
            data_nov_concat{j} = data;
        else 
            cfg = [];
            data_nov_concat{j} = ft_appenddata(cfg, data_nov_concat{j}, data);
        end
    end
end

% exp
for i = 1:num_exp
    for j = 1:num_type
        data = data_exp{i}.classified_data{j};
        if (isempty(data_exp_concat{j}))
            data_exp_concat{j} = data;
        else 
            cfg = [];
            data_exp_concat{j} = ft_appenddata(cfg, data_exp_concat{j}, data);
        end
    end
end

%% save 
save(fullfile(result_dir, 'v3_nov.mat'), 'data_nov_concat', '-v7.3');
save(fullfile(result_dir, 'v3_exp.mat'), 'data_exp_concat', '-v7.3');


   
