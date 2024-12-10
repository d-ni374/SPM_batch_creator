function output = json_update_dm(first_level_json, json_path_in, nodes, node_idx, edges, fmri_model_idx, design_matrix_col_names, dm_cond_col_names, update_flag, validation_output_lv2)
    % Updates the json file with contents of the design matrix:
    % writes json file with updated predictors "X" (mandatory) and 
    % "HRF.Variables" (if present) to output directory;
    % Called from json_validator_bids_values.m
    %
    % OPTION: replace design_matrix_col_names with predictors_list to use custom names
    %
    % Daniel Huber, University of Innsbruck, Novemeber 2024

    first_lv_node_idx = node_idx;
    if nargin == 9 % relevant if no second level node is defined
        second_lv_node_idx = 0;
        factorial_design_idx = 0;
        design_type = 0;
    else
        second_lv_node_idx = validation_output_lv2.second_lv_node_idx;
        factorial_design_idx = validation_output_lv2.factorial_design_idx;
        design_type = validation_output_lv2.design_type;
    end
    if ~update_flag
        % validate X and HRF.Variables
        validation_status = 1;
        if ~all(ismember(nodes{node_idx}.Model.X, design_matrix_col_names))
            validation_status = 0;
            warning('The design matrix predictors do not match the predictors in the json file.');
        end
        if isfield(nodes{node_idx}.Model, 'HRF')
            if ~all(ismember(nodes{node_idx}.Model.HRF.Variables, design_matrix_col_names))
                validation_status = 0;
                warning('The HRF variables do not match the predictors in the json file.');
            end
        end
        status = validation_status;
    else
        nodes{node_idx}.Model.X = design_matrix_col_names;
        if isfield(nodes{node_idx}.Model, 'HRF')
            var_cnt = 0;
            nodes{node_idx}.Model.HRF.Variables = {};
            for i = 1:length(design_matrix_col_names)
                for j = 1:length(dm_cond_col_names)
                    if strfind(design_matrix_col_names{i}, dm_cond_col_names{j})
                        var_cnt = var_cnt + 1;
                        nodes{node_idx}.Model.HRF.Variables{var_cnt} = design_matrix_col_names{i};
                    end
                end
            end
            nodes{node_idx}.Model.HRF.Variables = unique(nodes{node_idx}.Model.HRF.Variables, 'stable');
        end
        
        % fix escape characters
        nodes = fix_escape_characters_json_output(nodes, first_lv_node_idx, fmri_model_idx, second_lv_node_idx, factorial_design_idx, design_type);

        % apply changes
        first_level_json_out = first_level_json;
        first_level_json_out = rmfield(first_level_json_out, 'Nodes');
        first_level_json_out.Nodes = nodes;
        first_level_json_out.Edges = edges;

        % update json file
        json_path_out = json_path_in; % file will be overwritten
        %[path, file_name, ext] = fileparts(json_path_in);
        %json_path_out = fullfile(json_dir_out, [file_name, ext]);
        fid = fopen(json_path_out, 'w');
        encodedJSON = jsonencode(first_level_json_out, PrettyPrint=true);
        fprintf(fid,encodedJSON);
        fclose(fid);
        status = 1;
    end
    output.status = status;
    output.nodes = nodes;

end