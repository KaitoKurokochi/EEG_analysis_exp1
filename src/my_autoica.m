function [cleaned_data] = my_autoica(data)
%MY_AUTOICA 
% input: 
%   data: EEG data (with .trial, .time, .label)
% output: 
%   cleaned_data: data after cleaned (fieldtrip format)

    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab('nogui');
    EEG = eeg_emptyset;

    % data config
    EEG.data = data.trial{1, 1};
    EEG.srate = data.fsample;
    EEG.nbchan = size(EEG.data, 1);
    EEG.pnts = size(EEG.data, 2);
    EEG.trials = 1;
    EEG.times = (0:EEG.pnts-1) / EEG.srate;
    EEG.setname = 'MyEEGData';
    EEG.chanlocs = struct('labels', data.label);
    disp(data.label);
    EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp');

    % remove 'EOG'
    eog_idx = find(strcmp(data.label, 'EOG'));
    ica_channels = [1:64];
    ica_channels(eog_idx) = [];

    % run 
    EEG = pop_runica(EEG, 'extended', 1, 'interrupt', 'on', 'chanind', ica_channels);
    EEG = pop_iclabel(EEG, 'default');
end

