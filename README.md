# Abstract 
This repository is for analysis of EEG in Exp1. 

# Dependency 
- You have to have `define_path.m` in `code` directory. In this code, `prj_path` should be defined. 

# task result 
recorded in `cfg.trl` or `data.trialinfo`
Accuracy can be calculated by `calc_accuracy.m`

signals are 
- -1: missing data 
- 0: incorrect 
- 1: ff correct 
- 2: fc correct 
- 3: cf correct 
- 4: cc correct 

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
- N of pca: 20 
- channel: remove EOG

## IC-Label
link: https://www.fieldtriptoolbox.org/example/preproc/ica_eog/#identify-the-artifacts

## remove noise comps
cite for selection of noise labels: https://doi.org/10.1016/j.jneumeth.2015.01.030
