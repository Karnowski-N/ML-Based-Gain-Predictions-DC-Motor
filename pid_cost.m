    % Some parts of this code were written and refined with AI assistance
    % AI Assistance is used, but only for revisions and some suggestions
    % Script takes the best values (the ones from classic tuning) and gives
    % these to the Simulink model. They are then run and this script then
    % judges the values based on how successful they are.
function Score = pid_cost(Kp, Ki, Kd, Nf)

    MODEL = 'DCmotorAItuning';
    Stop_Time = '2';

    assignin('base', 'Kp', Kp);
    assignin('base', 'Ki', Ki);
    assignin('base', 'Kd', Kd);
    assignin('base', 'Nf', Nf);

    try
        simOut = sim(MODEL, ...
            'StopTime', Stop_Time, ...
            'ReturnWorkspaceOutputs', 'on');

        % Try direct access first, then out.<name> if needed
        speed_data = get_logged_data(simOut, 'speed');
        error_data = get_logged_data(simOut, 'Error');
        absolute_error_data = get_logged_data(simOut, 'AbsErr');
        control_input_data = get_logged_data(simOut, 'control_input');
        reference_data = get_logged_data(simOut, 'ref');

        [t_speed, y_speed] = unpack_logged_array(speed_data);
        [t_err, y_err] = unpack_logged_array(error_data);
        [t_abs_err, y_abs_err] = unpack_logged_array(absolute_error_data);
        [t_u, y_u] = unpack_logged_array(control_input_data);
        [~, y_ref] = unpack_logged_array(reference_data);

        t_speed = t_speed(:);
        y_speed = y_speed(:);
        t_err = t_err(:);
        y_err = y_err(:);
        t_abs_err = t_abs_err(:);
        y_abs_err = y_abs_err(:);
        t_u = t_u(:);
        y_u = y_u(:);
        y_ref = y_ref(:);

        if isempty(t_speed) || isempty(y_speed) || isempty(y_err) || ...
           isempty(y_abs_err) || isempty(y_u) || isempty(y_ref)
            Score = 1e12;
            return;
        end

        final_ref = y_ref(end);

        iae = trapz(t_abs_err, y_abs_err);
        overshoot = max(y_speed) - final_ref;
        overshoot_penalty = max(0, overshoot)^2;
        control_effort = trapz(t_u, abs(y_u));
        final_error = abs(final_ref - y_speed(end));

        idx_late = find(t_speed >= 0.5, 1, 'first');
        if isempty(idx_late)
            late_penalty = 0;
        else
            late_penalty = max(0, final_ref - y_speed(idx_late))^2;
        end

        Score = ...
            10.0 * iae + ...
            200.0 * overshoot_penalty + ...
            0.05 * control_effort + ...
            50.0 * final_error + ...
            40.0 * late_penalty;

        if ~isfinite(Score)
            Score = 1e12;
        end

    catch
        Score = 1e12;
    end
end

function data = get_logged_data(simOut, var_name)

    try
        data = simOut.get(var_name);
        return;
    catch
    end

    out_data = simOut.get('out');
    data = out_data.(var_name);
end

function [t, y] = unpack_logged_array(data)

    if isnumeric(data)
        if size(data,2) >= 2
            t = data(:,1);
            y = data(:,2);
        elseif size(data,2) == 1
            t = (0:size(data,1)-1)';
            y = data(:,1);
        else
            t = [];
            y = [];
        end
    else
        error('Logged data is not numeric. Make sure format is Array.');
    end
end