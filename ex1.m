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
R_fast = 1; K_fast = -dlqr(A, B, Q, R_fast); cont_fast = SingleController(n, m, gu, K_fast);
R_slow = 100; K_slow = -dlqr(A, B, Q, R_slow); cont_slow = SingleController(n, m, gu, K_slow);
Rs = [0.01, 1, 5, 10, 40, 100]; cont_mc = MultiController(A, B, Rs, Q, Fx, Fu, gx, n, m, gu);
R_mpc = 0.1; cont_mpc = MPController(n, m, gu, A, B, gx, Q, R_mpc);
cont_ic = ICController(n, m, gu, A, B, K_fast, Fx, Fu, gx, K_slow);
all_controllers = {cont_mc, cont_mpc, cont_ic, cont_fast, cont_slow};
labels = {'MC', 'MPC', 'IC', 'fast', 'slow'};
%% Run system
x0 = [-23;2];
sim_time = 20;
colors = {'b', 'r-', 'm--', 'k.-', 'g'};
num_of_controllers = length(all_controllers);
figure(1);clf; figure(2); clf;
for controller_id = 1:num_of_controllers
    controller = all_controllers{controller_id};
    controller_label = labels{controller_id};
    logger = run_system(plant, controller, x0, sim_time);
    fprintf('%s J=%.2f,  CTPS is %.5f ms\n', controller_label, logger.cost, logger.CTPS * 1000);
    logger.plot(1, [2; 1], colors{controller_id}, num_of_controllers - controller_id+1)
    logger.plot_u(2, [1; 1], colors{controller_id}, num_of_controllers - controller_id+1)
end
figure(1);legend(labels); figure(2);legend(labels)