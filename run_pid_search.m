% Some parts of this code were written and refined with AI assistance
% This tries to find a better PID tuning automatically by testing random candidates around the current best point.

MODEL = 'DCmotorAItuning';
open_system(MODEL);

% Best classical tuning values
Kp = 15.0380;
Ki = 57.4007;
Kd = 0.8951;
Nf = 1159.8;

assignin('base', 'Kp', Kp);
assignin('base', 'Ki', Ki);
assignin('base', 'Kd', Kd);
assignin('base', 'Nf', Nf);

baseline_Score = pid_cost(Kp, Ki, Kd, Nf);

fprintf('Baseline values:\n');
fprintf('Kp = %.6f\n', Kp);
fprintf('Ki = %.6f\n', Ki);
fprintf('Kd = %.6f\n', Kd);
fprintf('Nf = %.6f\n', Nf);
fprintf('Baseline Score = %.6f\n\n', baseline_Score);

best_Kp = Kp;
best_Ki = Ki;
best_Kd = Kd;
best_Score = baseline_Score;

Kp_range = 0.50 * Kp;
Ki_range = 0.50 * Ki;
Kd_range = max(0.50 * Kd, 0.1);

num_rounds = 5;
num_trials = 25;

results_matrix = zeros(num_rounds * num_trials, 6);
result_row = 1;

rng('shuffle');

for round_index = 1:num_rounds

    fprintf('------------------------------\n');
    fprintf('Round %d\n', round_index);
    fprintf('Center point: Kp=%.6f  Ki=%.6f  Kd=%.6f\n', best_Kp, best_Ki, best_Kd);
    fprintf('Ranges: Kp_range=%.6f  Ki_range=%.6f  Kd_range=%.6f\n', Kp_range, Ki_range, Kd_range);

    candidate_matrix = zeros(num_trials, 3);

    % Always keep the current best point as one candidate
    candidate_matrix(1, :) = [best_Kp, best_Ki, best_Kd];

    for trial_index = 2:num_trials
        candidate_matrix(trial_index, 1) = max(0, best_Kp - Kp_range + 2*Kp_range*rand());
        candidate_matrix(trial_index, 2) = max(0, best_Ki - Ki_range + 2*Ki_range*rand());
        candidate_matrix(trial_index, 3) = max(0, best_Kd - Kd_range + 2*Kd_range*rand());
    end

    round_best_Kp = best_Kp;
    round_best_Ki = best_Ki;
    round_best_Kd = best_Kd;
    round_best_Score = inf;

    for trial_index = 1:num_trials

        test_Kp = candidate_matrix(trial_index, 1);
        test_Ki = candidate_matrix(trial_index, 2);
        test_Kd = candidate_matrix(trial_index, 3);

        test_Score = pid_cost(test_Kp, test_Ki, test_Kd, Nf);

        results_matrix(result_row, :) = [round_index, trial_index, test_Kp, test_Ki, test_Kd, test_Score];
        result_row = result_row + 1;

        fprintf('Trial %d | Kp=%.6f  Ki=%.6f  Kd=%.6f  Score=%.6f\n', ...
            trial_index, test_Kp, test_Ki, test_Kd, test_Score);

        if test_Score < round_best_Score
            round_best_Score = test_Score;
            round_best_Kp = test_Kp;
            round_best_Ki = test_Ki;
            round_best_Kd = test_Kd;
        end
    end

    fprintf('Best in round %d:\n', round_index);
    fprintf('Kp = %.6f\n', round_best_Kp);
    fprintf('Ki = %.6f\n', round_best_Ki);
    fprintf('Kd = %.6f\n', round_best_Kd);
    fprintf('Score = %.6f\n\n', round_best_Score);

    if round_best_Score < best_Score
        best_Score = round_best_Score;
        best_Kp = round_best_Kp;
        best_Ki = round_best_Ki;
        best_Kd = round_best_Kd;
    end

    % Shrink the search window, but not too aggressively
    Kp_range = max(0.75 * Kp_range, 0.05 * Kp);
    Ki_range = max(0.75 * Ki_range, 0.05 * Ki);
    Kd_range = max(0.75 * Kd_range, 0.02);
end

fprintf('==============================\n');
fprintf('Final best values found:\n');
fprintf('Kp = %.6f\n', best_Kp);
fprintf('Ki = %.6f\n', best_Ki);
fprintf('Kd = %.6f\n', best_Kd);
fprintf('Nf = %.6f\n', Nf);
fprintf('Best Score = %.6f\n', best_Score);

assignin('base', 'Kp', best_Kp);
assignin('base', 'Ki', best_Ki);
assignin('base', 'Kd', best_Kd);
assignin('base', 'Nf', Nf);

sim(MODEL, 'StopTime', '2');

save('pid_search_results.mat', 'results_matrix', 'best_Kp', 'best_Ki', 'best_Kd', 'Nf', 'best_Score');

disp('Search complete. Best values are now in the workspace.');