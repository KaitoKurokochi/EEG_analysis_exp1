% power difference (time x freq)
% mask cluster

config;

stat_data_dir = fullfile(prj_dir, 'result', 'stat_cluster_based_permutest/');
freq_data_dir = fullfile(prj_dir, 'result', 'freq_cleaned/');
res_dir = fullfile(prj_dir, 'result', 'fig_pow_diff');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% read data_v4 (time x freq)
disp('--- loading cleaned data ---');
load(fullfile(freq_data_dir, 'freq_nov.mat')); % include freq_nov_cleaned
load(fullfile(freq_data_dir, 'freq_exp.mat')); % include freq_exp_cleaned

%% figure (each type, each condition)
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);

        % --- read data --- 
        load(fullfile(stat_data_dir, [conditions{i}, '_', main_channels{j}, '.mat'])); % include stat.mask

        % --- calculate diff ---
        % simply calculate average power for each group
        cfg = [];
        cfg.keeptrials = 'no';
        avg_power_exp = ft_freqdescriptives(cfg, freq_exp_cleaned{i, j}); 
        avg_power_nov = ft_freqdescriptives(cfg, freq_nov_cleaned{i, j});

        % calculate power difference (positive: exp, negative: non-exp)
        cfg = [];
        cfg.operation = 'x1 - x2';
        cfg.parameter = 'powspctrm';
        diff_power = ft_math(cfg, avg_power_exp, avg_power_nov);

        % --- figure --- 
        cfg = [];
        cfg.parameter      = 'powspctrm'; 
        cfg.zlim           = 'maxabs';
        fig = figure();
        ft_singleplotTFR(cfg, diff_power);
        
        % figure options
        title(['Power difference(z:power) - ', conditions{i}, ' ', main_channels{j}, ' (pos: exp, neg: nov)']);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '.jpg']));
        close(fig);

        % --- figure with mask ---
        % get x- and y-axis evenly spaced 
        diff_power.time = linspace(stat.time(1), stat.time(end), length(stat.time));
        diff_power.freq = linspace(stat.freq(1), stat.freq(end), length(stat.freq));

        % add mask 
        diff_power.mask = stat.mask;

        % figure
        cfg = [];
        cfg.parameter      = 'powspctrm'; 
        cfg.maskparameter  = 'mask';
        cfg.maskstyle      = 'opacity';
        cfg.maskalpha      = 0.0;
        cfg.zlim           = 'maxabs';
        fig = figure();
        ft_singleplotTFR(cfg, diff_power);
        
        % figure options
        title(['Power difference with mask(z:power, pos:exp, neg:nov) - ', conditions{i}, ' ', main_channels{j}]);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_mask.jpg']));
        close(fig);
    end
end