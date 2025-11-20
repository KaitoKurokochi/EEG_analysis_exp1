function [trl, event] = mytrialfun(cfg)
%%

%%
hdr        = ft_read_header(cfg.headerfile);
event      = ft_read_event(cfg.headerfile);

%% 
EVsample   = [event.sample]';
EVvalue    = {event.value}';

% select the target stimuli (check in dummy)
Word = find(strcmp('s2', EVvalue)==1);

% divide trials based on the conditions and task results

% Define the time window for clipping (0.2s pre-trigger to 1.0s post-trigger)
% Note: Using the original values for consistency. If you want different times, change the multipliers (0.2 and 1).
PreTrig   = round(1.5 * hdr.Fs);
PostTrig  = round(2.0 * hdr.Fs);

begsample = EVsample(Word) - PreTrig;
endsample = EVsample(Word) + PostTrig;

offset = -PreTrig*ones(size(endsample));
task = ones(size(endsample));

% concatenate the columns into the trl matrix
trl = [begsample endsample offset task];

