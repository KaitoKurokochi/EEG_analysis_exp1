% main_1: segment-base processing 
% -> v1 (pre-processed)

%% define path
set_path;
groups = {'nov', 'exp'};

for g = 1:length(groups)
    for i = 1:5
        pname = [groups{g}, num2str(i)];
        data_dir = fullfile(prj_dir, 'rawdata', pname);
        res_dir = fullfile(prj_dir, 'result', pname);
        vhdrs = dir(fullfile(data_dir, '*.vhdr'));
        
        for v = 1:length(vhdrs)
            vhdr_path = fullfile(data_dir, vhdrs(v).name);
            sequence_path = fullfile(data_dir, ['sequence_', num2str(v), '.csv']);
            id = [pname, '-', num2str(v)];

            disp(['--- id: ', id, ', start pre-processing ---']);
            
            % ica 
            [data, cleaned_data, ica_result] = pre_processing(vhdr_path, sequence_path, id);

            % spectrum 
            spectr1 = my_calc_spectr(data);
            spectr2 = my_calc_spectr(cleaned_data);

            % save 
            save(fullfile(res_dir, ['v0_', num2str(v), '_ica2.mat']), 'data', '-v7.3');
            save(fullfile(res_dir, ['v1_', num2str(v), '_ica2.mat']), 'cleaned_data', '-v7.3');
            save(fullfile(res_dir, ['v0_', num2str(v), '_spectrum_ica2.mat']), 'spectr1', '-v7.3');
            save(fullfile(res_dir, ['v1_', num2str(v), '_spectrum_ica2.mat']), 'spectr2', '-v7.3');           
        end
    end
end
