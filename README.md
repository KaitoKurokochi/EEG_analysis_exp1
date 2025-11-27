# Abstract 
This repository is for analysis of EEG in Exp1. 

# Dependency 
- You have to have `define_path.m` in `code` directory. In this code, `prj_path` should be defined. 

# flow of pre-processing
## clipping 
link: https://www.fieldtriptoolbox.org/tutorial/sensor/preprocessing_erp/
- -1.5 to 2.0sec around 's2'

## filtering
link: https://www.fieldtriptoolbox.org/tutorial/preproc/continuous/
- FIR filter 
- 1-30Hz

## ICA 
link: https://www.fieldtriptoolbox.org/example/preproc/ica_eog/

## IC-Label
link: https://www.fieldtriptoolbox.org/example/preproc/ica_eog/#identify-the-artifacts

cite for selection of noise labels: https://doi.org/10.1016/j.jneumeth.2015.01.030
