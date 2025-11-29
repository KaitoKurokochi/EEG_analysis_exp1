prj_path = 'C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1';
% for each participants
participant_name = 'nov12';
% for each segment
vhdr_file_name = 'Kurokochi_Exp1_2025-11-25_12-06-02.vhdr';
sequence_file_name = 'sequence_5.csv';
save_name = 'seg5_v1.mat';
rawdata_path = fullfile(prj_path, 'rawdata');
result_path = fullfile(prj_path, 'result');
rawdata_participant_path = fullfile(rawdata_path, participant_name);
result_participant_path = fullfile(result_path, participant_name);
vhdr_file = fullfile(rawdata_participant_path, vhdr_file_name);
sequence_file = fullfile(rawdata_participant_path, sequence_file_name);
if ~exist(result_participant_path, 'dir')
    mkdir(result_participant_path);
    disp(['Created directory: ' result_participant_path]);
end
classified_file_name = fullfile(result_path, participant_name, 'v2.mat');
result_file = fullfile(result_participant_path, save_name);