function [data, cleaned_data, ica_result] = pre_processing(vhdr_path, sequence_path, id)
% eeg pre_processing file
% 1. read data and filtering 
% 2. define trial 
% 3. ICA (run ICA and remove artifacts)
%
%   [DATA] = EEG_PREPROCESS_AND_TFR(VHDR_PATH, SEQUENCE_PATH)
%
%   input:
%     VHDR_PATH: BrainVision VHDR file path 
%     SEQUENCE_PATH: sequence definition path 
%
%   output:
%     DATA: fieldtrip data structure after filtered

    % filtering 
    disp("--- filtering ---")
    cfg = [];
    cfg.bpfilter    = 'yes';
    cfg.bpfilttype  = 'fir';
    cfg.bpfreq      = [1 30];
    cfg.continuous  = 'yes'; 
    cfg.dataset     = vhdr_path;
    data = ft_preprocessing(cfg);

    % define trial and labeling 
    disp('--- clipping ---');
    cfg = [];
    % cfg.trialfun = 'mytrialfun'; % (exp6-12, nov6-12)
    cfg.trialfun = 'mytrialfun_2'; % (exp1-5, nov1-5)
    cfg.headerfile = vhdr_path;
    cfg.sequencefile = sequence_path;
    cfg = ft_definetrial(cfg);
    data = ft_redefinetrial(cfg, data);

    % ICA 
    disp('--- ICA ---');
    [cleaned_data, ica_result0] = my_autoica(data, id);

    % 2nd ICA
    [cleaned_data, ica_result] = my_autoica(cleaned_data, id);
end

