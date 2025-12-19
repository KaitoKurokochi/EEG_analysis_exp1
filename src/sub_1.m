% sub 1: show spectrum data on graphs
%
% The result is saved in {prj_dir}/result/sub1/{participant_id}/xxx.jpg
%
% The graphs made in this program (i is segment number): 
% - power_{i}.jpg : sepctrum power graphs of v1_1
% - topo_{i}.jpg : spectrum topomap graphs of v1_1  

set_path;
groups = {'nov', 'exp'};
s1_res_dir = fullfile(prj_dir, 'result', 'sub1');

for g = 1:length(groups)
    for i = 1:12
        pname = [groups{g}, num2str(i)];
        data_dir = fullfile(prj_dir, 'result', 'v1', pname);
        res_dir = fullfile(s1_res_dir, pname);
        if ~exist(res_dir, 'dir')
            mkdir(res_dir);
        end
        
        n_seg = length(dir(fullfile(data_dir, '*.mat')))/6;

        %%
        for j = 1:n_seg
            id = [pname, '-', num2str(j)];
            disp(['--- id: ', id, ', start processing ---']);
            
            % load each data
            v0_path = fullfile(data_dir, ['v0_', num2str(j), '_spectrum.mat']);
            v1_path = fullfile(data_dir, ['v1_', num2str(j), '_spectrum.mat']);
            v1_ica2_path = fullfile(data_dir, ['v1_', num2str(j), '_spectrum_ica2.mat']);
            load(v0_path); % includes data1
            load(v1_path);
            load(v1_ica2_path);

            %% figure 
            % power
            hFig = my_spectr_power_plot(spectr0);
            saveas(hFig, fullfile(res_dir, 'power_0.jpg'));
            close(hFig);
            hFig = my_spectr_power_plot(spectr1);
            saveas(hFig, fullfile(res_dir, 'power_1.jpg'));
            close(hFig);
            hFig = my_spectr_power_plot(spectr1_ica2);
            saveas(hFig, fullfile(res_dir, 'power_1_ica2.jpg'));
            close(hFig);

            % topo 
            hFig = my_freq_band_topomap(spectr0);
            saveas(hFig, fullfile(res_dir, 'topo_0.jpg'));
            close(hFig);
            hFig = my_freq_band_topomap(spectr1);
            saveas(hFig, fullfile(res_dir, 'topo_1.jpg'));
            close(hFig);
            hFig = my_freq_band_topomap(spectr1_ica2);
            saveas(hFig, fullfile(res_dir, 'topo_1_ica2.jpg'));
            close(hFig);
        end
    end
end

