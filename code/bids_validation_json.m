function output = bids_validation_json(json, json_path_in, nodes, edges, execution_level, update_flag, logfile_flag, GUI_flag)
    % This function organises the validation of a json file for its compatibility 
    % with the BIDS Stats Models Specification.
    % In the first step, the structure of the json file is validated (as 
    % defined by BIDS stats model proposal).
    % In the second step, the given values of the json file are checked for 
    % their compatibilty with the format requirements.
    % Called from SPM_batch_creator.m
    % This script calls the following functions:
    % - json_validator_bids_structure.m
    % - json_validator_bids_values.m
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    % structural validation
    validation_output = json_validator_bids_structure(json, nodes, edges);
    validation_status = validation_output.validation_status;
    
    % validation of values given in json
    if validation_status
        validation_output_values = json_validator_bids_values(json, json_path_in, nodes, edges, execution_level, update_flag, logfile_flag, GUI_flag);
        validation_status = validation_output_values.validation_status;
        output.conditions_names = validation_output_values.conditions_names;
        if isfield(validation_output_values, 'dm_col_names') % might not exist if extended validation is skipped
            output.dm_col_names = validation_output_values.dm_col_names;
        end
        %output.all_dm_col_names = validation_output_values.all_dm_col_names; % not yet clear if needed
        output.contrast_names_list = validation_output_values.contrast_names_list;
        output.software_index_spm = validation_output_values.software_index_spm;
        output.validation_output_lv1 = validation_output_values.validation_output_lv1;
        if isfield(validation_output_values, 'validation_output_lv2')
            output.validation_output_lv2 = validation_output_values.validation_output_lv2;
        end
        if execution_level == 2
            output.contrast_names_list_lv2 = validation_output_values.contrast_names_list_lv2;
            output.dm_col_names_dataset = validation_output_values.dm_col_names_dataset;
            %output.all_dm_col_names_dataset = validation_output_values.all_dm_col_names_dataset; % not yet clear if needed
        end
    else
        warning('The json file does not comply with the structure of the BIDS Stats Models Specification.');
    end

    output.validation_status = validation_status;

end