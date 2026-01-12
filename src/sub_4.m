% sub_4: TFR graph
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

% TFR graph - nov
for i = 1:num_type
    for j = 1:length(main_channels)
        fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j});

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['nov_', conditions{i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

% TFR graph - exp
for i = 1:num_type
    for j = 1:length(main_channels)
        fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j});

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['exp_', conditions{i}, '_', main_channels{j},'.jpg']));
        close(fig);
    end
end

%%
% TFR graph - nov, xlim
for i = 1:num_type
    for j = 1:length(main_channels)
        % if strcmp(conditions{j}, 'ff') || strcmp(conditions{j}, 'sf')
        %     fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j}, [0.0 0.5]);
        % elseif strcmp(conditions{j}, 'fs') || strcmp(conditions{j}, 'ss')
        %     fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j}, [0.0 0.57]);
        % end
        fig = my_singleplot_TFR(spectr_nov{i, j}, main_channels{j}, [0.0 0.3]);

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['nov_', conditions{i}, '_', main_channels{j},'_time_lim.jpg']));
        close(fig);
    end
end

% TFR graph - exp, xlim
for i = 1:num_type
    for j = 1:length(main_channels)
        % if strcmp(conditions{j}, 'ff') || strcmp(conditions{j}, 'sf')
        %     fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j}, [0.0 0.5]);
        % elseif strcmp(conditions{j}, 'fs') || strcmp(conditions{j}, 'ss')
        %     fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j}, [0.0 0.57]);
        % end
        fig = my_singleplot_TFR(spectr_exp{i, j}, main_channels{j}, [0.0 0.3]);

        hold on;
        xlabel('Time (s)');
        ylabel('Freqency (Hz)');
        title(['TFR at channel: (', conditions{i}, ', ', main_channels{j}, ')']);
        hold off;
    
        saveas(fig, fullfile(res_dir, ['exp_', conditions{i}, '_', main_channels{j},'_time_lim.jpg']));
        close(fig);
    end
end

%% run statistics
for i = 1:num_type
    for j = 1:length(main_channels)
        disp(['--- start imaging: ', conditions{i}, ', ', main_channels{j}, '---']);
        hfig = my_fig_statistics(spectr_nov{i, j}, spectr_exp{i, j});
        sgtitle(['Condition: ', conditions{i}, ' Channel: ', main_channels{j}]);
        saveas(hfig, fullfile(res_dir, [conditions{i}, '_', main_channels{j}, '.jpg']));
        close(hfig);
    end
end
        
