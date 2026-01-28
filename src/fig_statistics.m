config;

data_dir = fullfile(prj_dir, 'result', 'TFR_cluster_based_permutest');
res_dir = fullfile(prj_dir, 'result', 'figure_statistics');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for i = 1:num_type
    for j= 1:length(main_channels)
        disp(['--- start stat: ', conditions{i}, ', ', main_channels{j}, '---']);

        % read data
        load(fullfile(data_dir, [conditions{i}, '_', main_channels{j}, '.mat'])); % include stat

        % get axis evenly spaced
        stat.time = linspace(stat.time(1), stat.time(end), length(stat.time));
        stat.freq = linspace(stat.freq(1), stat.freq(end), length(stat.freq));

        % log convert
        stat.neglogprob = -log10(stat.prob);

        % figure
        cfg = [];
        cfg.parameter = 'neglogprob'; % p-value
        fig = figure();
        ft_singleplotTFR(cfg, stat);

        % figure options
        set(gcf,'renderer','zbuffer');
        shading interp;
        colormap('hot'); clim = get(gca,'clim'); colorbar; set(gca,'clim',[0 clim(2)]); l
        title(['Permutation - ', conditions{i}, ' ', main_channels{j}, ' (plus: exp, minus: nov)']);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '.jpg']));
        close(fig);

        % figure with mask
        cfg = [];
        cfg.parameter = 'neglogprob'; % p-value
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'opacity';
        cfg.maskalpha     = 0.2;
        fig = figure();
        ft_singleplotTFR(cfg, stat);

        % figure options
        colormap("hot");
        colorbar;
        title(['Permutation - ', conditions{i}, ' ', main_channels{j}, ' (plus: exp, minus: nov)']);
        hold on;
        xline(0, '-r', 's2 start');
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        hold off;
        
        % save data and close figure 
        saveas(fig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '_with_mask.jpg']));
        close(fig);
    end
end