function expanded_global_calc_array = expand_global_calc_array(global_calc_array, contrasts_to_process)
    % This function expands the global calculation array to match the number of contrasts per subject.
    % Called from get_paths_lv2.m
    % Inputs:
    %   global_calc_array: array containing the global calculation values (1 row per subject)
    %   contrasts_to_process: cell array containing the contrasts to process
    % Outputs:
    %   output: the expanded global calculation array
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % get the number of contrasts
    num_contrasts = length(contrasts_to_process);

    % replicate each value of the global calculation array num_contrasts times
    expanded_global_calc_array = zeros(length(global_calc_array) * num_contrasts, 1);
    for i = 1:length(global_calc_array)
        expanded_global_calc_array((i - 1) * num_contrasts + 1:i * num_contrasts) = repmat(global_calc_array(i), num_contrasts, 1);
    end

end