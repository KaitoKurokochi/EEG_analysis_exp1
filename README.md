# Abstract 
This repository is for analysis of EEG in Exp1. 

# Dependency 
- You have to have `define_path.m` in `code` directory. In this code, `prj_path` should be defined. 

# flow of pre-processing
## clipping 
cite: https://www.fieldtriptoolbox.org/tutorial/sensor/preprocessing_erp/
- -1.5 to 2.0sec around 's2'

## filtering
cite: https://www.fieldtriptoolbox.org/tutorial/preproc/continuous/
- FIR filter 
- 1-30Hz
