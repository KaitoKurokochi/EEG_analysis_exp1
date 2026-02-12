% fig_freq_pow_topo: show freq power data (topomap)

config;

data_dir = fullfile(prj_dir, 'result', 'prepro3'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'fig_freq_pow_topo_prepro3'); % set res dir
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
            fig = figure('Position', [100, 100, 1600, 1200]);

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

                % baseline correction 
                cfg = [];
                cfg.baseline     = [-0.2 0.0];
                cfg.baselinetype = 'db';
                freq_db = ft_freqbaseline(cfg, freq);
    
                % figure
                subplot(2,3,b);
                cfg = [];
                cfg.layout      = 'easycapM11.mat';
                cfg.channel     = {'all', '-EOG'};
                cfg.parameter   = 'powspctrm'; % included in the result of ft_freqanalysis
                cfg.interactive = 'no';
                cfg.comment     = 'no';
                cfg.colorbar    = 'yes'; 
                cfg.figure      = 'gcf'; % get correct figure and add new plot in the window
                % cfg.marker       = 'labels';  % show channel name(string) on the graph 
                % cfg.markerfontsize = 8; 

                ft_topoplotER(cfg, freq);
            end
            saveas(fig, fullfile(res_dir, [id, '.jpg']));
            close(fig);
        end
    end
end