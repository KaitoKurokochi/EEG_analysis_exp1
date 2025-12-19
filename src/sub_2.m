% sub 2: show average ERP data on graphs
%
% The result is saved in {prj_dir}/result/sub1/{participant_id}/xxx.jpg
%
% The graphs made in this program (i is segment number): 
% - power_{i}.jpg : sepctrum power graphs of v1_1
% - topo_{i}.jpg : spectrum topomap graphs of v1_1  

set_path;
groups = {'exp'};
s1_res_dir = fullfile(prj_dir, 'result', 'sub2');

for g = 1:length(groups)
    for i = 7:7
        pname = [groups{g}, num2str(i)];
        data_dir = fullfile(prj_dir, 'result', 'v1', pname);
        res_dir = fullfile(s1_res_dir, pname);
        if ~exist(res_dir, 'dir')
            mkdir(res_dir);
        end
        v1_fnames = dir(fullfile(data_dir, 'v1_*.mat'));
        
        n_seg = length(v1_fnames)/4;
        for j = 1:n_seg
            id = [pname, '-', num2str(j)];
            disp(['--- id: ', id, ', start processing ---']);
            
            % load each data
            v1_path = fullfile(data_dir, v1_fnames(j).name);
            load(v1_path); % includes data1

            %% delete noise channels
            cfg          = [];
            cfg.method   = 'summary';
            dummy        = ft_rejectvisual(cfg, data1);

            %% fig 
            spectr = my_calc_spectr(dummy);
            hFig1 = my_spectr_power_plot(spectr);
        end
    end
end

