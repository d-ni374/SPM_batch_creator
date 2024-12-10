function output = json_validator_bids_values(json, json_path_in, nodes, edges, execution_level, update_flag, logfile_flag, GUI_flag)
    % Validate the content of a json file for its compatibility with the BIDS Stats Models Specification
    % Called from bids_validation_json.m
    % This script calls the following functions:
    % - specs_namespace.m
    % - start_logfile.m
    % - valid_bids_lv1_dm.m
    % - valid_bids_lv2_dm.m
    % - define_model.m
    % - json_validator_bids_contrasts.m
    % - json_validator_contrasts_to_process_lv2.m
    % - get_paths_lv2.m
    % - define_model_lv2.m
    % - get_design_matrix_cols.m
    % - write_single_subject_json.m
    % - json_update_dm.m
    % - json_update_dm_lv2.m
    % - validation_message.m
    %
    % Inputs:
    % json: struct, json file content
    % json_path_in: string, path to the json file
    % nodes: struct of nodes
    % edges: struct of edges
    % execution_level: int, 1 for first level analysis, 2 for second level analysis
    % update_flag: int, flag to update the json file
    % logfile_flag: int, flag to save a logfile
    % GUI_flag: int, flag to indicate if called from GUI
    %
    % Outputs:
    % output: struct, output of the function
    % output.validation_status: bool, status of the validation
    % output.conditions_names: cell array , names of the conditions
    % output.dm_col_names: cell array, names of the design matrix columns for each subject (in separate cells)
    % output.all_dm_col_names: cell array, names of the design matrix columns for all subjects (union of all subjects)
    % output.dm_col_names_dataset: cell array, names of the design matrix columns for each contrast (in separate cells)
    % output.all_dm_col_names_dataset: cell array, names of the design matrix columns for all contrasts (union of all contrasts)
    %
    % Daniel Huber, University of Innsbruck, 2024

    % import function library
    fct_lib = specs_namespace();

    % Validate the main inputs
    validation_status = true;
    validation_status = fct_lib.check_type(json.BIDSModelVersion, 'char', 'BIDSModelVersion') && validation_status;
    validation_status = fct_lib.check_type(json.Name, 'char', 'Name') && validation_status;
    if isfield(json, 'Description')
        validation_status = fct_lib.check_type(json.Description, 'char', 'Description') && validation_status;
    end

    % Validate the Input section: all entries are optional, but if present, they must be of type char
    if isfield(json, 'Input')
        if isfield(json.Input, 'task')
            validation_status = fct_lib.check_type(json.Input.task, 'char', 'Input.task') && validation_status;
            task = json.Input.task;
        end
        if isfield(json.Input, 'run')
            validation_status = fct_lib.check_type(json.Input.run, 'char', 'Input.run') && validation_status;
            run_id = json.Input.run; % not yet clear if needed
        end
        if isfield(json.Input, 'session')
            validation_status = fct_lib.check_type(json.Input.session, 'char', 'Input.session') && validation_status;
            sess_id = json.Input.session; % not yet clear if needed
        end
        if isfield(json.Input, 'subject')
            validation_status = fct_lib.check_type(json.Input.subject, 'char', 'Input.subject') && validation_status;
            sub_id = json.Input.subject; % not yet clear if needed
        end
    end

    % Validate the Nodes section
    for node_idx = 1:length(nodes)
        fprintf('Validating Node %d\n', node_idx);
        validation_status = fct_lib.check_options(nodes{node_idx}.Level, {'Run', 'Session', 'Subject', 'Dataset'}, 'Nodes.Level') && validation_status;
        if lower(nodes{node_idx}.Level) == "run" || lower(nodes{node_idx}.Level) == "session" || lower(nodes{node_idx}.Level) == "subject"
            validate_lv1 = valid_bids_lv1_dm(nodes, validation_status, node_idx);
            fmri_model_idx = validate_lv1.fmri_model_idx;
            conditions_names = validate_lv1.conditions_names;
            all_participant_ids = validate_lv1.all_participant_ids;
            %%first_lv_node_id = validate_lv1.first_lv_node_id;
            % start logfile
            if logfile_flag && execution_level == 1
                start_logfile(nodes, node_idx, fmri_model_idx);
            end
            msg = validation_message(validate_lv1);
            fprintf(msg);
            validation_status = validate_lv1.validation_status && validation_status;
        elseif lower(nodes{node_idx}.Level) == "dataset"
            validate_lv2 = valid_bids_lv2_dm(nodes, validation_status, node_idx, all_participant_ids);
            factorial_design_idx = validate_lv2.factorial_design_idx;
            %%second_lv_node_id = validate_lv2.second_lv_node_id;
            % start logfile
            if logfile_flag && execution_level == 2
                start_logfile(nodes, node_idx, factorial_design_idx);
            end
            msg = validation_message(validate_lv2);
            fprintf(msg);
            validation_status = validate_lv2.validation_status && validation_status;
        else
            warning('The Level of the Node is not valid');
            validation_status = false;
        end
    end

    % Get design matrix columns from SPM to validate Contrast section
    for node_idx = 1:length(nodes)
        if lower(nodes{node_idx}.Level) == "run" || lower(nodes{node_idx}.Level) == "session" || lower(nodes{node_idx}.Level) == "subject"
            bids_flag = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BIDSflag;
            participants = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID;
            dm_col_names = cell(1, length(participants));
            dm_cond_col_names = cell(1, length(participants));
            if execution_level == 1
                for sub_idx = 1:length(participants)
                    fprintf('\nValidating data for participant "%s"\n', participants{sub_idx});
                    participant_dir = fullfile(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputDirectory, participants{sub_idx});
                    matlabbatch_ = define_model(nodes, node_idx, task, fmri_model_idx, participant_dir, conditions_names, sub_idx, bids_flag); % definition of the model according to the json file
                    matlabbatch = matlabbatch_.matlabbatch;
                    nodes = matlabbatch_.nodes; % update nodes with new information
                    matlabbatch_spm_res = get_design_matrix_cols(matlabbatch);
                    dm_col_names{sub_idx} = matlabbatch_spm_res.design_matrix_column_names; % get the column names of the design matrix
                    dm_cond_col_names{sub_idx} = matlabbatch_spm_res.cond_column_names; % get the column names related to conditions
                    if sub_idx == 1
                        all_dm_col_names = dm_col_names{sub_idx};
                        all_dm_cond_col_names = dm_cond_col_names{sub_idx};
                    else
                        all_dm_col_names = union(all_dm_col_names, dm_col_names{sub_idx}, 'stable');
                        all_dm_cond_col_names = union(all_dm_cond_col_names, dm_cond_col_names{sub_idx}, 'stable');
                    end
                    if ~GUI_flag
                        write_single_subject_json(json, json_path_in, nodes, node_idx, fmri_model_idx, dm_col_names{sub_idx}, dm_cond_col_names{sub_idx}, sub_idx, matlabbatch, 1); % the last argument is the update flag
                    end
                    if sub_idx == length(participants)
                        if exist('validate_lv2', 'var')
                            updated_nodes = json_update_dm(json, json_path_in, nodes, node_idx, edges, fmri_model_idx, all_dm_col_names, all_dm_cond_col_names, update_flag, validate_lv2);
                        else % handle the case where there is no second level node
                            updated_nodes = json_update_dm(json, json_path_in, nodes, node_idx, edges, fmri_model_idx, all_dm_col_names, all_dm_cond_col_names, update_flag);
                        end
                        if isempty(nodes{node_idx}.Model.X) && ~GUI_flag
                            error('NODE %d: The design matrix predictors are empty. Please check automatically generated predictors and update the contrasts section with them.', node_idx);
                        end
                        if update_flag == 1 && updated_nodes.status == 1
                            nodes = updated_nodes.nodes;
                        end
                    end
                    clear matlabbatch matlabbatch_spm_res;
                end
            else
                fprintf('Skipping extended validation for node %d\n', node_idx);
            end
            %validate the contrasts
            validation_contrasts = json_validator_bids_contrasts(nodes, node_idx);
            validation_status = validation_contrasts.validation_status && validation_status;
            software_index_spm{node_idx} = validation_contrasts.software_index_spm;
            contrast_names_list = validation_contrasts.contrast_names_list;
        elseif lower(nodes{node_idx}.Level) == "dataset"
            if execution_level == 2
                model_name = json.Name;
                validation_contrasts_to_process_lv2 = json_validator_contrasts_to_process_lv2(nodes, node_idx, contrast_names_list);
                validation_status = validation_contrasts_to_process_lv2.validation_status && validation_status;
                validate_lv2 = get_paths_lv2(nodes, node_idx, task, validate_lv1, validate_lv2);
                validation_status = validate_lv2.validation_status && validation_status;
                contrasts_to_process = validate_lv2.contrasts_to_process;
                if ~isempty(contrasts_to_process)
                    n_cons = length(contrasts_to_process);
                else
                    n_cons = 1;
                end
                dm_col_names_dataset = cell(1, n_cons);
                for con_idx = 1:n_cons % can be different from 1 only for one-sample t-test, two-sample t-test, and multiple regression
                    matlabbatch = define_model_lv2(model_name, nodes, node_idx, validate_lv2, con_idx); % definition of the model according to the json file
                    matlabbatch_spm_res = get_design_matrix_cols_lv2(matlabbatch);
                    dm_col_names_dataset{con_idx} = matlabbatch_spm_res.design_matrix_column_names; % get the column names of the design matrix
                    if con_idx == 1
                        all_dm_col_names_dataset = dm_col_names_dataset{con_idx};
                    else
                        all_dm_col_names_dataset = union(all_dm_col_names_dataset, dm_col_names_dataset{con_idx}, 'stable');
                    end
                    if con_idx == n_cons
                        if ~all(cellfun(@(x) isequal(all_dm_col_names_dataset,x), dm_col_names_dataset))
                            warning('The design matrices of the 2nd level factorial design are not identical for all chosen contrasts. Please check.');
                        else
                            json_update_dm_lv2(json, json_path_in, nodes, node_idx, edges, all_dm_col_names_dataset, validate_lv1, validate_lv2, update_flag);
                        end
                        if isempty(nodes{node_idx}.Model.X) && ~GUI_flag
                            error('NODE %d: The design matrix predictors are empty. Please check automatically generated predictors and update the contrasts section with them.', node_idx);
                        end
                    end
                    clear matlabbatch matlabbatch_spm_res;
                end
                %validate the contrasts
                validation_contrasts_lv2 = json_validator_bids_contrasts(nodes, node_idx);
                validation_status = validation_contrasts_lv2.validation_status && validation_status;
                software_index_spm{node_idx} = validation_contrasts_lv2.software_index_spm;
                contrast_names_list_lv2 = validation_contrasts_lv2.contrast_names_list;
            end
        else 
            warning('The Level of the Node is not valid');
            validation_status = false;
        end
    end

    % Validate the Edges section
    if ~isempty(edges) %exist('edges', 'var')
        for edge_idx = 1:length(edges)
            fprintf('Validating Edge %d\n', edge_idx);
            validation_status = fct_lib.check_type(edges{edge_idx}.Source, 'char', 'Edges.Source') && validation_status;
            validation_status = fct_lib.check_type(edges{edge_idx}.Destination, 'char', 'Edges.Destination') && validation_status;
            if ~(isempty(edges{edge_idx}.Source) && isempty(edges{edge_idx}.Destination))
                % Source and Destination must be valid node names:
                node_names = cellfun(@(x) x.Name, nodes, 'UniformOutput', false);
                validation_status = fct_lib.check_options(edges{edge_idx}.Source, node_names, 'Edges.Source') && validation_status;
                validation_status = fct_lib.check_options(edges{edge_idx}.Destination, node_names, 'Edges.Destination') && validation_status;
            end
        end
    end

    % Display the validation status
    if validation_status == false
        warning_ackn = tbx_input_ui('Warning(s) occurred (see command window)', '+1', 'ignore|abort', [1, 0], 0);
        if warning_ackn == 0
            error('Validation failed');
        end
    end

    output.validation_status = validation_status;
    output.conditions_names = conditions_names;
    if exist('dm_col_names', 'var') % might not exist if extended validation is skipped
        output.dm_col_names = dm_col_names;
    end
    %output.all_dm_col_names = all_dm_col_names; % not yet clear if needed
    output.contrast_names_list = contrast_names_list;
    output.software_index_spm = software_index_spm;
    output.validation_output_lv1 = validate_lv1;
    if exist('validate_lv2', 'var')
        output.validation_output_lv2 = validate_lv2;
    end
    if execution_level == 2
        output.contrast_names_list_lv2 = contrast_names_list_lv2;
        output.dm_col_names_dataset = dm_col_names_dataset;
        %output.all_dm_col_names_dataset = all_dm_col_names_dataset; % not yet clear if needed
    end

end