function output = apply_filters_con_cov_2(paths_array, cov_array)
    % This function removes the entries (columns) of the paths_array and cov_array
    % that contain missing data in either of the arrays. This function is very 
    % similar to apply_filters_con_cov.m, but checks for missing data in columns.
    % Called from get_paths_lv2.m
    %
    % Inputs:
    %   paths_array: cell array containing the paths
    %   cov_array: cell array containing the covariates
    % Outputs:
    %   output: a struct containing the filtered arrays
    %   output.paths_array: the filtered paths array
    %   output.cov_array: the filtered covariate array
    %   output.removed_indices: the indices of the removed entries
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % filter for empty paths only if the covariate array is empty
    if isempty(cov_array)
        missing_data = any(cellfun(@isempty, paths_array), 1);
        paths_array_filtered = paths_array(:,~missing_data);
        cov_array_filtered = {};
        removed_indices = find(missing_data);
    else
        % check if the input arrays are of the same length
        if size(paths_array, 2) ~= size(cov_array, 2)
            error('The paths array and the covariates array have different number of columns.');
        end
        % Find indices of missing data
        missing_data = any(cellfun(@isempty, paths_array), 1) | any(cellfun(@isempty, cov_array), 1) | any(cellfun(@(x) any(isnan(x)), cov_array), 1);
        paths_array_filtered = paths_array(:,~missing_data);
        cov_array_filtered = cov_array(:,~missing_data);
        removed_indices = find(missing_data);
    end

    output.paths_array = paths_array_filtered;
    output.cov_array = cov_array_filtered;
    output.removed_indices = removed_indices;

end