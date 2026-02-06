% main_4: conduct frequency analysis
% read data as below
% - result/v3/{group}.mat: v3 of {group} (include data_v3)
% save data as below
% - result/v4/{group}.mat: v4 of {pname} (include freq_{group})

config;

data_dir = fullfile(prj_dir, 'result', 'v3');
res_dir = fullfile(prj_dir, 'result', 'v4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% nov
load(fullfile(data_dir, 'nov.mat'));
data_nov = data_v3;

freq_nov = cell(num_type, length(main_channels));
for i = 1:num_type
    for j = 1:length(main_channels)
        disp(['--- processing: type ', num2str(i), ', channel ', main_channels{j}, '---']);
        % freq analysis 
        cfg              = [];
        cfg.channel      = main_channels{j};
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'hanning';
        cfg.foi          = 1:0.5:30; % start:step:end
        cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % length of time window = 0.5 sec
        cfg.toi          = -1.0:0.025:1.5; 
        cfg.keeptrials   = 'yes';

        freq_nov{i, j} = ft_freqanalysis(cfg, data_nov{i});

        % baseline correction 
        cfg              = [];
        cfg.baseline     = [-0.2 0.0];
        cfg.baselinetype = 'absolute'; % to be reviewed
        freq_nov{i, j} = ft_freqbaseline(cfg, freq_nov{i, j});
    end
end

save(fullfile(res_dir, 'freq_nov.mat'), 'freq_nov', '-v7.3');
clear data_nov data_v3;

%% exp
load(fullfile(data_dir, 'exp.mat'));
data_exp = data_v3;

freq_exp = cell(num_type, length(main_channels));
for i = 1:num_type
    for j = 1:length(main_channels)
        disp(['--- processing: type ', num2str(i), ', channel ', main_channels{j}, '---']);
        % freq analysis 
        cfg              = [];
        cfg.channel      = main_channels{j};
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'hanning';
        cfg.foi          = 1:0.5:30; % start:step:end
        cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;  % length of time window = 0.5 sec
        cfg.toi          = -1.0:0.025:1.5; 
        cfg.keeptrials   = 'yes';

        freq_exp{i, j} = ft_freqanalysis(cfg, data_exp{i});

        % baseline correction 
        cfg              = [];
        cfg.baseline     = [-0.2 0.0];
        cfg.baselinetype = 'absolute'; % to be reviewed
        freq_exp{i, j} = ft_freqbaseline(cfg, freq_exp{i, j});
    end
end

save(fullfile(res_dir, 'freq_exp.mat'), 'freq_exp', '-v7.3');