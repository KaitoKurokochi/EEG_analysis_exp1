% input: need to set participant's name, vhdrfile name, sequencefile name, savefile name
% - rawdata/{participant}/*.eeg, *.vhdr, *.vmrk
% - rawdata/{participant}/sequence_x.csv

define_path;

%% check the dataset
cfg = [];
cfg.dataset             = vhdr_path;
cfg.trialdef.eventtype = '?';
cfg                   = ft_definetrial(cfg);

% correct s1 idx
event_data = cfg.event;
values = {event_data.value};
max_id = length(values);
is_s1 = strcmp(values, 's1');
s1_ids = find(is_s1);

for i = 1:length(s1_ids)
    st_id = s1_ids(i);

    if st_id+3 <= max_id
        if strcmp(values(st_id+1), 's2') && strcmp(values(st_id+2), 's4') && strcmp(values(st_id+3), 's32')
            continue;
        end
    end

    if st_id+2 <= max_id
        if strcmp(values(st_id+1), 's2') && strcmp(values(st_id+2), 's32')
            continue;
        end
    end

    disp(['trial id: ' num2str(i) ', st_id(all evnet): ' num2str(st_id)]);
end