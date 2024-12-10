function status = json_update_dm_lv2(json, json_path_in, nodes, node_idx, edges, design_matrix_col_names, validation_output_lv1, validation_output_lv2, update_flag)
    % Updates the json file with contents of the design matrix:
    % writes json file with updated predictors "X" (mandatory) to output directory;
    % called from json_validator_bids_values.m
    %
    % Daniel Huber, University of Innsbruck, Novemeber 2024

    first_lv_node_idx = validation_output_lv1.first_lv_node_idx;
    fmri_model_idx = validation_output_lv1.fmri_model_idx;
    second_lv_node_idx = node_idx;
    factorial_design_idx = validation_output_lv2.factorial_design_idx;
    design_type = validation_output_lv2.design_type;
    if ~update_flag
        % validate X and HRF.Variables
        validation_status = 1;
        if ~all(ismember(nodes{node_idx}.Model.X, design_matrix_col_names))
            validation_status = 0;
            warning('The design matrix predictors do not match the predictors in the json file.');
        end
        status = validation_status;
    else
        nodes{node_idx}.Model.X = cell(1,length(design_matrix_col_names));
        for i = 1:length(design_matrix_col_names)
            nodes{node_idx}.Model.X{i} = design_matrix_col_names{i};
        end
        
        % fix escape characters
        nodes = fix_escape_characters_json_output(nodes, first_lv_node_idx, fmri_model_idx, second_lv_node_idx, factorial_design_idx, design_type);

        % apply changes
        json_out = json;
        json_out = rmfield(json_out, 'Nodes');
        json_out.Nodes = nodes;
        json_out.Edges = edges;

        % update json file
        json_path_out = json_path_in; % file will be overwritten
        %[path, file_name, ext] = fileparts(json_path_in);
        %json_path_out = fullfile(json_dir_out, [file_name, ext]);
        fid = fopen(json_path_out, 'w');
        encodedJSON = jsonencode(json_out, PrettyPrint=true);
        fprintf(fid,encodedJSON);
        fclose(fid);
        status = 1;
    end

end