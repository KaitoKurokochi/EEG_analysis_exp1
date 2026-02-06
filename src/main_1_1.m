% main_1_1: segment-base pre-processing (read data, filtering, clipping,
% baseline correction)
% read data as below 
% - rawdata/{pname}/*.vhdr: headerfile for each eeg segment
% save data as below
% - result/v0/{pname}_{i}.mat: rawdata of {pname}, segment {i} % include
% data
% - result/v1_1/{pname}_{i}.mat: pre-processed data % include data

config;

res_v0_dir = fullfile(prj_dir, 'result', 'v0');
if ~exist(res_v0_dir, 'dir')
    mkdir(res_v0_dir);
end
res_v1_1_dir = fullfile(prj_dir, 'result', 'v1_1');
if ~exist(res_v1_1_dir, 'dir')
    mkdir(res_v1_1_dir);
end

for g = 1:length(groups)
    for i = 1:12
        pname = [groups{g}, num2str(i)]; % like exp1
        data_dir = fullfile(prj_dir, 'rawdata', pname);
        vhdrs = dir(fullfile(data_dir, '*.vhdr'));
        
        for v = 1:length(vhdrs)
            vhdr_path = fullfile(data_dir, vhdrs(v).name);
            sequence_path = fullfile(data_dir, ['sequence_', num2str(v), '.csv']);
            seg_id = [pname, '-', num2str(v)];

            disp(['--- id: ', seg_id, ', start pre-processing ---']);

            % read raw data 
            cfg              = [];
            cfg.dataset      = vhdr_path;
            data = ft_preprocessing(cfg);
            % save v0
            save(fullfile(res_v0_dir, [seg_id, '.mat']), 'data', '-v7.3');

            % filtering (1-30)
            disp('--- filtering ---')
            cfg = [];
            cfg.bpfilter      = 'yes';
            cfg.bpfilttype    = 'fir';
            cfg.bpfreq        = [1 30];
            cfg.continuous    = 'yes'; 
            data = ft_preprocessing(cfg, data);

            % define trls
            disp('--- trial def ---');
            cfg = [];
            % trial function depends on the participants
            if 1 <= i && i <= 5
                cfg.trialfun       = 'mytrialfun_2';
            elseif 6 <= i && i <= 12
                cfg.trialfun       = 'mytrialfun';
            end
            cfg.headerfile     = vhdr_path;
            cfg.sequencefile   = sequence_path;
            cfg = ft_definetrial(cfg);
            data = ft_redefinetrial(cfg, data);

            % baseline correction (-200 - 0 ms)
            cfg = [];
            cfg.demean        = 'yes';
            cfg.baselinewindow = [-0.2 0];
            data = ft_preprocessing(cfg, data);
            
            % save v1
            save(fullfile(res_v1_1_dir, [seg_id, '.mat']), 'data', '-v7.3');
        end
    end
end
