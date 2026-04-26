% testing_pid_gain_ML_in_Simulink.m
% Tests ML-predicted PID gains against the classical PID gains
% for one DC motor case.

clc;

model_name = 'DCmotorAItuning';
load('pid_gain_models.mat');

% Pick one motor case to test
A11 = -4;
A12 = -0.2;
A21 = 5;
A22 = -10;
B1  = 2;

step_amp = 1;

Nf = 1159.8;

% Predict PID gains for this motor case
X_test = [A11, A12, A21, A22, B1, step_amp];

Kp_ml = predict(Kp_model, X_test);
Ki_ml = predict(Ki_model, X_test);
Kd_ml = predict(Kd_model, X_test);

fprintf('\nML predicted gains:\n');
fprintf('Kp = %.6f\n', Kp_ml);
fprintf('Ki = %.6f\n', Ki_ml);
fprintf('Kd = %.6f\n', Kd_ml);
fprintf('Nf = %.6f\n', Nf);

% Test the ML gains
Kp = Kp_ml;
Ki = Ki_ml;
Kd = Kd_ml;

ml_score = pid_cost(Kp, Ki, Kd, Nf);

fprintf('\nML PID Score = %.6f\n', ml_score);

% Test the classical PID gains
Kp = 15.0380;
Ki = 57.4007;
Kd = 0.8951;

baseline_score = pid_cost(Kp, Ki, Kd, Nf);

fprintf('\nClassical PID Score = %.6f\n', baseline_score);

% Compare results
fprintf('\nComparison:\n');
fprintf('Classical PID Score: %.6f\n', baseline_score);
fprintf('ML PID Score:        %.6f\n', ml_score);

if ml_score < baseline_score
    fprintf('ML-predicted PID performed better for this test case.\n');
else
    fprintf('Classical PID performed better for this test case.\n');
end