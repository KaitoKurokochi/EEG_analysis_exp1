% main_1: segment-base pre-processing
% -> v1 (pre-processed, saved in result/v1)

%% define path
set_path;
groups = {'nov', 'exp'};

for g = 1:length(groups)
    for i = 1:12
        pname = [groups{g}, num2str(i)];
        data_dir = fullfile(prj_dir, 'rawdata', pname);
        vhdrs = dir(fullfile(data_dir, '*.vhdr'));
        res_dir = fullfile(prj_dir, 'result', 'v1', pname);
        if ~exist(res_dir, 'dir')
            mkdir(res_dir);
        end
        
        for v = 1:length(vhdrs)
            vhdr_path = fullfile(data_dir, vhdrs(v).name);
            sequence_path = fullfile(data_dir, ['sequence_', num2str(v), '.csv']);
            id = [pname, '-', num2str(v)];

            disp(['--- id: ', id, ', start pre-processing ---']);
            
            % pre-processing
            if 1 <= i && i <= 5
                [data0, data1, data1_ica2, ic1, ic1_ica2] = pre_processing(vhdr_path, sequence_path, id, 'mytrialfun_2');
            end
            if 6 <= i && i <= 12
                [data0, data1, data1_ica2, ic1, ic1_ica2] = pre_processing(vhdr_path, sequence_path, id, 'mytrialfun');
            end

            % spectrum 
            spectr0 = my_calc_spectr(data0);
            spectr1 = my_calc_spectr(data1);
            spectr1_ica2 = my_calc_spectr(data1_ica2);

            % save 
            save(fullfile(res_dir, ['v0_', num2str(v), '.mlat']), 'data0', '-v7.3');
            save(fullfile(res_dir, ['v1_', num2str(v), '.mat']), 'data1', '-v7.3');
            save(fullfile(res_dir, ['v1_', num2str(v), '_ica2.mat']), 'data1_ica2', '-v7.3');
            save(fullfile(res_dir, ['v0_', num2str(v), '_spectrum.mat']), 'spectr0', '-v7.3');
            save(fullfile(res_dir, ['v1_', num2str(v), '_spectrum.mat']), 'spectr1', '-v7.3');
            save(fullfile(res_dir, ['v1_', num2str(v), '_spectrum_ica2.mat']), 'spectr1_ica2', '-v7.3');
        end
    end
end
