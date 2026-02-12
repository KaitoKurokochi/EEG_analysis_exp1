% classification_by_label: classify data by label(condtions)

config;

data_dir = fullfile(prj_dir, 'result', 'prepro3');
res_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups) % group index
    for ci = 1:num_type % condition index
        data_all = [];
        for pi = 1:12 % participant index
            id = [groups{gi}, num2str(pi)];
    
            disp(['--- id: ', id, ', start pre-processing ---']);
            for si = 1:5 % segment index
                id = [groups{gi}, num2str(pi), '-', num2str(si)];
                
                fname = fullfile(data_dir, [id, '.mat']);
                if ~exist(fname, 'file')
                    continue;
                end

                disp('loading...');
                load(fname); % include data

                % extract data
                cfg = [];
                cfg.trials = find(data.trialinfo == ci);
                data_tmp = ft_selectdata(cfg, data);

                % append
                if isempty(data_all)
                    data_all = data_tmp;
                else 
                    cfg = [];
                    data_all = ft_appenddata(cfg, data_all, data_tmp);
                end

                disp(['len: ', num2str(length(data_tmp.trialinfo))]); % debug
            end
        end

        data = data_all;
        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.mat']), 'data', '-v7.3');
    end
end