function [cleaned_data, ica_result] = my_autoica(data, id)
%MY_AUTOICA 
% input: 
%   data: EEG data (with .trial, .time, .label)
% output: 
%   cleaned_data: data after cleaned (fieldtrip format)

    % init eeglab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab('nogui');
    EEG = eeg_emptyset;

    % translate data from fieldtrip format into EEGLAB format
    EEG.data = data.trial{1, 1};
    EEG.srate = data.fsample;
    EEG.nbchan = size(EEG.data, 1);
    EEG.pnts = size(EEG.data, 2);
    EEG.trials = 1;
    EEG.times = (0:EEG.pnts-1) / EEG.srate;
    EEG.setname = id;
    EEG.chanlocs = struct('labels', data.label);
    EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp'); % for GUI

    % remove 'EOG'
    idx_no_eog = ~strcmp(data.label, 'EOG');
    ica_channels = find(idx_no_eog);

    % run ICA
    EEG = pop_runica(EEG, 'extended', 1, 'interrupt', 'on', 'chanind', ica_channels);
    EEG = pop_iclabel(EEG, 'default'); % Classify components using ICLabel

    % make a result of ica 
    ica_result = struct();
    ica_result.EEG = EEG;
    ica_result.timestamp = datetime('now');
    ica_result.icaweights = EEG.icaweights;
    ica_result.icasphere = EEG.icasphere;
    ica_result.icawinv = EEG.icawinv;
    ica_result.inputdataname = id;
    ica_result.ic_classification = EEG.etc.ic_classification; % ic-classification info

    % automatic artifact removal 
    artifact_threshold = 0.8;
    artifact_threshold_muscle = 0.3;

    artifact_ICs = find(...
        EEG.etc.ic_classification.ICLabel.classifications(:,2) >= artifact_threshold_muscle | ... % Muscle
        EEG.etc.ic_classification.ICLabel.classifications(:,3) >= artifact_threshold | ...       % Eye
        EEG.etc.ic_classification.ICLabel.classifications(:,4) >= artifact_threshold | ...       % Heart
        EEG.etc.ic_classification.ICLabel.classifications(:,5) >= artifact_threshold | ...       % Line Noise
        EEG.etc.ic_classification.ICLabel.classifications(:,6) >= artifact_threshold);           % Channel Noise

    fprintf('Removing %d artifact components out of %d total ICs\n', ...
            length(artifact_ICs), size(EEG.icaweights, 1));

    % remove artifact ICs from EEG data
    EEG = pop_subcomp(EEG, artifact_ICs, 0);
    
    % data replacement
    cleaned_data = data;
    cleaned_data.time{1,1} = EEG.times; % simply replacement
    cleaned_data.trial{1,1} = EEG.data; % simply replacement
end

