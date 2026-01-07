function [fig] = my_spectr_power_plot(spectr)
% 
% input: 
%     spectr(struct): EEG spectrum data (rep x chan x freq) in fieldtrip format

    % plot [freq x power] graph
    channel_indices = ~cellfun(@(x) strcmp(x, 'EOG'), spectr.label);
    labels_to_plot = spectr.label(channel_indices);

    avg_pow = squeeze(mean(mean(spectr.powspctrm, 1, 'omitnan'), 4, 'omitnan'));
    pow_to_plot = avg_pow(channel_indices, :);
    
    fig = figure;
    plot(spectr.freq, pow_to_plot');
    xlabel('Frequency (Hz)');
    ylabel('absolute power (uV^2)');
    legend(labels_to_plot, 'Location', 'northeastoutside', 'Interpreter', 'none', 'NumColumns', 3);
end

