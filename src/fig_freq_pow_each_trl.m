% figure time-freq average and variance data
config;

freq_data_dir = fullfile(prj_dir, 'result', 'v4'); 
res_dir = fullfile(prj_dir, 'result', 'fig_freq_pow_each_trl');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v4 (time x freq)
disp('--- loading v4 data ---');
load(fullfile(tfr_data_dir, 'freq_nov.mat')); % include freq_nov
load(fullfile(tfr_data_dir, 'freq_exp.mat')); % include freq_exp

%% nov
for ti = 1:num_type
    for ci = 1:length(main_channels)
        disp(['--- start stat: ', conditions{ti}, ', ', main_channels{ci}, '---']);

        for f = 5:5:25
            max_plots = 50; 
            num_trials = size(freq_nov{ti, ci}.trialinfo, 1);

            for trl = 1:size(freq_nov{ti, ci}.trialinfo, 1)
                if mod(trl, max_plots) == 1
                    fig = figure('Units', 'pixels', 'Position', [100, 100, 1500, 900]);
                    t = tiledlayout(5, 10, 'TileSpacing', 'compact', 'Padding', 'compact'); 
                end

                % select trial
                cfg = [];
                cfg.trials = trl;
                cfg.frequency = [f-0.5 f+0.5];
                freq_trl_f = ft_selectdata(cfg, freq_nov{ti, ci});

                % extract necessary data
                time_axis = freq_nov{ti, ci}.time;
                tmp = squeeze(mean(freq_trl_f.powspctrm, 3))'; 

                % plot
                nexttile;
                plot(time_axis, tmp);
                title(sprintf('Trl: %d', trl), 'FontSize', 8);
                grid on;

                if mod(trl, max_plots) == 0 || trl == num_trials
                    title(t, sprintf('Power (Cond: %s, Chan: %s, Freq: %d Hz)', ...
                        conditions{ti}, main_channels{ci}, f));
                    batch_num = ceil(trl / max_plots);
                    save_name = sprintf('nov_%s_%s_%dHz_batch%d.jpg', ...
                        conditions{ti}, main_channels{ci}, f, batch_num);
                    saveas(fig, fullfile(res_dir, save_name));

                    close(fig);
                end
            end
        end
    end
end

% exp
for ti = 1:num_type
    for ci = 1:length(main_channels)
        disp(['--- start stat: ', conditions{ti}, ', ', main_channels{ci}, '---']);

        for f = 5:5:25
            max_plots = 50; 
            num_trials = size(freq_exp{ti, ci}.trialinfo, 1);

            for trl = 1:size(freq_exp{ti, ci}.trialinfo, 1)
                if mod(trl, max_plots) == 1
                    fig = figure('Units', 'pixels', 'Position', [100, 100, 1500, 900]);
                    t = tiledlayout(5, 10, 'TileSpacing', 'compact', 'Padding', 'compact'); 
                end

                % select trial
                cfg = [];
                cfg.trials = trl;
                cfg.frequency = [f-0.5 f+0.5];
                freq_trl_f = ft_selectdata(cfg, freq_exp{ti, ci});

                % extract necessary data
                time_axis = freq_exp{ti, ci}.time;
                tmp = squeeze(mean(freq_trl_f.powspctrm, 3))'; 

                % plot
                nexttile;
                plot(time_axis, tmp);
                title(sprintf('Trl: %d', trl), 'FontSize', 8);
                grid on;

                if mod(trl, max_plots) == 0 || trl == num_trials
                    title(t, sprintf('Power (Cond: %s, Chan: %s, Freq: %d Hz)', ...
                        conditions{ti}, main_channels{ci}, f));
                    batch_num = ceil(trl / max_plots);
                    save_name = sprintf('exp_%s_%s_%dHz_batch%d.jpg', ...
                        conditions{ti}, main_channels{ci}, f, batch_num);
                    saveas(fig, fullfile(res_dir, save_name));

                    close(fig);
                end
            end
        end
    end
end
