function output = multi_cond_validation(multi_cond_file_path, conditions_names, verbose)
    % This function validates, if a .mat file containing multiple conditions 
    % (including names, onsets, durations, tmod, pmod) is compatible with the
    % SPM12 requirements;
    % called from get_conditions_regressors.m
    % This script calls the following functions:
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, Novemeber 2024

    % import function library
    fct_lib = specs_namespace();

    validation_status = true; % default status

    if ~isempty(multi_cond_file_path)
        length_conditions_names = length(conditions_names);
        validation_status = fct_lib.check_file_type(multi_cond_file_path,'.*mat$', multi_cond_file_path) && validation_status;
        multiple_conditions = load(multi_cond_file_path);
        validation_status = fct_lib.check_structure_field(multiple_conditions, 'names', multi_cond_file_path) && validation_status;
        validation_status = fct_lib.check_structure_field(multiple_conditions, 'onsets', multi_cond_file_path) && validation_status;
        validation_status = fct_lib.check_structure_field(multiple_conditions, 'durations', multi_cond_file_path) && validation_status;
        for i = 1:length(multiple_conditions.names)
            if ~isfield(multiple_conditions, 'tmod') && verbose
                fprintf('Info: (Optional) input for time modulation not found in %s: tmod\n', multi_cond_file_path);
            end
            if isfield(multiple_conditions, 'pmod')
                validation_status = fct_lib.check_structure_field(multiple_conditions.pmod, 'name', ['pmod cell array of ' multi_cond_file_path]) && validation_status;
                validation_status = fct_lib.check_structure_field(multiple_conditions.pmod, 'param', ['pmod cell array of ' multi_cond_file_path]) && validation_status;
                validation_status = fct_lib.check_structure_field(multiple_conditions.pmod, 'poly', ['pmod cell array of ' multi_cond_file_path]) && validation_status;
            else
                if verbose
                    fprintf('Info: (Optional) input for parametric modulations not found in %s: pmod\n', ['pmod of cell array of ' multi_cond_file_path]);
                end
            end
        end
        if ~isfield(multiple_conditions, 'orth') && verbose
            fprintf('Info: (Optional) input for orthogonalisation not found in %s: orth\n', multi_cond_file_path);
        end
        for j = 1:length(multiple_conditions.names)
            validation_status = fct_lib.check_name_validity(multiple_conditions.names{j}, conditions_names, 'condition') && validation_status;
            conditions_names{length_conditions_names + j} = multiple_conditions.names{j};
        end
    else
        validation_status = false;
    end
    output.status = validation_status;
    output.conditions_names = conditions_names;

end