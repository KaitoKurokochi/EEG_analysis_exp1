config;

data_dir = fullfile(prj_dir, 'result', 'v4');
res_dir = fullfile(prj_dir, 'result', 'fig_freq');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v4 (time x freq)
disp('--- loading v4 data ---');
load(fullfile(data_dir, 'freq_nov.mat')); % include freq_nov
load(fullfile(data_dir, 'freq_exp.mat')); % include freq_exp

%% nov
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start fig: ', conditions{i}, ', ', main_channels{j}, '---']);

        % --- figure --- 
        cfg = [];
        cfg.parameter = 'powspctrm'; 
        fig = figure();
        ft_singleplotTFR(cfg, freq_nov{i, j});
        
        % figure options
        title(['Time-Frequency power (z:power) - ', conditions{i}, ' ', main_channels{j}, ' (pos: exp, neg: nov)']);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_nov.jpg']));
        close(fig);
    end
end

%% exp
for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start fig: ', conditions{i}, ', ', main_channels{j}, '---']);

        % --- figure --- 
        cfg = [];
        cfg.parameter = 'powspctrm'; 
        fig = figure();
        ft_singleplotTFR(cfg, freq_exp{i, j});
        
        % figure options
        title(['Time-Frequency power (z:power) - ', conditions{i}, ' ', main_channels{j}, ' (pos: exp, neg: nov)']);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_exp.jpg']));
        close(fig);
    end
end