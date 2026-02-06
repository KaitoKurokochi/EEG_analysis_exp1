% figure time-freq average and variance data
config;

freq_data_dir = fullfile(prj_dir, 'result', 'freq_cleaned'); 
stat_data_dir = fullfile(prj_dir, 'result', 'stat_cluster_based_permutest'); 
res_dir = fullfile(prj_dir, 'result', 'fig_freq_pow_avg_var');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read freq data
disp('--- loading cleaned data ---');
load(fullfile(freq_data_dir, 'freq_nov.mat')); % include freq_nov_cleaned
load(fullfile(freq_data_dir, 'freq_exp.mat')); % include freq_exp_cleaned

%% 
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);

        % --- read statistics data --- 
        load(fullfile(stat_data_dir, [conditions{i}, '_', main_channels{j}, '.mat'])); % include stat.mask

        % --- calculate avg and sem ---
        cfg = [];
        cfg.variance = 'yes'; % calculate the variance 
        freq_chan_exp = ft_freqdescriptives(cfg, freq_exp_cleaned{i, j}); % chan x time x freq
        freq_chan_nov = ft_freqdescriptives(cfg, freq_nov_cleaned{i, j});

        % get x- and y-axis evenly spaced 
        freq_chan_exp.time = linspace(stat.time(1), stat.time(end), length(stat.time));
        freq_chan_exp.freq = linspace(stat.freq(1), stat.freq(end), length(stat.freq));
        freq_chan_nov.time = linspace(stat.time(1), stat.time(end), length(stat.time));
        freq_chan_nov.freq = linspace(stat.freq(1), stat.freq(end), length(stat.freq));

        % add mask 
        freq_chan_exp.mask = stat.mask;
        freq_chan_nov.mask = stat.mask;
        
        % calculate variance 
        n_exp = size(freq_exp_cleaned{i, j}.trialinfo, 1);
        n_nov = size(freq_nov_cleaned{i, j}.trialinfo , 1);
        freq_chan_exp.var = (freq_chan_exp.powspctrmsem.^2).*n_exp;
        freq_chan_nov.var = (freq_chan_nov.powspctrmsem.^2).*n_nov;

        % figure 
        for f = 5:5:25 % frequency to extract
            % --- extract data ---
            cfg = [];
            cfg.frequency = [f-0.5 f+0.5];
            freq_exp_f = ft_selectdata(cfg, freq_chan_exp);
            freq_nov_f = ft_selectdata(cfg, freq_chan_nov);
            
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
