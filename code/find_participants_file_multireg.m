function participants_file_path = find_participants_file_multireg(nodes, node_idx, task, factorial_design_idx)
    % This function searches for "participants" files needed to get information 
    % about covariates that are included in the model. For this purpose, it 
    % uses a regular expression pattern; Since the participants file is
    % usually stored in the main directory of the project, it first searches
    % for the file in the main directory, and if it is not found, it searches
    % in the subdirectories. If multiple files are found, it tries to find a 
    % file dedicated to the given task and if that fails selects the first
    % file from the list. If no file is found, it returns an empty cell array.
    % NOTE: This is a modified version of find_participants_file.m to handle 
    % covariates given in the multiple regression design.
    % called from get_covariates.m
    % This script calls the following functions:
    % - specs_namespace.m
    % 
    % INPUTS
    % nodes: cell array; the nodes of the pipeline
    % node_idx: int; the index of the node in the pipeline
    % task: string; the task name
    % factorial_design_idx: int; the index of the factorial design instruction
    %
    % OUTPUTS
    % participants_file_path: string; the path to the participants file
    % 
    % EXAMPLE
    % files = find_files_regexp('subjectPreprocDir', '_events.tsv$', 'foraging', true, {'01', '02'})
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression, 'Covariates')
        participants_file_path = cell(1, length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates));
        for j = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates)
            if iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates) && isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}, 'Name') && ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name)
                participants_info_files = fct_lib.get_file_names(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.MainProjectFolder, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.CovariatesFileRegexp);
                if isempty(participants_info_files)
                    warning('No participants file found in the main project folder for covariate %s.', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                    participants_info_files = fct_lib.recursdir(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.MainProjectFolder, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.CovariatesFileRegexp);
                    if isempty(participants_info_files)
                        warning('No participants file found for covariates %s. Covariate %s will be skipped!', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                        return;
                    elseif length(participants_info_files) > 1
                        filter_task = cellfun(@(x) regexp(x, task), participants_info_files, "UniformOutput", false);
                        participants_info_files_filtered = participants_info_files(cellfun(@(x) ~isempty(x), filter_task));
                        if ~isempty(participants_info_files_filtered)
                            if length(participants_info_files_filtered) > 1
                                participants_info_files{1} = participants_info_files_filtered{1};
                                warning('Multiple participants files found for covariates %s. Using the first one...', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                            else
                                participants_info_files = participants_info_files_filtered;
                            end
                        else
                            warning('Multiple participants files found for covariates %s. Using the first one...', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                        end
                    end
                elseif length(participants_info_files) > 1
                    participants_info_files = fullfile(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.MainProjectFolder, participants_info_files); % full path needed
                    filter_task = cellfun(@(x) regexp(x, task), participants_info_files, "UniformOutput", false);
                    participants_info_files_filtered = participants_info_files(cellfun(@(x) ~isempty(x), filter_task));
                    if ~isempty(participants_info_files_filtered)
                        if length(participants_info_files_filtered) > 1
                            participants_info_files{1} = participants_info_files_filtered{1};
                            warning('Multiple participants files found for covariates %s. Using the first one...', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                        else
                            participants_info_files = participants_info_files_filtered;
                        end
                    else
                        warning('Multiple participants files found in the main project folder for covariate %s. Using the first one...', nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name);
                    end
                else
                    participants_info_files = fullfile(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.MainProjectFolder, participants_info_files); % full path needed
                end
                participants_file_path{j} = participants_info_files{1};
            end
        end
    end

end