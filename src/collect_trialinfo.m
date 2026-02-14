% collect trialinfo
% collect trialinfo (task condition and RT) for each participants

config;

data_dir = fullfile(prj_dir, 'result', 'prepro1'); % set data dir
res_dir = fullfile(prj_dir, 'result', 'trialinfo'); % set res dir
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

%% exp
disp('--- start exp ---');
% count trls
exp = [];
exp.trialinfo = cell(1, 12);
for pi = 1:12
    for si = 1:5
        seg_id = ['exp', num2str(pi), '-', num2str(si)];
        fname = fullfile(data_dir, [seg_id, '.mat']);
        if ~exist(fname, 'file')
            continue;
        end

        disp('loading...');
        load(fname); % include data

        disp(['--- id: ', seg_id, ', start processing ---']);

        if isempty(exp.trialinfo{pi})
            exp.trialinfo{pi} = data.trialinfo;
        else
            exp.trialinfo{pi} = [exp.trialinfo{pi}; data.trialinfo];
        end
    end
end

save(fullfile(res_dir, 'exp.mat'), 'exp', '-v7.3');

%% nov
disp('--- start nov ---');
% count trls
nov = [];
nov.trialinfo = cell(1, 12);
for pi = 1:12
    for si = 1:5
        seg_id = ['nov', num2str(pi), '-', num2str(si)];
        fname = fullfile(data_dir, [seg_id, '.mat']);
        if ~exist(fname, 'file')
            continue;
        end

        disp('loading...');
        load(fname); % include data

        disp(['--- id: ', seg_id, ', start processing ---']);

        if isempty(nov.trialinfo{pi})
            nov.trialinfo{pi} = data.trialinfo;
        else
            nov.trialinfo{pi} = [nov.trialinfo{pi}; data.trialinfo];
        end
    end
end

% save data
save(fullfile(res_dir, 'nov.mat'), 'nov', '-v7.3');