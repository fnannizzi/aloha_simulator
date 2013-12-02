% This function simulates the slotted ALOHA protocol for N nodes, each with
% probability p of transmitting during a given time slot. The simulation
% runs for n time slots.
function [efficiency, mean_wait_time, std_dev_wait_time] = pureALOHA(p, num_nodes, num_time_slots, num_calculations)
% Declare output arguments
    efficiency = zeros(1, num_calculations);
    mean_wait_time = zeros(1, num_calculations);
    std_dev_wait_time = zeros(1, num_calculations);
    
    
    % Initialize random begin times for nodes
    time_interval = rand(1,num_nodes);
    %for node = 1:num_nodes
        %fprintf('Node %d begins at %d.\n', node, time_interval(node));
    %end
    
    % When to stop to calculate statistics (every 10 slots, 20, etc.).
    calculation_break = num_time_slots/num_calculations;

    % Array that records current transmitting status of nodes. Initialized
    % to all ones since the nodes will all transmit on time slot one,
    % causing the initial collision.
    is_transmitting = ones(1,num_nodes);
    was_transmitting = zeros(1,num_nodes);
    
    % Array that records the total wait time for each transmitted packet.
    wait_time = zeros(num_time_slots,num_nodes);
    
    % Total number of frames transmitted by each node over the course of
    % the simulation. Incremented when transmission_success(node) is 1.
    total_frames_transmitted = zeros(1,num_nodes);
    
    
    % Simulate for a certain number of time slots
    for time_slot = 1:num_time_slots
        
        % Check for a collision
        collision = false;
        for node = 1:num_nodes
            for compare_node = 1:num_nodes
                if(node == compare_node) 
                    break;
                elseif(is_transmitting(node) && is_transmitting(compare_node))
                    if(abs(time_interval(node) - time_interval(compare_node)) < 1)
                        %fprintf('Nodes %d and %d have collided.\n', node, compare_node);
                        collision = true;
                        break;
                    end
                elseif(is_transmitting(node) && was_transmitting(compare_node))
                    if(abs(time_interval(node) - time_interval(compare_node)) < 1)
                        %fprintf('Nodes %d and %d have collided.\n', node, compare_node);
                        collision = true;
                        break;
                    end
                end
            end
            if(collision)
                break;
            end
        end
        
        % For all nodes, must decide whether to transmit or not
        for node = 1:num_nodes
            
            % Initialize our decision variable.
            do_transmit = 1;
            
            if(is_transmitting(node) && not(collision))
                total_frames_transmitted(node) = total_frames_transmitted(node) + 1;
                was_transmitting(node) = 1;
                %fprintf('SUCCESS: Node %d do_transmit: %d.\n', node, do_transmit);
            else
                if(is_transmitting(node))
                    was_transmitting(node) = 1;
                else
                    was_transmitting(node) = 0;
                end
                
                % For this node, use a binomial random variable to simulate a
                % coin flip with probability p. If the coin flip is 1, transmit
                % data.
                do_transmit = binornd(1, p);
                %fprintf('NO SUCCESS: Node %d do_transmit: %d.\n', node, do_transmit);
                wait_time((total_frames_transmitted(node) + 1), node) = wait_time((total_frames_transmitted(node) + 1), node) + 1;
            end
            
            % Update the transmitting status array
            if(do_transmit)
                is_transmitting(node) = 1;
            else
                is_transmitting(node) = 0;
            end
        end
        
        % Every 10 time slots, compute some statistics.
        if(mod(time_slot, calculation_break) == 0)
             %fprintf('Frames transmitted:\n');
             %disp(total_frames_transmitted);
            
            calculation_iterator = time_slot/calculation_break;
            
            % Compute the average wait time. Divide the total wait times by
            % the total frames transmitted. sum_frames_transmitted may be
            % 0, which makes the mean_wait_time infinite, but if no frames
            % have been transmitted that is an acceptable answer.
            mean_wait_time(calculation_iterator) = sum(sum(wait_time))/sum(total_frames_transmitted);
            %fprintf('Mean wait time at time %d: %d.\n', time_slot, mean_wait_time(calculation_iterator));

            % Compute the std dev wait time
            std_dev_container = zeros(1, sum(total_frames_transmitted));
            std_dev_container_iterator = 1;
            for node = 1:num_nodes
                for frame = 1:total_frames_transmitted(node)
                    std_dev_container(std_dev_container_iterator) = wait_time(frame, node);
                    std_dev_container_iterator = std_dev_container_iterator + 1;
                end
            end
            std_dev_wait_time(calculation_iterator) = std2(std_dev_container);
            %fprintf('Std dev wait time at time %d: %d.\n', time_slot, std_dev_wait_time(calculation_iterator));

            % Compute the efficiency
            efficiency(calculation_iterator) = (sum(total_frames_transmitted)/time_slot)/2;
            %fprintf('Efficiency at time %d: %d.\n', time_slot, efficiency(calculation_iterator));
        end
    end 
end