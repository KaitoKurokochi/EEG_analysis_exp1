% input: need to set participant's name, vhdrfile name, sequencefile name, savefile name
% - rawdata/{participant}/*.eeg, *.vhdr, *.vmrk
% - rawdata/{participant}/sequence_x.csv

vhdr_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov5\Nakabayashi_20250117_2025-01-17_11-43-41.vhdr";
sequence_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov5\sequence_2.csv";

% read data 
cfg = [];
cfg.trialfun = 'mytrialfun_2';
cfg.headerfile = vhdr_path;
cfg.sequencefile = sequence_path;
cfg = ft_definetrial(cfg);

%%
task_res = cfg.trl(:, 4);

n_trial = 0;
n_correct = 0;

for i = 1:length(task_res)
    if task_res(i) == -1
        continue;
    end

    n_trial = n_trial+1;
    if task_res(i) > 0
        n_correct = n_correct+1;
    end
end

disp(['n_trial: ' num2str(n_trial) ', n_correct: ' num2str(n_correct)]);
disp(['accuracy: ' num2str(n_correct/n_trial)]);

%%
T_sequence = readtable(sequence_path);
keys = T_sequence{:, 'Key'};

ff_c = 0;
ff_i = 0;
fc_c = 0;
fc_i = 0;
cf_c = 0;
cf_i = 0;
cc_c = 0;
cc_i = 0;

for i = 1:length(task_res)
    if strcmp(keys{i}, 'ff')
        if task_res(i) == 0 
            ff_i = ff_i + 1;
        else 
            ff_c = ff_c + 1;
        end
    elseif strcmp(keys{i}, 'fc')
        if task_res(i) == 0 
            fc_i = fc_i + 1;
        else 
            fc_c = fc_c + 1;
        end
    elseif strcmp(keys{i}, 'cf')
        if task_res(i) == 0 
            cf_i = cf_i + 1;
        else 
            cf_c = cf_c + 1;
        end
    elseif strcmp(keys{i}, 'cc')
        if task_res(i) == 0 
            cc_i = cc_i + 1;
        else 
            cc_c = cc_c + 1;
        end
    end
end

disp(['FF Correct: ' num2str(ff_c) ', Incorrect: ' num2str(ff_i)]);
disp(['FC Correct: ' num2str(fc_c) ', Incorrect: ' num2str(fc_i)]);
disp(['CF Correct: ' num2str(cf_c) ', Incorrect: ' num2str(cf_i)]);
disp(['CC Correct: ' num2str(cc_c) ', Incorrect: ' num2str(cc_i)]);

