% erp_to_freq: convert ERP data to frequency data

config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'freq_group_cond'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for gi = 1:length(groups)
    for ci = 1:num_type
        fname = fullfile(data_dir, [groups{gi}, '_', conditions{ci}, '.mat']);
        
        disp('loading...');
        load(fname); % include data

        % to freq
        cfg = [];
        cfg.method      = 'mtmconvol';
        cfg.taper       = 'hanning'; % ff
        cfg.foi         = 1:1:100;
        cfg.toi         = data.time{1}(1) : 0.05 : data.time{1}(end);
        cfg.t_ftimwin   = ones(length(cfg.foi), 1) .* 0.5;
        cfg.keeptrials   = 'yes';
        freq = ft_freqanalysis(cfg, data);

        % save 
        save(fullfile(res_dir, [groups{gi}, '_', conditions{ci}, '.mat']), 'freq', '-v7.3');
    end
end