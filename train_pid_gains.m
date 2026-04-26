% train_pid_gain_model.m
% Trains a simple regression model to predict PID gains from motor
% parameters (the stead state equation is the parameters)

clc;

data = readtable('pid_training_data.csv');

% Remove bad rows based on their "score"
data = data(data.best_Score < 1e6, :);

fprintf('Training with %d usable rows.\n', height(data));

X = data{:, {'A11','A12','A21','A22','B1','step_amp'}};

Y_Kp = data.best_Kp;
Y_Ki = data.best_Ki;
Y_Kd = data.best_Kd;

% Train individual models for proportional, integral, and derivative
Kp_model = fitrensemble(X, Y_Kp);
Ki_model = fitrensemble(X, Y_Ki);
Kd_model = fitrensemble(X, Y_Kd);

save('pid_gain_models.mat', ...
    'Kp_model', 'Ki_model', 'Kd_model');

fprintf('Saved trained PID gain models to pid_gain_models.mat\n');