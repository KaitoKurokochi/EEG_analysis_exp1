% good trl detection 
% detect trls whose abs(max) is under the threshold for each condition, trl

config;

freq_data_dir = fullfile(prj_dir, 'result', 'v4'); 
res_dir = fullfile(prj_dir, 'result', 'freq_cleaned');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v4 (time x freq)
disp('--- loading v4 data ---');
load(fullfile(freq_data_dir, 'freq_nov.mat')); % include freq_nov
load(fullfile(freq_data_dir, 'freq_exp.mat')); % include freq_exp

%% threshold
bad_trl_threshold = {10, 1; 20, 10; 4, 2}; % (chan(main) x freq(5, 10Hz))

%% nov 
freq_nov_cleaned = cell(num_type, length(main_channels));
for ti = 1:num_type
    num_trls = size(freq_nov{ti, 1}.powspctrm, 1);
    is_good_trl = true(num_trls, 1);

    for ci = 1:length(main_channels)
        data_struct = freq_nov{ti, ci};
        
        for f_val = [5, 10]
            f_idx = data_struct.freq >= (f_val - 0.5) & data_struct.freq <= (f_val + 0.5);

            tmp_pow = squeeze(mean(mean(data_struct.powspctrm(:,:,f_idx,:), 4), 3));

            threshold = bad_trl_threshold{ci, f_val/5};
            is_good_trl = is_good_trl & (abs(tmp_pow) <= threshold);
        end
    end
    
    for ci = 1:length(main_channels)
        cfg = [];
        cfg.trials = is_good_trl;
        freq_nov_cleaned{ti, ci} = ft_selectdata(cfg, freq_nov{ti, ci});
    end
end
save(fullfile(res_dir, 'freq_nov.mat'), 'freq_nov_cleaned', '-v7.3');

%% exp
freq_exp_cleaned = cell(num_type, length(main_channels));
for ti = 1:num_type
    num_trls = size(freq_exp{ti, 1}.powspctrm, 1);
    is_good_trl = true(num_trls, 1);

    for ci = 1:length(main_channels)
        data_struct = freq_exp{ti, ci};
        
        for f_val = [5, 10]
            f_idx = data_struct.freq >= (f_val - 0.5) & data_struct.freq <= (f_val + 0.5);

            tmp_pow = squeeze(mean(mean(data_struct.powspctrm(:,:,f_idx,:), 4), 3));

            threshold = bad_trl_threshold{ci, f_val/5};
            is_good_trl = is_good_trl & (abs(tmp_pow) <= threshold);
        end
    end
    
    for ci = 1:length(main_channels)
        cfg = [];
        cfg.trials = is_good_trl;
        freq_exp_cleaned{ti, ci} = ft_selectdata(cfg, freq_exp{ti, ci});
    end
end
save(fullfile(res_dir, 'freq_exp.mat'), 'freq_exp_cleaned', '-v7.3');