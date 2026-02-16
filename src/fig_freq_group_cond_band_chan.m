% fig_freq_group_cond: figure time x frequency data for each group,
% conditions

config;

data_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_group_cond_band_chan'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% define_bands (frequency band, name of the band, zlim)
bands = { ...
    [1 4],   'Delta',      [0 0.1]; ...
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

%% 
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
            % cfg.zlim             = bands{b, 3};
            cfg.baseline         = [-0.2 0];
            cfg.baselinetype     = 'db';
            cfg.showlabels       = 'yes';
            ft_multiplotTFR(cfg, freq);
    
            saveas(fig, fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '_', bands{b, 2}, '.jpg']));
            close(fig);
        end
    end
end