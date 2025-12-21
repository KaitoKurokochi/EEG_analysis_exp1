% main_3: group concat
% read data as below
% - result/v2/{pname}.mat: v2 of {pname}, segment {i} (include
% data_v2)
% save data as below
% - result/v3/{group}.mat: v3 of {group} (include data_v3)

set_path;
groups = {'nov', 'exp'};
num_type = 4;

data_dir = fullfile(prj_dir, 'result', 'v2');
res_dir = fullfile(prj_dir, 'result', 'v3');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for i = 1:length(groups)
    data_v3 = cell(num_type, 1);
    fnames = dir(fullfile(data_dir, [groups{i}, '*.mat']));

    for j = 1:length(fnames)
        load(fullfile(data_dir, fnames(j).name)); % include data_v2

        for l = 1:num_type
            if (isempty(data_v3{l}))
                data_v3{l} = data_v2{l};
            else 
                cfg = [];
                data_v3{l} = ft_appenddata(cfg, data_v3{l}, data_v2{l});
            end
        end
    end

    save(fullfile(res_dir, [groups{i}, '.mat']), 'data_v3', '-v7.3');
end

   
