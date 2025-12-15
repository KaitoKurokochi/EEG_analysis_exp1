% sub 1: compare data before and after ICA processed, in terms of power of
% each channel (using my_spectr_power_plot)
% (v0 vs v1) 

%% define path
set_path;
groups = {'nov', 'exp'};

for g = 1:length(groups)
    for i = 1:12
        pname = [groups{g}, num2str(i)];
        data_dir = fullfile(prj_dir, 'result', pname);
        v0_spectr_fnames = dir(fullfile(data_dir, 'v0_*_spectrum.mat'));
        v1_spectr_fnames = dir(fullfile(data_dir, 'v1_*_spectrum.mat'));
        n_seg = length(v0_spectr_fnames);
        for j = 1:n_seg
            id = [pname, '-', num2str(j)];
            disp(['--- id: ', id, ', start processing ---']);

            % v0
            v0_spectr_path = fullfile(data_dir, v0_spectr_fnames(j).name);
            load(v0_spectr_path);
            my_spectr_power_plot(spectr1);
            figure_handle = gcf;
            saveas(figure_handle, fullfile(data_dir, ['sub1_0_', num2str(j), '.png']));
            close(figure_handle);

            %v1
            v1_spectr_path = fullfile(data_dir, v1_spectr_fnames(j).name);
            load(v1_spectr_path);
            my_spectr_power_plot(spectr2);
            figure_handle = gcf;
            saveas(figure_handle, fullfile(data_dir, ['sub1_1_', num2str(j), '.png']));
            close(figure_handle);
        end
    end
end

