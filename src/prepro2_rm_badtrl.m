% prepro2_rm_badtrl: segment-base pre-processing (remove bad trls)
% read data as below 
% - result/prepro1/{pname}_{i}.mat
% saves data as below
% - result/prepro2/{pname}_{i}.mat

config;

data_dir = fullfile(prj_dir, 'result', 'prepro1');
res_dir = fullfile(prj_dir, 'result', 'prepro2');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% check each segment 
for i = 1:1%length(groups)
    for j = 1:1%12
        for k = 1:1%5
            seg_id = [groups{i}, num2str(j), '-', num2str(k)];

            fname = fullfile(data_dir, [seg_id, '.mat']);
            if ~exist(fname, 'file')
                continue;
            end

            disp('loading...');
            load(fname); % include data
            
            disp(['--- id: ', seg_id, ', start processing ---']);

            % reject artifacts (mannually)
            cfg = [];
            cfg.method      = 'summary';
            cfg.channel     = {'all', '-Fp1', '-Fp2', '-EOG', '-M1', '-M2'};
            data_rejvis = ft_rejectvisual(cfg, data);
            % extract good trials
            [~, idx_kept] = ismember(data_rejvis.sampleinfo, data.sampleinfo, 'rows');
            cfg = [];
            cfg.trials = idx_kept; 
            data = ft_preprocessing(cfg, data);

            % 3SD
            ntrl = length(data.trial);
            trl_means = zeros(ntrl, 1);
            % means for each trial
            for t = 1:ntrl
                trl_means(t) = mean(data.trial{t}(:)); 
            end
            m_mean = mean(trl_means);
            s_mean = std(trl_means);
            threshold = m_mean + 3 * s_mean;
            bad_trls = find(trl_means > threshold);
            
            cfg = [];
            cfg.trials = setdiff(1:ntrl, bad_trls);
            data = ft_preprocessing(cfg, data);
            
            disp([num2str(length(bad_trls)) ' trials removed']);

            % save prepro2 - have removed bad channel
            save(fullfile(res_dir, [seg_id, '.mat']), 'data', '-v7.3');
        end
    end
end