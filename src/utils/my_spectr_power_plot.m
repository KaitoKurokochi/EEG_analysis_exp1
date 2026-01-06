function [fig] = my_spectr_power_plot(spectr)
% 
% input: 
%     spectr(struct): EEG spectrum data in fieldtrip format

    % plot [freq x power] graph
    channel_indices = ~cellfun(@(x) strcmp(x, 'EOG'), spectr.label);
    pow_to_plot = nanmean(spectr.powspctrm(channel_indices, :, :), 3);
    labels_to_plot = spectr.label(channel_indices);
    
    fig = figure;
    disp(size(spectr.freq));
    disp(size(pow_to_plot'));
    plot(spectr.freq, pow_to_plot');
    xlabel('Frequency (Hz)');
    ylabel('absolute power (uV^2)');
    legend(labels_to_plot, 'Location', 'northeastoutside', 'Interpreter', 'none', 'NumColumns', 3);
end

