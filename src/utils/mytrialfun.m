function [trl, event] = mytrialfun(cfg)
%%
hdr        = ft_read_header(cfg.headerfile);
event      = ft_read_event(cfg.headerfile);
T_sequence = readtable(cfg.sequencefile);

%% 
EVsample   = [event.sample]';
EVvalue    = {event.value}';
keys = T_sequence{:, 'Key'};

% select the target stimuli (check in dummy)
s2_ids = find(strcmp('s2', EVvalue)==1);
num_trials = length(s2_ids);

% Define the time window for clipping (0.2s pre-trigger to 1.0s post-trigger)
% Note: Using the original values for consistency. If you want different times, change the multipliers (0.2 and 1).
PreTrig   = round(0.5 * hdr.Fs);
PostTrig  = round(1.0 * hdr.Fs);
begsample = EVsample(s2_ids) - PreTrig;
endsample = EVsample(s2_ids) + PostTrig;
offset = -PreTrig*ones(size(endsample));

% devide task
if num_trials < height(T_sequence)
    error('the num of s2 and sequence is not equal');
end 

% task: at the moment, pressed -> 1, not pressed -> 0, without signal -> -1
task = zeros(num_trials, 1);
for i = 1:num_trials
    is_in_trial = EVsample >= begsample(i) & EVsample <= endsample(i);
    event_ids = find(is_in_trial);
    
    s2_id = -1;
    s4_id = -1; 
    s32_id = -1;
    for j = 1:length(event_ids)
        if strcmp(EVvalue(event_ids(j)), 's2')==1
            s2_id = event_ids(j);
        elseif strcmp(EVvalue(event_ids(j)), 's4')==1
            s4_id = event_ids(j);
        elseif strcmp(EVvalue(event_ids(j)), 's32')==1
            s32_id = event_ids(j);
        end 
    end

    if s32_id == -1
        disp(['trial ' num2str(i) ': without s32']);
        task(i) = -1;
        continue;
    end

    if s4_id ~= -1
        s2_ev = EVsample(s2_id);
        s4_ev = EVsample(s4_id);
        s32_ev = EVsample(s32_id);

        if s2_ev <= s4_ev && s4_ev <= s32_ev
            task(i) = 1;
        end
    end
end

% check if the task correct/incorrect 
for i = 1:num_trials
    if task(i) == -1
        continue;
    end

    key = keys{i, 1};
    if strcmp(key, 'ff')
        if task(i) == 1
            task(i) = 1; % ff correct 
        else 
            task(i) = 0; % incorrect
        end
    elseif strcmp(key, 'fc')
        if task(i) == 1
            task(i) = 0; % incorrect
        else 
            task(i) = 2; % fc correct 
        end
    elseif strcmp(key, 'cf')
        if task(i) == 1
            task(i) = 0; % incorrect
        else 
            task(i) = 3; % cf correct
        end
    elseif strcmp(key, 'cc')
        if task(i) == 1
            task(i) = 4; % cc correct
        else 
            task(i) = 0; % incorrect
        end
    else 
        task(i) = -1;
    end
end

% concatenate the columns into the trl matrix
trl = [begsample endsample offset task];

