%% default 
data_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov6"; % adjust for each participants 
result_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\nov6"; % adjust for each participants 

%% read data and filtering 
% EEG data
vhdr_list = dir(fullfile(data_path, '*.vhdr'));
assert(~isempty(vhdr_list), 'No .vhdr files in: %s', data_path);

%% dummy 
cfg = [];
cfg.dataset             = fullfile(data_path, vhdr_list(1).name);
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);


%% preprocessing
cfg = [];
cfg.hpfilttype = 'fir';
cfg.lpfilter = 'yes';
cfg.lpfreq = 30;
cfg.hpfilter = 'yes';
cfg.hpfreq= 1;
cfg.continuous = 'yes';

data_sets = cell(1, numel(vhdr_list));
for i = 1:numel(vhdr_list)
    cfg0 = cfg;
    cfg0.dataset = fullfile(data_path, vhdr_list(i).name); 
    data_sets{i} = ft_preprocessing(cfg0);
end

disp("finish processing")

