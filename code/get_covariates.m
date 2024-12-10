function covariates_data_filtered = get_covariates(nodes, node_idx, task, factorial_design_idx, subject_ids, design_type)
    % Get the covariates for the participants of the study;
    % The covariates data is filtered by subject IDs;
    % The function returns the filtered covariates data.
    % called from get_paths_lv2.m
    % This script calls the following functions:
    % - find_participants_file.m
    % - read_participants_file.m
    % - filter_covariates_data.m
    % Inputs:
    %   nodes: cell array of nodes
    %   node_idx: index of the current node
    %   task: task name
    %   factorial_design_idx: index of the factorial design instruction
    %   subject_ids: cell array of subject IDs
    %   design_type: factorial design type
    % Outputs:
    %   covariates_data_filtered: cell array of filtered covariates data
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    % get the covariates data
    covariates_data = struct();
    cov_idx = 1;
    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'Covariates') && ...
        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates) && ...
        iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates) && ...
        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{1}.ColName)
        participants_file_path = find_participants_file(nodes, node_idx, task, factorial_design_idx);
        for j = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates)
            participants_info = read_participants_file(participants_file_path{1}, {nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{j}.ColName});
            covariates_data(cov_idx).data = participants_info;
            cov_idx = cov_idx + 1;
            if ~participants_info.status
                warning('Source file contains incomplete data for covariate %s.', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{j}.Name);
            end
        end
    end

    % get additional covariates data for "Multiple Regression" design
    if design_type == 4
        if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression, 'Covariates') && ...
            ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates) && ...
            iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates) && ...
            ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{1}.ColName)
            participants_file_path = find_participants_file_multireg(nodes, node_idx, task, factorial_design_idx);
            for j = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates)
                participants_info = read_participants_file(participants_file_path{1}, {nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.ColName});
                covariates_data(cov_idx).data = participants_info;
                cov_idx = cov_idx + 1;
                if ~participants_info.status
                    warning('Source file contains incomplete data for covariate %s.', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                end
            end
        end
    end

    % exit function if no covariates data is found
    if cov_idx == 1
        covariates_data_filtered = {};
        return
    end

    % filter the covariates data by subject IDs
    covariates_data_filtered_ = struct();
    for i = 1:length(covariates_data)
        covariates_data_filtered_(i).data = filter_covariates_data(covariates_data(i).data, subject_ids);
    end

    % re-structure the covariates data for output
    for i = 1:length(covariates_data_filtered_)
        covariates_data_filtered(:, i) = covariates_data_filtered_(i).data;
    end

end