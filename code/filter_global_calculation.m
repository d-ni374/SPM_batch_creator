function output = filter_global_calculation(user_specified_values, indices_to_remove)
    % The global calculation values are filtered by indices to remove;
    % The function returns the filtered global calculation values.
    % Called from get_paths_lv2.m
    %
    % Inputs:
    %   user_specified_values: array of user specified global calculation values
    %   indices_to_remove: array of indices to remove
    % Outputs:
    %   output: a struct containing the filtered global calculation values
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    % filter the global calculation values by subject IDs
    filtered_values = user_specified_values;
    filtered_values(indices_to_remove) = [];

    output.values = filtered_values;

end