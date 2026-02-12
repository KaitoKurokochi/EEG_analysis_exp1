% fig_freq_pow_all_chan: show TFR power data (multiple channels)

config;

data_dir = fullfile(prj_dir, 'result', 'prepro3'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_pow_all_chan_prepro3'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% define_bands (frequency band, name of the band, zlim)
bands = { ...
    [1 4],   'Delta',      [0 0.1]; ...
    [4 7],   'Theta',      [0 0.025]; ...
    [7 13],  'alpha',      [0 17*10^-3]; ...
    [13 30], 'beta',      [0 7*10^-3]; ...
    [30 45], 'Low_g',  [0 12.5*10^-4]; ...
    [60 90], 'High_g', [0 5*10^-6]
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
for i = 1:length(groups)
    for j = 1:12
        for k = 1:5
            id = [groups{i}, num2str(j), '-', num2str(k)];
            
            fname = fullfile(data_dir, [id, '.mat']);
            if ~exist(fname, 'file')
                continue;
            end

            disp('loading...');
            load(fname); % include data
            
            disp(['--- id: ', id, ', start processing ---']);

            for b = 2:length(bands)
                % calc freq
                cfg           = [];
                cfg.output    = 'pow';
                cfg.method    = 'mtmconvol';
                cfg.taper     = 'hanning';
                cfg.toi       = -0.500 : 0.050 : 1.000;
                cfg.foi       = bands{b, 1}(1):1.0:bands{b,1}(2);
                cfg.t_ftimwin = 5 ./ cfg.foi; % 5 cycles
                freq = ft_freqanalysis(cfg, data);
    
                % figure
                fig = figure('Position', [100, 100, 1600, 1200]);
                % multiplot
                cfg = [];
                cfg.layout           = 'easycapM11.mat';
                cfg.xlim             = [0.0 0.6];
                cfg.ylim             = bands{b, 1}(1):1.0:bands{b,1}(2);
                % cfg.zlim             = bands{b, 3};
                cfg.baseline         = [-0.2 0];
                cfg.baselinetype     = 'db';
                cfg.showlabels       = 'yes';
                ft_multiplotTFR(cfg, freq);
    
                saveas(fig, fullfile(res_dir, [id, '_', bands{b, 2}, '.jpg']));
                close(fig);
            end
        end
    end
end