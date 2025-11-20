%% define path  
data_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov11"; % adjust for each participants 
result_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\nov11"; % adjust for each participants 

%% define vhdr list
% EEG data
vhdr_list = dir(fullfile(data_path, '*.vhdr'));
assert(~isempty(vhdr_list), 'No .vhdr files in: %s', data_path);

%% check the dataset
cfg = [];
cfg.dataset             = fullfile(data_path, vhdr_list(5).name);
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);

%% load data and clipping 
cfg = [];
cfg.trialfun = 'mytrialfun';

data_sets = cell(1, numel(vhdr_list));
for i = 1:numel(vhdr_list)
    cfg0 = cfg;
    cfg0.dataset = fullfile(data_path, vhdr_list(i).name);
    cfg0 = ft_definetrial(cfg0);
    data_sets{i} = ft_preprocessing(cfg0);
end

%% filtering 
cfg_flt = [];
cfg_flt.hpfilttype = 'fir';
cfg_flt.lpfilter = 'yes';
cfg_flt.lpfreq = 30;
cfg_flt.hpfilter = 'yes';
cfg_flt.hpfreq= 1;

for i = 1:numel(vhdr_list)
    data_sets{i} = ft_preprocessing(cfg_flt, data_sets{i});
end

disp("finish processing")

