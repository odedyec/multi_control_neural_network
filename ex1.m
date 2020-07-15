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
%% Run system
x0 = [-23;2];
sim_time = 30;
logger_fast = run_system(plant, cont_fast, x0, sim_time);
logger_slow = run_system(plant, cont_slow, x0, sim_time);
logger_mc = run_system(plant, cont_mc, x0, sim_time);
logger_mpc = run_system(plant, cont_mpc, x0, sim_time);
fprintf('Fast CTPS is %.5f ms\n', logger_fast.CTPS * 1000);
fprintf('Slow CTPS is %.5f ms\n', logger_slow.CTPS * 1000);
fprintf('MC CTPS is %.5f ms\n', logger_mc.CTPS * 1000);
fprintf('MPC CTPS is %.5f ms\n', logger_mpc.CTPS * 1000);
figure(1);clf;
logger_fast.plot(1, [2;1], 'r-', 1)
logger_slow.plot(1, [2;1], 'b', 1)
logger_mc.plot(1, [2;1], 'm--', 1)
logger_mpc.plot(1, [2;1], 'k.-', 1)
figure(2);clf;
logger_fast.plot_u(2, [1, 1], 'r-', 1)
logger_slow.plot_u(2, [1, 1], 'b', 1)