% sub 4: running PhaseOppotiosion
%
% input: 
% - result/v4/{group}.mat: v4 of {pname} (include spectr_{group})

config;

data_dir = fullfile(prj_dir, 'result', 'v4');
res_dir = fullfile(prj_dir, 'result', 'sub4');
if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

% read data_v4
disp('--- loading v4 data ---');
load(fullfile(data_dir, 'spectr_nov.mat')); % include spectr_nov
load(fullfile(data_dir, 'spectr_exp.mat')); % include spectr_exp

%% run phase-opposition 
for i = 1:num_type
    for j = 1:length(main_channels)
        disp(['--- start imaging: ', conditions{i}, ', ', main_channels{j}, '---']);
        hfig = my_fig_statistics(spectr_nov{i, j}, spectr_exp{i, j});
        sgtitle(['Condition: ', conditions{i}, ' Channel: ', main_channels{j}]);
        saveas(hfig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '.jpg']));
        close(hfig);
    end
end
        
