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
%%% Multicontroller
Rs = [1, 2, 5, 10, 20, 40, 70, 100]; 
cont_mc1 = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx);
Rs = [1, 100]; 
cont_mc2 = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx);
Rs = [1, 5, 10, 100]; 
cont_mc3 = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx);
Rs = [1:0.5:100]; 
cont_mc4 = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx);
%% Run system
%%% Stack all of the controllers together
all_controllers = {cont_mc1, cont_mc2, cont_mc3, cont_mc4};
labels = {'MC8', 'MC2', 'MC4', 'MC200'};
colors = {'b', 'r-', 'm--', 'k.-', 'g', 'y'};
num_of_controllers = length(all_controllers);

%%% Setup inital conditions, ref, and run-time
x0 = [23; -2];
sim_time = 30;
% ref = random_step_signal_generator(2, sim_time, 20, [-12.5 12.5; 0 0]);
ref = [0;0];
%%%% Run all control systems and plot results
clc;
result_matrix = zeros(length(all_controllers), 2);
%figure(1);clf; figure(2); clf;
for controller_id = 1:num_of_controllers
    controller = all_controllers{controller_id};
    controller_label = labels{controller_id};
    logger = run_system(plant, controller, x0, sim_time, ref);
    fprintf('%s J=%.2f,  CTPS is %.5f ms\n', controller_label, logger.cost(ref), logger.CTPS);
    result_matrix(controller_id, :) = [logger.cost(ref), logger.CTPS];
end
% figure(1);legend(labels); figure(2);legend(labels)
show_result_as_latex(result_matrix, labels, 'MC200')