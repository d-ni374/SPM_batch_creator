function output = filter_global_calculation_pairs(global_calc_pairs, indices_to_remove)
    % The global calculation values are filtered by indices to remove;
    % The function returns the filtered global calculation values.
    % Called from get_paths_lv2.m
    %
    % Inputs:
    %   global_calc_pairs: cell array of sub_ids and global calculation values
    %   indices_to_remove: array of indices to remove
    % Outputs:
    %   output: a struct containing the filtered global calculation values
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    % filter the global calculation values by subject IDs
    filtered_pairs = global_calc_pairs;
    filtered_pairs(indices_to_remove,:) = [];
    filtered_global_calc_values = filtered_pairs(:,3:4);
    reshaped_filtered_global_calc_values = reshape_values(filtered_global_calc_values);

    output.values = reshaped_filtered_global_calc_values;

end