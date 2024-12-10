function global_calc_value_pairs = assign_global_calc_values(global_calc_values, subject_list_pairs, n_contrasts)
    % This function assigns the global calculation values to the subject list pairs.
    % Each pair of global calc values have to be repeated n_contrasts times in the global_calc_value_pairs,
    % i.e. each single value has to be repeated n_contrasts times.
    % Inputs:
    %   global_calc_values: array of global calculation values
    %   subject_list_pairs: cell array of subject list pairs
    %   n_contrasts: number of contrasts
    % Called from get_paths_lv2.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    global_calc_value_pairs = cell(size(subject_list_pairs, 1), 4);
    global_calc_value_pairs(:, 1:2) = subject_list_pairs;
    for i = 1:length(global_calc_values)/2
        for j = 1:n_contrasts
            global_calc_value_pairs{j+(i-1)*n_contrasts, 3} = global_calc_values(i);
            global_calc_value_pairs{j+(i-1)*n_contrasts, 4} = global_calc_values(i + length(global_calc_values)/2);
        end
    end

end