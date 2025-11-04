%% default 
data_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov7"; % adjust for each participants 
result_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\nov7"; % adjust for each participants 

%% read data 
% EEG data
vhdr_list = dir(fullfile(data_path, '*.vhdr'));
assert(~isempty(vhdr_list), 'No .vhdr files in: %s', data_path);
names = {vhdr_list.name};
datasets = fullfile(data_path, names);

cfg = [];
cfg.continuous = 'yes';
cfg.dataset = datasets;
data = ft_preprocessing(cfg);

%% events 
target_triggers = {'s1','s2','s4','s32'};
per_file_counts = zeros(numel(names), numel(target_triggers));

for fi = 1:numel(names)
    vhdr_path = fullfile(data_path, names{fi});
    ev = ft_read_event(vhdr_path);

    event_values = {ev.value};

    for ti = 1:numel(target_triggers)
        per_file_counts(fi, ti) = sum(strcmp(event_values, target_triggers{ti}));
    end
end

T_file = table(string(names)', per_file_counts(:,1), per_file_counts(:,2), ...
    per_file_counts(:,3), per_file_counts(:,4), ...
    'VariableNames', {'vhdr','s1','s2','s4','s32'});

disp('--- Trigger counts per .vhdr file ---');
disp(T_file);

%% data shower 
cfgv = [];
cfgv.viewmode  = 'butterfly';
cfgv.blocksize = 10;
cfgv.plotevents = 'yes';
ft_databrowser(cfgv, data);