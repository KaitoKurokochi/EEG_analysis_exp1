%% default 
data_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\exp11"; % adjust for each participants 
result_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\exp11"; % adjust for each participants 

%% read data 
vhdr_list = dir(fullfile(data_path, '*.vhdr'));
datasets = fullfile(data_path, {vhdr_list.name}); 
alldata = cell(1, numel(datasets));

for i = 1:numel(datasets)
    cfg = [];
    cfg.dataset = datasets{i};
    cfg.continuous = 'yes';
    % epoching
    cfg.trialdef.eventtype = 'Stimulus';
    cfg.trialdef.eventvalue = {'s2'};
    cfg.trialdef.prestim = 1.5;
    cfg.trialdef.poststim = 2.0;
    
    cfg = ft_definetrial(cfg);
    data = ft_preprocessing(cfg);

    event = ft_read_event(datasets{i});
    data.cfg.event = event;

    alldata{i} = data;
end


%% data visualizer 
for i = 1:numel(alldata)
    cfgv = [];
    cfgv.viewmode   = 'butterfly'; 
    cfgv.plotevents = 'yes'; 
    cfgv.channel    = {'Cz'};
    ft_databrowser(cfgv, alldata{i});
    disp('end');
end
