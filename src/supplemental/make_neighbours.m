% Generate neighbours structure using distance method (neighbourdist = 0.4)
% based on easycapM11 electrode layout.
% Output: src/neighbours.mat
clear;
config;

% Load layout to get electrode positions
cfg_layout = [];
cfg_layout.layout = 'easycapM11.mat';
layout = ft_prepare_layout(cfg_layout);

% Build a minimal elec structure from the layout
% (exclude COMNT and SCALE pseudo-channels)
valid = ~ismember(layout.label, {'COMNT', 'SCALE'});
elec = [];
elec.label  = layout.label(valid);
elec.elecpos = [layout.pos(valid, :), zeros(sum(valid), 1)];
elec.chanpos = elec.elecpos;
elec.unit    = 'cm';

% Compute neighbours
cfg_neighb = [];
cfg_neighb.method        = 'distance';
cfg_neighb.neighbourdist = 0.15;
neighbours = ft_prepare_neighbours(cfg_neighb, elec);

% Print neighbour counts per channel
for i = 1:length(neighbours)
    fprintf('  %-8s: %d neighbours\n', neighbours(i).label, ...
            length(neighbours(i).neighblabel));
end

% Plot neighbours
cfg_plot = [];
cfg_plot.neighbours = neighbours;
cfg_plot.layout     = 'easycapM11.mat';
ft_neighbourplot(cfg_plot, elec);

% Save
save_path = fullfile(prj_dir, 'src', 'supplemental', 'try_neighbours.mat');
save(save_path, 'neighbours');
fprintf('\nSaved to: %s\n', save_path);
