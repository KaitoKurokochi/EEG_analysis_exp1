% main_2: participants base processing
% read data as below
% - result/v1_3/{pname}_{i}.mat: v1 of {pname}, segment {i} (include
% data_v1_3)
% save data as below
% - result/v2/{pname}.mat: v2 of {pname} (include data_v2)

config;

data_dir = fullfile(prj_dir, 'result', 'v1_3');
res_dir = fullfile(prj_dir, 'result', 'v2');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for g = 1:length(groups)
    for i = 1:12
        id = [groups{g}, num2str(i)];

        disp(['--- id: ', id, ', start pre-processing ---']);

        data_v2 = cell(num_type, 1); 

        for j = 1:5
            % define fname, if none, continue
            fname = fullfile(data_dir, [id, '-', num2str(j), '.mat']);
            if ~exist(fname, 'file')
                continue;
            end

            % read data
            load(fname); % include data_v1_3

            % classify based on the trialinfo
            for l = 1:num_type 
                cfg = [];
                cfg.trials = find(data_v1_3.trialinfo == l);
                cfg.channel = main_channels;
                selected_data = ft_selectdata(cfg, data_v1_3); 
                if isempty(data_v2{l})
                    data_v2{l} = selected_data;
                else 
                    cfg = [];
                    data_v2{l} = ft_appenddata(cfg, data_v2{l}, selected_data);
                end
            end
        end

        save(fullfile(res_dir, [id, '.mat']), 'data_v2', '-v7.3');
    end
end