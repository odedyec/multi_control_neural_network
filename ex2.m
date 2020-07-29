%% Clear and add paths
clearvars; clc; close all;addpath('utils'); addpath('controllers'); addpath(genpath('tbxmanager'))
%% Setup everything

A = [0.7627 0.4596 0.1149 0.0198 0.0025 0.0003
-0.8994 0.7627 0.4202 0.1149 0.0193 0.0025
0.1149 0.0198 0.7652 0.4599 0.1149 0.0198
0.4202 0.1149 -0.8801 0.7652 0.4202 0.1149
0.0025 0.0003 0.1149 0.0198 0.7627 0.4596
0.0193 0.0025 0.4202 0.1149 -0.8994 0.7627];

B = [0.1199 0.4596 0.0025 0.0198 0.0000 0.0003
0.0025 0.0198 0.1199 0.4599 0.0025 0.0198]';
n = size(A, 1); m = size(B, 2);
Fx = [eye(6); -eye(6)];
gx = 1000 * ones(12, 1);%[4 1000 4 1000 4 1000 4 1000 4 1000 4 1000]';
Fu = [eye(2); -eye(2)]; 
gu = [1; 1; 1; 1] * 0.5; 

plant = Plant(A, B, gx, gu);
Q = diag([1 0 1 0 1 0]);
%%% Fast LQR controller
R_fast = .1 * diag([1, 1]);
K_fast = -dlqr(A, B, Q, R_fast);
cont_fast = SingleController(n, m, gu, K_fast);
%%% Slow LQR controller
R_slow = 10 * diag([1, 1]);
K_slow = -dlqr(A, B, Q, R_slow); 
cont_slow = SingleController(n, m, gu, K_slow);
%%% Multicontroller
Rs = [1;1] * [0.1, 1, 3, 5, 10]; 
cont_mc = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx);
%%% MCNN
cont_mcnn = NeuralNetworkMultiController(n, m, gu, cont_mc.K, cont_mc.ConvHulls); 
layers = [160, 80]; epochs = 3;
% cont_mcnn.train_network(layers, epochs)  % <- uncomment if you have Python & Keras
cont_mcnn.load_network();
%%% MPC
R_mpc = .1 * eye(2); 
cont_mpc = MPController(n, m, gu, A, B, gx, Q, R_mpc);
%%% Interpolation control
cont_ic = ICController(n, m, gu, A, B, K_fast, Fx, Fu, gx, K_slow);

%% Run system
%%% Stack all of the controllers together
all_controllers = {cont_mc, cont_mcnn, cont_mpc, cont_ic, cont_fast, cont_slow};
labels = {'MC', 'MCNN', 'MPC', 'IC', 'fast', 'slow'};
colors = {'b', 'r-', 'k', 'g.-', 'm', 'c'};
num_of_controllers = length(all_controllers);

%%% Setup inital conditions, ref, and run-time
x0 = [3.0136, 2.7106, 4.0000, 0.3585, 3.8636, -3.1652]'/1.8;
sim_time = 70;
ref = zeros(6, 1);
% ref = random_step_signal_generator(2, sim_time, sim_time/30, [-12.5 12.5; 0 0]);
%%%% Run all control systems and plot results
result_matrix = zeros(length(all_controllers), 2);
clc;
figure(1);clf; %figure(2); clf;
for controller_id = 1:num_of_controllers
    controller = all_controllers{controller_id};
    controller_label = labels{controller_id};
    logger = run_system(plant, controller, x0, sim_time, ref);
    fprintf('%s J=%.2f,  CTPS is %.5f ms\n', controller_label, logger.cost(ref), logger.CTPS);
    result_matrix(controller_id, :) = [logger.cost(ref), logger.CTPS];
    if ~strcmp(labels{controller_id}, 'fast') && ~strcmp(labels{controller_id}, 'slow')    
        logger.plot(1, [2; 3], colors{controller_id}, 0.3*(num_of_controllers - controller_id)+1)
    end
end
figure(1);legend(labels{1:4}); for i=1:3; for j=1:2; subplot(2, 3, i + (j-1)*3); grid on; xlabel('k[sec]'); ylabel(sprintf('x_%d', i+(j-1)*3));end;end
% xlabel('Time[sec]')
% subplot(2, 1, 1); ylabel('x_1'); grid on;xlim([0, 20])
% subplot(2, 1, 2); ylabel('u');grid on; xlim([0, 20])
%% Plot results as LaTeX  for publication 
result_matrix(find(strcmp(labels,'MCNN')), 2) = 0.0003 + length(cont_mcnn.K) * result_matrix(end, 2);  % Override MCNN CTPS cause matlab's importKerasNetwork sucks
show_result_as_latex(result_matrix, labels, 'MPC')