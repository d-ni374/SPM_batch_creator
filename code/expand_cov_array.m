function expanded_cov_array = expand_cov_array(cov_array, contrasts_to_process)
    % This function expands the covariates array to match the number of contrasts per subject.
    % Called from get_paths_lv2.m
    % Inputs:
    %   cov_array: cell array containing the covariates (1 row per covariate, 1 column per subject)
    %   contrasts_to_process: cell array containing the contrasts to process
    % Outputs:
    %   expanded_cov_array: the expanded covariates array
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % get the number of contrasts
    num_contrasts = length(contrasts_to_process);
    
    % replicate each column of the covariates array num_contrasts times
    expanded_cov_array = cell(size(cov_array, 1), size(cov_array, 2) * num_contrasts);
    for i = 1:size(cov_array, 1)
        for j = 1:size(cov_array, 2)
            expanded_cov_array(i, (j - 1) * num_contrasts + 1:j * num_contrasts) = repmat(cov_array(i, j), 1, num_contrasts);
        end
    end

end