% classification_by_label: classify data by label(condtions)
% collect correct trials and concat each group

config;

data_dir = fullfile(prj_dir, 'result', 'prepro3');
res_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% conditions
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
            end
        end

        data = data_all;
        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.mat']), 'data', '-v7.3');
    end
end

% go/nogo
for gi = 1:length(groups) % group index
    % go trials
    data_go = [];
    data_nogo = [];
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
            cfg.trials = find(data.trialinfo == 1 | data.trialinfo == 4);
            tmp_go = ft_selectdata(cfg, data);
            cfg = [];
            cfg.trials = find(data.trialinfo == 2 | data.trialinfo == 3);
            tmp_nogo = ft_selectdata(cfg, data);

            % append
            if isempty(data_go) & isempty(data_nogo)
                data_go = tmp_go;
                data_nogo = tmp_nogo;
            else 
                cfg = [];
                data_go = ft_appenddata(cfg, data_go, tmp_go);
                data_nogo = ft_appenddata(cfg, data_nogo, tmp_nogo);
            end
        end
    end
    save(fullfile(res_dir, [groups{gi}, '_go.mat']), 'data_go', '-v7.3');
    save(fullfile(res_dir, [groups{gi}, '_nogo.mat']), 'data_nogo', '-v7.3');
end