% erp_to_freq: convert ERP data to frequency data
% no method -> no normalization 
% sum -> 

%% config 
config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:length(conditions)
    %     fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']);
    % 
    %     disp('loading...');
    %     load(fname); % include data
    % 
    %     % to freq
    %     cfg = [];
    %     cfg.method      = 'mtmconvol';
    %     cfg.taper       = 'hanning'; % ff
    %     cfg.foi         = 1:1:100;
    %     cfg.toi         = data.time{1}(1) : 0.05 : data.time{1}(end);
    %     cfg.t_ftimwin   = ones(length(cfg.foi), 1) .* 0.5;
    %     cfg.keeptrials   = 'yes';
    %     freq = ft_freqanalysis(cfg, data);
    % 
    %     % save 
    %     save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.mat']), 'freq', '-v7.3');

        fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']); % incoude data
        disp('loading...');
        load(fname); % include data

        cfg = [];
        cfg.method      = 'wavelet';
        cfg.output      = 'pow';
        cfg.keeptrials  = 'yes';
        cfg.foi         = logspace(log10(3),log10(90),30);
        cfg.width       = logspace(log10(3),log10(30),30);
        cfg.toi         = data.time{1}(1) : 0.05 : data.time{1}(end);
        freq = ft_freqanalysis(cfg, data);

        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.mat']), 'freq', '-v7.3');
    end
end

%% fig - all channels
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_group_cond_band_chan'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% define_bands (frequency band, name of the band, zlim)
bands = { ...
    % [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]
    };

% set baseline type
baseline_type = 'db';

for gi = 1:length(groups)
    for ci = 1:length(conditions)
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat'])); % include freq
        for b = 2:length(bands)
            % figure
            fig = figure('Position', [100, 100, 1600, 1200]);
            % multiplot
            cfg = [];
            cfg.layout           = 'easycapM11.mat';
            cfg.xlim             = [0.0 0.6];
            cfg.ylim             = [bands{b, 1}(1), bands{b, 1}(2)];
            cfg.zlim             = 'maxabs';
            % cfg.zlim             = bands{b, 3};
            cfg.baseline         = [-0.2 0];
            cfg.baselinetype     = baseline_type;
            cfg.showlabels       = 'yes';
            ft_multiplotTFR(cfg, freq);
            saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', bands{b, 2}, '_', baseline_type, '.jpg']));
            close(fig);
        end
    end
end

%% fig - topomap
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_group_cond_band_topo'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% set baseline type
baseline_type = 'db';

% define_bands (frequency band, name of the band, zlim)
bands = { ...
    % [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_gamma',  [0 12.5*10^-4]; ...
    [60 90], 'High_gamma', [0 5*10^-6]
    };
% bands = { ...
%     [1 4],   '\Delta',      [0 0.1]; ...
%     [4 7],   '\Theta',      [0 0.025]; ...
%     [7 13],  '\alpha',      [0 17*10^-3]; ...
%     [13 30], '\beta',      [0 7*10^-3]; ...
%     [30 45], 'Low_γ',  [0 12.5*10^-4]; ...
%     [60 90], 'High_γ', [0 5*10^-6]
%     };

%
for gi = 1:length(groups)
    for ci = 1:length(conditions)
        disp('loading...');
        load(fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat'])); % include freq

        % for each 50ms
        for t = 0:0.05:0.55
            for b = 2:length(bands)
                t_strt = t;
                t_end = t+0.05;
    
                fig = figure('Position', [100, 100, 800, 600], 'Visible', 'off');
    
                cfg = [];
                cfg.xlim               = [t_strt, t_end];
                cfg.ylim               = [bands{b, 1}(1), bands{b, 1}(2)];
                cfg.baseline           = 'yes';
                cfg.baselinetype       = baseline_type;
                cfg.colorbar           = 'yes';
                cfg.layout             = 'easycapM11.mat';
                ft_topoplotTFR(cfg, freq);
                saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', bands{b, 2}, '_', num2str(t_strt*1000), '_', num2str(t_end*1000), '_', baseline_type, '.jpg']));
                close(fig);
            end
        end
    end
end
