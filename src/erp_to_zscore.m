% erp_to_zscore: convert ERP data to zscore(group-condtion level)

config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'erp_zscore_group_cond'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:num_type
        fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']);
        
        disp('loading...');
        load(fname); % include data

        

    end
end