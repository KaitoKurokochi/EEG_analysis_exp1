% sub 4: running PhaseOppotiosion
%
% input: 
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})

set_path;

data_dir = fullfile(prj_dir, 'result', 'v4');
res_dir = fullfile(prj_dir, 'result', 'sub4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

main_channels = {'Pz', 'Cz', 'Fz'};
num_type = 4;
conditions = {'ff', 'fs', 'sf', 'ss'};

% read data