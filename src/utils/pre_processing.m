function [cleaned_data, ica_result] = pre_processing(data, sequence_path, id, trialfun)
% eeg pre_processing file
% 1. filtering (1-30Hz)
% 2. define trial 
% 3. ICA (run ICA and remove artifacts)
%
%   [DATA] = EEG_PREPROCESS_AND_TFR(DATA, SEQUENCE_PATH, ID, TRIALFUN)
%
%   input:
%     DATA: data in fieldtrip format
%     SEQUENCE_PATH: sequence definition path 
%
%   output:
%     DATA: fieldtrip data structure after filtered
   
    vhdr = data.cfg.dataset; % use in clipping

    % filtering 
    disp("--- filtering ---")
    cfg = [];
    cfg.bpfilter    = 'yes';
    cfg.bpfilttype  = 'fir';
    cfg.bpfreq      = [1 30];
    cfg.continuous  = 'yes'; 
    data = ft_preprocessing(cfg, data);

    % define trial and labeling 
    disp('--- clipping ---');
    cfg = [];
    cfg.trialfun = trialfun;
    cfg.headerfile = vhdr;
    cfg.sequencefile = sequence_path;
    cfg = ft_definetrial(cfg);
    data = ft_redefinetrial(cfg, data);

    % ICA 
    disp('--- ICA ---');
    [cleaned_data, ica_result] = my_autoica(data, id);
end

