%% Clear and add paths
clearvars; clc; close all;addpath('utils'); addpath('controllers'); addpath(genpath('tbxmanager'))
%% Setup everything

A = [1 1; 0 1];
B = [0.5; 1];
Cc = [1 0];
n = size(A, 1); m = size(B, 2);
Fx = [eye(2); -eye(2)];
gx = [25, 5, 25, 5]';
Fu = [eye(1); -eye(1)]; 
gu = [1; 1]; 

Q = [1 0; 0 0];

plant = Plant(A, B, gx, gu);
%%% Fast LQR controller
R_fast = 1; 
K_fast = -dlqr(A, B, Q, R_fast); 
cont_fast = SingleController(n, m, gu, K_fast);
%%% Slow LQR controller
R_slow = 100; 
K_slow = -dlqr(A, B, Q, R_slow); 
cont_slow = SingleController(n, m, gu, K_slow);
%%% Multicontroller
Rs = [1, 3, 5, 10, 25, 50, 100]; 
cont_mc = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx);
cont_mc.plot('Alpha', 0.3, 'Clear', 1)
%%% MCNN
cont_mcnn = NeuralNetworkMultiController(n, m, gu, cont_mc.K, cont_mc.ConvHulls); 
layers = [32, 16, 8]; epochs = 1000;
cont_mcnn.train_network(layers, epochs)  % <- uncomment if you have Python & Keras
cont_mcnn.load_network();
%%% MPC
R_mpc = 0.1; 
cont_mpc = MPController(n, m, gu, A, B, gx, Q, R_mpc);
%%% Interpolation control
cont_ic = ICController(n, m, gu, A, B, K_fast, Fx, Fu, gx, K_slow);

%% Run system
%%% Stack all of the controllers together
all_controllers = {cont_mc, cont_mcnn, cont_mpc, cont_ic, cont_fast, cont_slow};
labels = {'MC', 'MCNN', 'MPC', 'IC', 'fast', 'slow'};
colors = {'b', 'r-', 'm--', 'k.-', 'g', 'y'};
num_of_controllers = length(all_controllers);

%%% Setup inital conditions, ref, and run-time
x0 = [-23; 2];
sim_time = 30;
% ref = random_step_signal_generator(2, sim_time, sim_time/30, [-12.5 12.5; 0 0]);
ref = [0;0];
%%%% Run all control systems and plot results
result_matrix = zeros(length(all_controllers), 2);
clc;
figure(1);clf; figure(2); clf;
for controller_id = 1:num_of_controllers
    controller = all_controllers{controller_id};
    controller_label = labels{controller_id};
    logger = run_system(plant, controller, x0, sim_time, ref);
    fprintf('%s J=%.2f,  CTPS is %.5f ms\n', controller_label, logger.cost(ref), logger.CTPS);
    result_matrix(controller_id, :) = [logger.cost(ref), logger.CTPS];
    logger.plot(1, [2; 1], colors{controller_id}, 0.2*(num_of_controllers - controller_id)+1)
    logger.plot_u(2, [1; 1], colors{controller_id}, 0.2*(num_of_controllers - controller_id)+1)
end
figure(1);legend(labels); figure(2);legend(labels)
%% Plot results as LaTeX  for publication 
result_matrix(find(strcmp(labels,'MCNN')), 2) = 0.019;  % Override MCNN CTPS cause matlab's importKerasNetwork sucks
show_result_as_latex(result_matrix, labels, 'MPC')