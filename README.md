# Abstract 
This repository is for analysis of EEG in Kurokochi-Exp1. 
The flow of the processing is like below, 
1. define path 
2. calculate accuracy 
3. find missing trials
4. pre-processing 

# Path setting 
- Read [this page](https://www.fieldtriptoolbox.org/faq/matlab/installation/) 
- If you've got EEGLAB in your computer, I recommend that you delete the EEGLAB direcotry. It is likely to occur some path conflicts.

# Dependency 
- MATLAB: R2024b 
- fieldtrip: clone from github in Nov 2025

# Programs
## define path  
You have to have `define_path.m` like below.  
``` matlab 
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
```

## find missing trial 
execute `calc_accuracy.m` and if the accuracy of the task is lower, you need to find missing trial 

-> execute `find_missing.m` and modify sequence files

## pre-processing
### filtering
using `ft_preprocessing`

link: https://www.fieldtriptoolbox.org/tutorial/preproc/continuous/
- FIR filter 
- 1-30Hz

### clipping 
link: https://www.fieldtriptoolbox.org/tutorial/sensor/preprocessing_erp/

clipping -1.5 to 2.0sec around 's2', using `mytrialdef`, `ft_redefinetrial`

In the function, using `ft_read_header`, `ft_read_event`

recorded in `cfg.trl` or `data.trialinfo`
Accuracy can be calculated by `calc_accuracy.m`

signals are 
- -1: missing data 
- 0: incorrect 
- 1: ff correct 
- 2: fc correct 
- 3: cf correct 
- 4: cc correct 

### ICA 
link: https://www.fieldtriptoolbox.org/example/preproc/ica_eog/
- N of pca: 20 
- channel: remove EOG
- using `ft_componentanalysis`

### IC-Label
link: https://www.fieldtriptoolbox.org/example/preproc/ica_eog/#identify-the-artifacts

using `ft_topoplotIC`, `ft_databrowser`

### remove noise comps
cite for selection of noise labels: https://doi.org/10.1016/j.jneumeth.2015.01.030

using `ft_rejectcomponent`

### save data 
- filename: `seg{x}_v1.mat`

## classify trials based on the trial information  
### read data 
- filename: `{result_paricipant_path}/*_v1.mat`

### classify data 
- using `ft_selectdata`, `ft_appenddata`

### save 
- filename: `v2.mat`
