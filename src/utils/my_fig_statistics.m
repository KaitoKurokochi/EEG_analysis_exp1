function [fig_perm, fig_zscore, p_POS] = my_fig_statistics(data1, data2)
% data1, data2: fieldtrip format data for 1 channel

% adjusting data format ([ ] -> [time x frequency x trials])
data1_trans = data1.powspctrm(:, 1, :, :);
data1_trans = squeeze(data1_trans);
data1_trans = permute(data1_trans, [2, 3, 1]);

data2_trans = data2.powspctrm(:, 1, :, :);
data2_trans = squeeze(data2_trans);
data2_trans = permute(data2_trans, [2, 3, 1]);

[p_POS, p_zPOS] = my_calc_statistics(data1_trans, data2_trans);
wavfreqs = data1.freq;
wavtimes = data1.time;

% hfig = figure('Position', [100, 100, 1200, 400]); 
% % p_circWW
% subplot(1,3,1); surf(wavtimes,wavfreqs,-log10(p_circWW)); hold on; set(gcf,'renderer','zbuffer');
% title('circWW (-log10(p-values))'); shading interp; view(0,90); axis tight;
% colormap('hot'); clim = get(gca,'clim'); colorbar; set(gca,'clim',[0 clim(2)]); 
% plot3([0 0],[2 30],[clim(2) clim(2)],'w--'); xlabel('time (s)'); ylabel('frequency (hz)');

% p_POS - fig1
fig_perm = figure(1);

plot_data = -log10(p_POS);
threshold = 3.0;
plot_data(plot_data < threshold) = 0.0;

surf(wavtimes, wavfreqs, plot_data); 
hold on;
title('POS (-log10(p-values) from perm.)'); 
shading interp; 
view(0,90); 
axis tight;
colormap('hot');
c = colorbar;
ylabel(c, '-log_{10}(p)');
curr_lim = get(gca, 'clim');
% set(gca, 'clim', [0.0 curr_lim(2)]);
plot3([0 0], [2 30], [curr_lim(2) curr_lim(2)], 'w--', 'LineWidth', 1.5); 
xlabel('Time (s)'); 
ylabel('Frequency (Hz)');

% p_zPOS - fig2
fig_zscore = figure(2);
surf(wavtimes, wavfreqs, -log10(p_zPOS)); 
hold on;
title('POS (-log10(p-values) from zscore.)'); 
shading interp; 
view(0, 90); 
axis tight;
colormap('hot'); 
c = colorbar; 
ylabel(c, '-log_{10}(p)');
curr_lim = get(gca, 'clim');
set(gca, 'clim', [0 curr_lim(2)]);

plot3([0 0], [2 30], [curr_lim(2) curr_lim(2)], 'w--', 'LineWidth', 1.5); 
xlabel('Time (s)'); 
ylabel('Frequency (Hz)');
end

