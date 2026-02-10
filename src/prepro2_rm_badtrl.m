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
for i = 1:length(groups)
    for j = 1:12
        for k = 1:5
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

            % % detect jump artifact
            % cfg = [];
            % cfg.artfctdef.zvalue.channel = 'EEG'; 
            % cfg.artfctdef.zvalue.cutoff  = 30; 
            % cfg.artfctdef.zvalue.trlpadding = 0;
            % cfg.artfctdef.zvalue.artpadding = 0.1;
            % cfg.artfctdef.zvalue.fltpadding = 0;
            % cfg.artfctdef.zvalue.cumulative    = 'yes';
            % cfg.artfctdef.zvalue.medianfilter  = 'yes';
            % cfg.artfctdef.zvalue.medianfiltord = 9;
            % cfg.artfctdef.zvalue.interactive = 'yes';
            % [cfg_artfct_jump, artifact_jump] = ft_artifact_zvalue(cfg, data);
            % 
            % % detect EOG artifact
            % cfg = [];
            % cfg.artfctdef.zvalue.channel = 'EOG'; 
            % cfg.artfctdef.zvalue.cutoff  = 4; 
            % cfg.artfctdef.zvalue.trlpadding = 0;
            % cfg.artfctdef.zvalue.artpadding = 0.1;
            % cfg.artfctdef.zvalue.fltpadding = 0;
            % cfg.artfctdef.zvalue.bpfilter   = 'yes';
            % cfg.artfctdef.zvalue.bpfilttype = 'but';
            % cfg.artfctdef.zvalue.bpfreq     = [4 15];
            % cfg.artfctdef.zvalue.bpfiltord  = 4;
            % cfg.artfctdef.zvalue.hilbert    = 'yes';
            % cfg.artfctdef.zvalue.interactive = 'yes';
            % [cfg_artfct_eog, artifact_eog] = ft_artifact_zvalue(cfg, data);
            % 
            % % reject artifact
            % cfg = [];
            % cfg.artfctdef.jump.artifact   = artifact_jump;
            % cfg.artfctdef.eog.artifact    = artifact_eog;
            % data = ft_rejectartifact(cfg, data);
            % 
            % data_clean = data; % debug

            % 3SD
            ntrl = length(data.trial);
            trial_var = zeros(ntrl, 1);
            for t = 1:ntrl
                trial_var(t) = var(data.trial{t}(:)); 
            end
            
            m_var = mean(trial_var);
            s_var = std(trial_var);
            threshold = m_var + 3 * s_var;
            bad_trials = find(trial_var > threshold);
            
            cfg = [];
            cfg.trials = setdiff(1:ntrl, bad_trials);
            data = ft_preprocessing(cfg, data);
            
            disp([num2str(length(bad_trials)) ' trials removed']);

            % save prepro2 - have removed bad channel
            save(fullfile(res_dir, [seg_id, '.mat']), 'data', '-v7.3');
        end
    end
end