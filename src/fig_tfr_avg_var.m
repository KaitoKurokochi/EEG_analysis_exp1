% figure time-freq average and variance data
config;

tfr_data_dir = fullfile(prj_dir, 'result', 'v4'); % spectr
stat_data_dir = fullfile(prj_dir, 'result', 'TFR_cluster_based_permutest'); 
res_dir = fullfile(prj_dir, 'result', 'fig_tfr_pow_avg_var');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v4 (time x freq)
disp('--- loading v4 data ---');
load(fullfile(tfr_data_dir, 'spectr_nov.mat')); % include spectr_nov
load(fullfile(tfr_data_dir, 'spectr_exp.mat')); % include spectr_exp

%% 
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);

        % --- read statistics data --- 
        load(fullfile(stat_data_dir, [conditions{i}, '_', main_channels{j}, '.mat'])); % include stat.mask

        % --- calculate avg and sem ---
        cfg = [];
        cfg.variance = 'yes'; % calculate the variance 
        freq_exp = ft_freqdescriptives(cfg, spectr_exp{i, j}); % chan x time x freq
        freq_nov = ft_freqdescriptives(cfg, spectr_nov{i, j});

        % get x- and y-axis evenly spaced 
        freq_exp.time = linspace(stat.time(1), stat.time(end), length(stat.time));
        freq_exp.freq = linspace(stat.freq(1), stat.freq(end), length(stat.freq));
        freq_nov.time = linspace(stat.time(1), stat.time(end), length(stat.time));
        freq_nov.freq = linspace(stat.freq(1), stat.freq(end), length(stat.freq));

        % add mask 
        freq_exp.mask = stat.mask;
        freq_nov.mask = stat.mask;
        
        % calculate variance 
        n_exp = size(freq_exp.cumtapcnt, 1);
        n_nov = size(freq_nov.cumtapcnt, 1);
        freq_exp.var = (freq_exp.powspctrmsem.^2).*n_exp;
        freq_nov.var = (freq_nov.powspctrmsem.^2).*n_nov;

        % figure 
        for f = 5:5:25 % frequency to extract
            % --- extract data ---
            cfg = [];
            cfg.frequency = [f-0.5 f+0.5];
            freq_exp_f = ft_selectdata(cfg, freq_exp);
            freq_nov_f = ft_selectdata(cfg, freq_nov);
            
            % --- plot average power ---
            fig = figure();
            cfg = [];
            cfg.parameter = 'powspctrm';
            cfg.maskparameter = 'mask';
            cfg.maskfacealpha = 0.3;
            cfg.maskstyle = 'box';
            cfg.linecolor = 'rb';
            cfg.channel = 'all';
            cfg.linewidth = 2;

            ft_singleplotER(cfg, freq_exp_f, freq_nov_f);
            
            % options
            title(sprintf('Power Average (Cond: %s, Chan: %s, Freq: %d Hz)', ...
                conditions{i}, main_channels{j}, f));
            xlabel('Time (s)');
            ylabel('Power (\muV^2)');
            lines = findobj(gca, 'Type', 'line');
            legend([lines(2) lines(1)], {'Expert', 'Non-Expert'});
            grid on;

            % save data and close figure 
            saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_', num2str(f), '_avg.jpg']));
            close(fig);
            
            % --- plot variance ---
            fig = figure();
            cfg = [];
            cfg.parameter = 'var';
            cfg.maskparameter = 'mask';
            cfg.maskfacealpha = 0.3;
            cfg.linecolor = 'rb';
            cfg.maskstyle = 'box';
            cfg.channel = 'all';
            cfg.linewidth = 2;

            ft_singleplotER(cfg, freq_exp_f, freq_nov_f);
            
            % options
            title(sprintf('Power Variance (Cond: %s, Chan: %s, Freq: %d Hz)', ...
                conditions{i}, main_channels{j}, f));
            xlabel('Time (s)');
            ylabel('Variance');
            lines = findobj(gca, 'Type', 'line');
            legend([lines(2) lines(1)], {'Expert', 'Non-Expert'});
            grid on;

            % save data and close figure 
            saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_', num2str(f), '_var.jpg']));
            close(fig);
        end
    end
end
