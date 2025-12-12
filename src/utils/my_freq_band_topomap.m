function my_freq_band_topomap(spectr)
% input: 
%     spectr(struct): EEG spectrum data in fieldtrip format
    
    % define_bands (frequency band, name of the band, zlim)
    bands = { ...
        [1 4],   '\Delta',      [0 0.1]; ...
        [4 7],   '\Theta',      [0 0.025]; ...
        [7 13],  '\alpha',      [0 17*10^-3]; ...
        [13 30], '\beta',      [0 7*10^-3]; ...
        %[30 45], 'Low_γ',  [0 12.5*10^-4]; ...
        %[60 90], 'High_γ', [0 5*10^-6]
        };

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

    figure('Name','Topographies by band (Individually Fixed Color Scale)');
    for k = 1:size(bands,1)
        subplot(2,2,k); % order in 2x2
        cfg.xlim = bands{k,1}; % xlim = frequecy band
        % cfg.zlim = bands{k,3};
        
        ft_topoplotER(cfg, spectr);
        title(bands{k,2}, 'Interpreter', 'tex', 'FontSize', 14, 'FontWeight', 'bold');

        h = colorbar;
        h.FontSize = 14; 
    end