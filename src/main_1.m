% main_1: segment-base processing 
% -> v1 (pre-processed)

%% define path
set_path;
pname = "nov12";
vhdr_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov12\Kurokochi_Exp1_2025-11-25_11-09-15.vhdr";
sequence_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\nov12\sequence_1.csv";
v1_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\nov12";
id = strcat(pname, "-", "1"); 

%% for each participants 
[data, ica_result] = pre_processing(vhdr_path, sequence_path, id);

%% save 
% save(fullfile(v1_path, 'seg1_v1.mat'), 'data', '-v7.3');