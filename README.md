# Abstract 
This repository is for analysis of EEG in Kurokochi-Exp1. 
The flow of the processing is like below, 
1. define path 
2. calculate accuracy 
3. find missing trials
4. pre-processing 
5. group concat
6. group comparison

# Path setting 
- Read [this page](https://www.fieldtriptoolbox.org/faq/matlab/installation/) 
- If you've got EEGLAB in your computer, I recommend that you delete the EEGLAB direcotry. It is likely to occur some path conflicts.
- add `set_path.m` in `src`, define the directory path that this repository is put in as `prj_dir`
- add `addpath("utils\");` in`set_path.m`

# Dependencies 
- MATLAB: R2024b 
- fieldtrip: clone from github in Nov 2025

# Data explanation 
- `result/v0/{pname}_{i}.mat`: rawdata of {pname}, segment {i}
- `result/v1_1/{pname}_{i}.mat`: pre-processed data, after artifact components removed 
- `result/v1_2/{pname}_{i}.mat`: after noise channels interpolated 
- `result/v2/{name}.mat`: classified data
- `reuslt/v3/{group_name}.mat`: after group concat 
