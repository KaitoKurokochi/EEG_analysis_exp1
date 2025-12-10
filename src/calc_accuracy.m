% input: need to set participant's name, vhdrfile name, sequencefile name, savefile name
% - rawdata/{participant}/*.eeg, *.vhdr, *.vmrk
% - rawdata/{participant}/sequence_x.csv

vhdr_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov12\Kurokochi_Exp1_2025-11-25_12-06-02.vhdr";
sequence_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov12\sequence_5.csv";

% read data 
cfg = [];
cfg.trialfun = 'mytrialfun';
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

