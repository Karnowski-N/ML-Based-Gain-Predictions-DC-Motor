% make_training_dataset.m
% Runs make_training_case several times because I don't want to press run a
% million times

clear;
clc;

num_cases = 2;

for case_num = 1:num_cases
    fprintf('\n--- Training case %d of %d ---\n', case_num, num_cases);
    make_training_case;
end

fprintf('\nDone. Dataset saved to pid_training_data.csv\n');