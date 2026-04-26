%AI assistance is utilitized
% In order to train a model, we need to obtain data from many different
%kinds of motor models, not just the basic one. I will change the step
%block and the state-space. 
% This script creates one randomized DC motor case, searches for good PID gains, then
% puts it into a csv so we can collect data!

%THIS GOT ANNOYING TO RUN OVER AND OVER AGAIN SO NEW SCRIPT IS MADE TO DO
%MANY RUNS AND MAKE A NEW CSV

clc;

model_name = 'DCmotorAItuning';
dataset_file = 'pid_training_data.csv';

open_system(model_name);
%Original numbers used:
base_A11 = -4;
base_A12 = -0.2;
base_A21 = 5;
base_A22 = -10;
base_B1  = 2;

plant_variation_percent = 0.10;   % +/- 10 percent variation
min_step_amp = 0.75;
max_step_amp = 1.50;

% Make random motor values

A11 = base_A11 * (1 + plant_variation_percent * (2*rand - 1));
A12 = base_A12 * (1 + plant_variation_percent * (2*rand - 1));
A21 = base_A21 * (1 + plant_variation_percent * (2*rand - 1));
A22 = base_A22 * (1 + plant_variation_percent * (2*rand - 1));
B1  = base_B1  * (1 + plant_variation_percent * (2*rand - 1));

step_amp = min_step_amp + (max_step_amp - min_step_amp) * rand;

%original PID values...the baseline
Kp = 15.0380;
Ki = 57.4007;
Kd = 0.8951;
Nf = 1159.8;

%function from before that finds best values from trials and scores them
run_pid_search;


training_row = table( ...
    A11, A12, A21, A22, B1, step_amp, ...
    best_Kp, best_Ki, best_Kd, best_Score);

if isfile(dataset_file)
    existing_data = readtable(dataset_file);
    training_data = [existing_data; training_row];
else
    training_data = training_row;
end

writetable(training_data, dataset_file);

disp(training_row);
fprintf('Saved new training row to %s\n', dataset_file);