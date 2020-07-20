function [ref] = random_step_signal_generator(state_size, n, samples_per_step, bounds)
%RANDOM_STEP_SIGNAL_GENERATOR Summary of this function goes here
%   Detailed explanation goes here
ref = zeros(state_size, n);
% % JUMPS = 1;
jumps = ceil(n / samples_per_step);
for i = 1:jumps
    step_val = rand(state_size, 1) .* (bounds(:, 2) - bounds(:, 1)) + bounds(:, 1);
    init_index = 1+(i-1)*samples_per_step;
    end_index = min(i*samples_per_step, n);
    ref(:, init_index:end_index) = ones(state_size, end_index - init_index + 1) .* step_val;
%     Ref(1, 1+(i-1)*SAMPLES_IN_JUMP:i*SAMPLES_IN_JUMP) = ones(1, SAMPLES_IN_JUMP) * (rand - 0.5) * 2 * 20;
end
end

