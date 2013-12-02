% Number of nodes
num_nodes = 10;
% Number of time slots to run for
num_time_slots = 500;
num_calculations = 50;

% Probability of transmitting p
p = 0.025;

% Number of times to run simulation
num_intervals = 28;

efficiency = zeros(num_calculations, (num_intervals - 1));
mean_wait_time = zeros(num_calculations, (num_intervals - 1)); 
std_dev_wait_time = zeros(num_calculations, (num_intervals - 1));

for i = 1:num_intervals
    fprintf('Running simulation for p = %f.\n', p);
    [efficiency(1:num_calculations,i), mean_wait_time(1:num_calculations,i), std_dev_wait_time(1:num_calculations,i)] = slottedALOHA(p, num_nodes, num_time_slots, num_calculations);
    p = p + 0.025;
end