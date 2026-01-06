% sub 1: show spectrum data on graphs
%
% The result is saved in {prj_dir}/result/sub1/{participant_id}/xxx.jpg
%
% The graphs made in this program: 
% - {id}_power.jpg : sepctrum power graphs of v1_3
% - {id}_topo.jpg : spectrum topomap graphs of v1_3 

config;

data_dir = fullfile(prj_dir, 'result', 'v1_3');
res_dir = fullfile(prj_dir, 'result', 'sub1');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

data_fnames = {dir(fullfile(data_dir, '*.mat')).name};

for i = 1:length(data_fnames)
    load(fullfile(data_dir, data_fnames{i})); % include data_v1_3

    id = erase(data_fnames{i}, '.mat');
    disp(['--- id: ', id, ', start processing ---']);

    spectr = my_calc_spectr(data_v1_3);

    %%
    hFig = my_spectr_power_plot(spectr);
    saveas(hFig, fullfile(res_dir, [id, '_power.jpg']));
    close(hFig);

    hFig = my_freq_band_topomap(spectr);
    saveas(hFig, fullfile(res_dir, [id, '_topo.jpg']));
    close(hFig);
end