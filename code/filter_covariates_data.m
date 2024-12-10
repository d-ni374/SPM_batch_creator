function filtered_data = filter_covariates_data(covariates_data, subject_ids)
    % This function filters the covariates data by subject IDs.
    % Called from get_covariates.m
    % Inputs:
    %   covariates_data: struct containing covariates data
    %   subject_ids: cell array of subject IDs
    % Outputs:
    %   filtered_data: the filtered covariates data
    %
    % Daniel Huber, University of Innsbruck, November 2024

    covariates_array = cell(length(subject_ids), length(covariates_data.covariates_names));
    for i = 1:length(subject_ids)
        for j = 1:length(covariates_data)
            cov_row_idx = find(strcmp(covariates_data.participant_id, subject_ids{i}));
            if isempty(cov_row_idx)
                warning('No data found (covariate "%s") for subject ID %s. -> Skipped!', covariates_data.covariates_names{j}, subject_ids{i});
            else
                covariates_array{i, j} = covariates_data.covariates_data{j}(cov_row_idx);
            end
        end
    end
    filtered_data = covariates_array;

end