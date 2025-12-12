function [spectr] = my_spectr_power_plot(spectr)
% input: 
%     spectr(struct): EEG spectrum data in fieldtrip format

    % plot [freq x power] graph
    channel_indices = ~cellfun(@(x) strcmp(x, 'EOG'), spectr.label);
    pow_to_plot = nanmean(spectr.powspctrm(channel_indices, :, :), 3);
    
    figure;
    plot(spectr.freq, pow_to_plot');
    xlabel('Frequency (Hz)');
    ylabel('absolute power (uV^2)');

