% main_1_1: segment-base pre-processing (read data, filtering, clipping,
% ICA, IC removal)
% save data as below
% - result/v0/{pname}_{i}.mat: rawdata of {pname}, segment {i}
% - result/v1_1/{pname}_{i}.mat: pre-processed data

set_path;
groups = {'nov', 'exp'};

for g = 1:length(groups)
    for i = 1:12
        pname = [groups{g}, num2str(i)];
        data_dir = fullfile(prj_dir, 'rawdata', pname);
        vhdrs = dir(fullfile(data_dir, '*.vhdr'));
        res_dir_v0 = fullfile(prj_dir, 'result', 'v0');
        if ~exist(res_dir_v0, 'dir')
            mkdir(res_dir_v0);
        end
        res_dir_v1 = fullfile(prj_dir, 'result', 'v1_1');
        if ~exist(res_dir_v1, 'dir')
            mkdir(res_dir_v1);
        end
        
        for v = 1:length(vhdrs)
            vhdr_path = fullfile(data_dir, vhdrs(v).name);
            sequence_path = fullfile(data_dir, ['sequence_', num2str(v), '.csv']);
            seg_id = [pname, '-', num2str(v)];

            disp(['--- id: ', seg_id, ', start pre-processing ---']);

            % read data 
            cfg = [];
            cfg.dataset = vhdr_path;
            data_v0 = ft_preprocessing(cfg);
            % save v0
            save(fullfile(res_dir_v0, [seg_id, '.mat']), 'data_v0', '-v7.3');
            
            % pre-processing
            if 1 <= i && i <= 5
                [data_v1_1, ic_label] = pre_processing(data_v0, sequence_path, id, 'mytrialfun_2');
            end
            if 6 <= i && i <= 12
                [data_v1_1, ic_label] = pre_processing(data_v0, sequence_path, id, 'mytrialfun');
            end
            % save v1
            save(fullfile(res_dir_v1, [seg_id, '.mat']), 'data_v1_1', '-v7.3');
        end
    end
end
