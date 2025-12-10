% main_1: segment-base processing 
% -> v1 (pre-processed)

%% define path
set_path;
pname = "exp1";
vhdr_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\exp1\Kawamura_20250111_2025-01-11_15-37-33.vhdr";
sequence_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\rawdata\exp1\sequence_1.csv";
v1_path = "C:\Users\kaito\workspace\2025_exp1\EEG_analysis_exp1\result\exp1";

%% for each participants 
data = pre_processing(vhdr_path, sequence_path);

%% save 
save(fullfile(v1_path, 'seg1_v1.mat'), 'data', '-v7.3');