% redefine trials: cluster-based permutation test (Response-locked)
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'erp_group_cond'); 
res_dir  = fullfile(prj_dir, 'result', 'erp_res_lock'); 
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

cond = 'go';
redef_int = 0.4; % 0.8 sec around response

% load data
disp(['--- loading ERP data: ', cond, ' ---']);
load(fullfile(data_dir, ['exp', '_', cond, '.mat'])); 
data_exp = data; clear data;
load(fullfile(data_dir, ['nov', '_', cond, '.mat'])); 
data_nov = data; clear data;

% realign - exp
rt_exp  = data_exp.trialinfo(:, 2); 
for i = 1:numel(data_exp.time)
    data_exp.time{i} = data_exp.time{i} - rt_exp(i);
end

cfg_re = [];
cfg_re.toilim = [-redef_int redef_int];
data = ft_redefinetrial(cfg_re, data_exp);

save(fullfile(res_dir, ['exp', '_', cond, '.mat']), 'data', '-v7.3');

% realign - nov
rt_nov  = data_nov.trialinfo(:, 2); 
for i = 1:numel(data_nov.time)
    data_nov.time{i} = data_nov.time{i} - rt_nov(i);
end

cfg_re = [];
cfg_re.toilim = [-redef_int redef_int];
data = ft_redefinetrial(cfg_re, data_nov);

save(fullfile(res_dir, ['nov', '_', cond, '.mat']), 'data', '-v7.3');

%% figure 
clear;
config;

data_dir = fullfile(prj_dir, 'result', 'erp_res_lock'); 
res_dir  = fullfile(prj_dir, 'result', 'fig_erp_res_lock'); 
if ~exist(res_dir, 'dir'), mkdir(res_dir); end

cond = 'go';

% load data
disp(['--- loading ERP data: ', cond, ' ---']);
load(fullfile(data_dir, ['exp', '_', cond, '.mat'])); 
data_exp = data; clear data;
load(fullfile(data_dir, ['nov', '_', cond, '.mat'])); 
data_nov = data; clear data;

cfg = [];
cfg.covariance         = 'yes';
data_exp = ft_timelockanalysis(cfg, data_exp);
data_nov = ft_timelockanalysis(cfg, data_nov);

for chi = 1:length(data_exp.label)
    fig = figure('Position', [100, 100, 1600, 1200], 'Visible', 'off');

    cfg = [];
    cfg.channel       = data_exp.label{chi};
    cfg.errorkit      = 'shadedcloud';
    cfg.errorbar      = 'sem';
    cfg.linewidth     = 2;
    ft_singleplotER(cfg, data_exp, data_nov);

    grid on
    saveas(fig, fullfile(res_dir, [cond, '_', data_exp.label{chi}, '.jpg']));
    close(fig);
end