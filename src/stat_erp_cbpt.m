% statistics: cluster-based permutation test of ERP for each condition 
% data is trial x time x amplitude ERP data
% compare between groups
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% neighbours
load(fullfile(prj_dir, 'src', 'neighbours.mat'));

% statistics - erp cbpt
for ci = 1:length(conditions)
    % read data
    disp('--- loading ERP data ---');
    % exp ERP
    load(fullfile(data_dir, ['exp_', conditions{ci}, '.mat'])); % include data
    data_exp = data;
    clear data;
    % nov ERP
    load(fullfile(data_dir, ['nov_', conditions{ci}, '.mat'])); % include data
    data_nov = data;
    clear data;

    % statistics
    cfg = [];
    cfg.latency          = [0.0 0.6];
    cfg.method           = 'montecarlo';
    cfg.statistic        = 'ft_statfun_indepsamplesT'; 
    cfg.correctm         = 'cluster';
    cfg.clusteralpha     = 0.01;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan        = 4;
    cfg.tail             = 0;
    cfg.clustertail      = 0;
    cfg.alpha            = 0.05;
    cfg.numrandomization = 10000;
    cfg.neighbours       = neighbours;
    % design
    n_trl_exp = size(data_exp.trial, 2);
    n_trl_nov = size(data_nov.trial, 2);
    cfg.design = [ones(1, n_trl_exp), 2*ones(1, n_trl_nov)];
    cfg.ivar   = 1;
    stat = ft_timelockstatistics(cfg, data_exp, data_nov);

    % save data
    save(fullfile(res_dir, [conditions{ci}, '.mat']), 'stat', '-v7.3');
end

%% figure result - time x amp for all channels
clear;
config;

data_erp_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt');
res_dir = fullfile(prj_dir, 'result', 'fig_stat_erp_cbpt'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for ci = 1:length(conditions)
    % read ERP data
    disp('--- loading ERP data ---');
    % exp ERP
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat'])); % include data
    data_exp = data;
    clear data;
    % nov ERP
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat'])); % include data
    data_nov = data;
    clear data;

    % read stat data 
    disp('--- loading stat data ---');
    load(fullfile(data_stat_dir, [conditions{ci}, '.mat'])); % include stat

    % calculate mean ERP
    cfg = [];
    cfg.latency = [0.0 0.6];
    data_exp = ft_timelockanalysis(cfg, data_exp);
    data_nov = ft_timelockanalysis(cfg, data_nov);

    % add mask 
    data_exp.mask = stat.mask;

    % figure
    cfg        = [];
    cfg.layout = 'easycapM11.mat';
    cfg.maskparameter = 'mask';
    cfg.maskstyle     = 'box';
    cfg.linewidth     = 1.0;
    cfg.linecolor     = 'br';
    cfg.comment = ['Condition: ', conditions{ci}, '(Blue: experienced, Red: Inexperienced)'];
    cfg.showlabels = 'yes';
    cfg.maskfacealpha = '0.2';

    fig = figure('Position', [100, 100, 1600, 1200]);
    ft_multiplotER(cfg, data_exp, data_nov);
    title(['ERP CBPT - ', conditions{ci}]);

    % save data and close figure 
    saveas(fig, fullfile(res_dir, [conditions{ci}, '.jpg']));
    % close(fig);
end

%% figure for each channel
clear;
config;
data_erp_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt');
res_dir = fullfile(prj_dir, 'result', 'fig_stat_erp_cbpt');

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for ci = 1:length(conditions)
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat']));
    data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat']));
    data_nov_all = data; clear data;
    load(fullfile(data_stat_dir, [conditions{ci}, '.mat']));

    cfg_tl = [];
    cfg_tl.latency = [0.0 0.6];
    data_exp = ft_timelockanalysis(cfg_tl, data_exp_all);
    data_nov = ft_timelockanalysis(cfg_tl, data_nov_all);
    
    data_exp.mask = stat.mask;
    chan_labels = data_exp.label;
    
    for chi = 1:length(chan_labels)
        current_chan = chan_labels{chi};
        
        fig = figure('Visible', 'off');
        
        cfg = [];
        cfg.channel       = current_chan;
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'box';
        cfg.maskfacealpha = 0.2;
        cfg.linewidth     = 1.5;
        cfg.graphcolor    = 'br';
        cfg.title         = [conditions{ci}, ' ', current_chan];
        
        ft_singleplotER(cfg, data_exp, data_nov);

        h = findobj(gca, 'Type', 'line');
        if length(h) >= 2
            legend(h(2:-1:1), {'Exp', 'Inexp'}, 'Location', 'southeast');
        end
        
        xlabel('Time (s)');
        ylabel('Amplitude (uV)');
        
        save_name = fullfile(res_dir, [conditions{ci}, '_', current_chan, '.jpg']);
        saveas(fig, save_name);
        close(fig);
    end
end

%% extract each cluster
clear;
config;

data_erp_dir = fullfile(prj_dir, 'result', 'erp_group_cond');
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt');
res_dir = fullfile(prj_dir, 'result', 'stat_erp_cond_cluster');
alpha = 0.05;

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for ci = 1:length(conditions)
    load(fullfile(data_erp_dir, ['exp_', conditions{ci}, '.mat']));
    data_exp_all = data; clear data;
    load(fullfile(data_erp_dir, ['nov_', conditions{ci}, '.mat']));
    data_nov_all = data; clear data;
    load(fullfile(data_stat_dir, [conditions{ci}, '.mat']));

    % pos clusters
    for cli = 1:length(stat.posclusters)
        if stat.posclusters(cli).prob >= alpha
            break
        end
    
        % extract cluster from labelmat
        cluster_mask = (stat.posclusterslabelmat == cli);
    
        % find channels
        chan_idx = find(any(cluster_mask, 2));
        chan_names = stat.label(chan_idx);
    
        % find time
        time_idx = find(any(cluster_mask, 1));
        time_range = stat.time(time_idx);

        % extract (time x chan) 
        cfg = [];
        cfg.channel            = chan_names;
        cfg.latency            = [0.0 0.6];
        data_exp = ft_timelockanalysis(cfg, data_exp_all);
        data_nov = ft_timelockanalysis(cfg, data_nov_all);

        % data
        data = [];
        data.erp_exp = data_exp;
        data.erp_nov = data_nov;
        data.mask = cluster_mask(chan_idx, :);

        % save data
        save(fullfile(res_dir, [conditions{ci}, '_pos', num2str(cli), '.mat']), 'data', '-v7.3');
    end

    % neg clusters
    for cli = 1:length(stat.negclusters)
        if stat.negclusters(cli).prob >= alpha
            break
        end
    
        % extract cluster from labelmat
        cluster_mask = (stat.negclusterslabelmat == cli);
    
        % find channels
        chan_idx = find(any(cluster_mask, 2));
        chan_names = stat.label(chan_idx);
    
        % find time
        time_idx = find(any(cluster_mask, 1));
        time_range = stat.time(time_idx);

        % extract (time x chan) 
        cfg = [];
        cfg.channel            = chan_names;
        cfg.latency            = [0.0 0.6];
        data_exp = ft_timelockanalysis(cfg, data_exp_all);
        data_nov = ft_timelockanalysis(cfg, data_nov_all);

        % data
        data = [];
        data.erp_exp = data_exp;
        data.erp_nov = data_nov;
        data.mask = cluster_mask(chan_idx, :);

        % save data
        save(fullfile(res_dir, [conditions{ci}, '_neg', num2str(cli), '.mat']), 'data', '-v7.3');
    end
end

%% figure each cluster
clear;
config;

data_erp_dir = fullfile(prj_dir, 'result', 'stat_erp_cond_cluster');
data_stat_dir = fullfile(prj_dir, 'result', 'stat_erp_cbpt');
res_dir = fullfile(prj_dir, 'result', 'fig_stat_erp_cond_cluster');
alpha = 0.05;

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for ci = 1:length(conditions)
    % load stat
    load(fullfile(data_stat_dir, [conditions{ci}, '.mat'])); % include stat

    % pos clusters
    for cli = 1:length(stat.posclusters)
        if stat.posclusters(cli).prob >= alpha
            break
        end

        load(fullfile(data_erp_dir, [conditions{ci}, '_pos', num2str(cli), '.mat'])); % include data
        data.erp_exp.mask = data.mask;

        % fig - ERP
        fig = figure('Visible', 'off');
        
        cfg = [];
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'box';
        cfg.maskfacealpha = 0.2;
        cfg.linewidth     = 1.5;
        cfg.graphcolor    = 'br';
        
        ft_singleplotER(cfg, data.erp_exp, data.erp_nov);

        h = findobj(gca, 'Type', 'line');
        if length(h) >= 2
            legend(h(2:-1:1), {'Exp', 'Inexp'}, 'Location', 'southeast');
        end
        
        xlabel('Time (s)');
        ylabel('Amplitude (uV)');
        
        save_name = fullfile(res_dir, [conditions{ci}, '_pos', num2str(cli), '_erp.jpg']);
        saveas(fig, save_name);
        close(fig);

        % fig - chan
        fig = figure('Visible', 'off');

        tmp_stat = stat;
        tmp_stat.stat = zeros(size(stat.stat));

        cfg = [];
        cfg.parameter = 'stat';
        cfg.layout    = 'easycapM11.mat';
        % Style settings for the blank map
        cfg.style     = 'blank';
        cfg.comment    = 'on';
        cfg.colorbar   = 'no';
        cfg.markers    = 'on';
        cfg.markersize = 3;
        % Highlight settings
        cfg.highlight          = 'on';
        cfg.highlightchannel   = data.erp_exp.label;
        cfg.highlightsymbol    = 'o';
        cfg.highlightcolor     = [1 0 0]; % Red
        cfg.highlightsize      = 10;
        cfg.highlightlinewidth = 2;
        
        ft_topoplotER(cfg, tmp_stat);

        save_name = fullfile(res_dir, [conditions{ci}, '_pos', num2str(cli), '_chan.jpg']);
        saveas(fig, save_name);
        close(fig);
    end

    % neg clusters
    for cli = 1:length(stat.negclusters)
        if stat.negclusters(cli).prob >= alpha
            break
        end

        load(fullfile(data_erp_dir, [conditions{ci}, '_neg', num2str(cli), '.mat'])); % include data
        data.erp_exp.mask = data.mask;

        % fig - ERP
        fig = figure('Visible', 'off');
        
        cfg = [];
        cfg.maskparameter = 'mask';
        cfg.maskstyle     = 'box';
        cfg.maskfacealpha = 0.2;
        cfg.linewidth     = 1.5;
        cfg.graphcolor    = 'br';
        
        ft_singleplotER(cfg, data.erp_exp, data.erp_nov);

        h = findobj(gca, 'Type', 'line');
        if length(h) >= 2
            legend(h(2:-1:1), {'Exp', 'Inexp'}, 'Location', 'southeast');
        end
        
        xlabel('Time (s)');
        ylabel('Amplitude (uV)');
        
        save_name = fullfile(res_dir, [conditions{ci}, '_neg', num2str(cli), '_erp.jpg']);
        saveas(fig, save_name);
        close(fig);

        % fig - chan
        fig = figure('Visible', 'off');

        tmp_stat = stat;
        tmp_stat.stat = zeros(size(stat.stat));

        cfg = [];
        cfg.parameter = 'stat';
        cfg.layout    = 'easycapM11.mat';
        % Style settings for the blank map
        cfg.style     = 'blank';
        cfg.comment    = 'on';
        cfg.colorbar   = 'no';
        cfg.markers    = 'on';
        cfg.markersize = 3;
        % Highlight settings
        cfg.highlight          = 'on';
        cfg.highlightchannel   = data.erp_exp.label;
        cfg.highlightsymbol    = 'o';
        cfg.highlightcolor     = [1 0 0]; % Red
        cfg.highlightsize      = 10;
        cfg.highlightlinewidth = 2;
        
        ft_topoplotER(cfg, tmp_stat);

        save_name = fullfile(res_dir, [conditions{ci}, '_neg', num2str(cli), '_chan.jpg']);
        saveas(fig, save_name);
        close(fig);
    end
end