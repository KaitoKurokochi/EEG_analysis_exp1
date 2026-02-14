function stat_result = myf_cluster_statistics(A, B, foi_contrast)
% MYF_CLUSTER_STATISTICS A > B の片側クラスターベース順列検定を実行
%
%   入力:
%     A, B: (nsubj, nchan, nfreq) の3D行列 (Aが条件1, Bが条件2)
%     foi_contrast: (オプション) 周波数インデックスのベクトル (デフォルト: [1 2 3 4 5 6])
%
%   出力:
%     stat_result: 各バンドごとの統計結果を格納した構造体

    % デフォルト設定
    bands = {'delta','theta','alpha','beta','low_gamma','high_gamma'};
    if nargin < 3
        foi_contrast = [1 2 3 4 5 6];
    end

    % FieldTrip構造体作成 (A: 条件1, B: 条件2)
    template_freq = load("data\template_freq.mat", "template_freq");
    ind_pre_A = template_freq.template_freq;  % A: 条件1
    ind_pre_A.powspctrm = A;
    ind_pre_A.freq = [1 2 3 4 5 6];
    ind_pre_A.dimord = 'subj_chan_freq';

    ind_pre_B = template_freq.template_freq;  % B: 条件2
    ind_pre_B.powspctrm = B;
    ind_pre_B.freq = [1 2 3 4 5 6];
    ind_pre_B.dimord = 'subj_chan_freq';

    % 統計解析の設定 (A > B の片側検定)
    neighbours = load('data\neighbours.mat', 'neighbours');

    cfg = [];
    cfg.channel          = {'all', '-EOG'};
    cfg.parameter        = 'powspctrm';
    cfg.method           = 'ft_statistics_montecarlo';
    cfg.statistic        = 'ft_statfun_depsamplesT';
    cfg.correctm         = 'cluster';
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsize';
    cfg.clusterthreshold = 'nonparametric_common';
    cfg.minnbchan        = 2;
    cfg.tail             = 1;  % A > B の片側検定
    cfg.clustertail      = cfg.tail;
    cfg.alpha            = 0.05;
    cfg.correcttail      = 'alpha';
    cfg.computeprob      = 'yes';
    cfg.numrandomization = 'all';
    cfg.neighbours       = neighbours.neighbours;

    nsubj = size(ind_pre_A.powspctrm, 1);
    design = zeros(2, 2*nsubj);
    design(1,1:nsubj)         = 1;  % 条件1 (A)
    design(1,nsubj+1:2*nsubj) = 2;  % 条件2 (B)
    design(2,1:nsubj)         = 1:nsubj;
    design(2,nsubj+1:2*nsubj) = 1:nsubj;
    cfg.design = design;
    cfg.ivar   = 1;  % 独立変数: 条件
    cfg.uvar   = 2;  % 単位変数: 被験者

    % 統計検定
    if isscalar(foi_contrast)
        cfg.frequency = foi_contrast;
        stat_result = ft_freqstatistics(cfg, ind_pre_A, ind_pre_B);
    else
        stat_result = struct();
        for b = 1:length(foi_contrast)
            cfg.frequency = foi_contrast(b);
            band_name = bands{cfg.frequency};
            stat = ft_freqstatistics(cfg, ind_pre_A, ind_pre_B);
            stat_result.(band_name) = stat;
        end
    end
end