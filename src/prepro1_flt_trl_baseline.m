% pro-processing1: segment-base pre-processing (read data, filtering, resampling,
% trial definition, baseline correction)
% read data as below 
% - rawdata/{pname}/*.vhdr: headerfile for each eeg segment
% save data as below
% - result/raw/{pname}_{i}.mat: rawdata of {pname}, segment {i} % include
% data
% - result/prepro1/{pname}_{i}.mat: pre-processed data % include data

config;

res_raw_dir = fullfile(prj_dir, 'result', 'raw');
if ~exist(res_raw_dir, 'dir')
    mkdir(res_raw_dir);
end
res_prepro1_dir = fullfile(prj_dir, 'result', 'prepro1');
if ~exist(res_prepro1_dir, 'dir')
    mkdir(res_prepro1_dir);
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
            % save raw data
            % save(fullfile(res_raw_dir, [seg_id, '.mat']), 'data', '-v7.3');

            % filtering (1-100)
            disp('--- filtering ---')
            cfg = [];
            % remove EOG 
            cfg.channel       = {'all', '-EOG'};
            % band-pass filter
            cfg.bpfilter      = 'yes';
            cfg.bpfilttype    = 'firws';
            cfg.bpfreq        = [1 100];
            % band-stop filter
            cfg.bsfilter      = 'yes';
            cfg.bsfreq        = [49 51];
            cfg.bsfilttype    = 'firws';
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

            % baseline correction (-100 - 100 ms)
            disp('--- baseline correction ---');
            cfg = [];
            cfg.demean        = 'yes';
            cfg.baselinewindow = [-0.1 0.1]; 
            data = ft_preprocessing(cfg, data);
            
            % save prepro1
            save(fullfile(res_prepro1_dir, [seg_id, '.mat']), 'data', '-v7.3');
        end
    end
end
