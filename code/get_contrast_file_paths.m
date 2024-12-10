function output = get_contrast_file_paths(input_dirs, contrasts_to_process, input_file_type, input_filter_regexp_)
    % This function extracts the contrast file paths from the input directories, 
    % given the input file type and the input filter regular expression (optional).
    % The function works very similar to get_subject_file_paths.m, but input and output 
    % structures are different.
    % 'input_file_type' can be 'con', 'ess', 'beta', or 'other'.
    % 'input_file_type' is prioritized over 'input_filter_regexp_'.
    % Called from get_paths_lv2.m
    % This script calls the following functions:
    % - get_input_filter_regexp.m
    % - get_paths_regexp.m
    % - get_contrast_index.m
    % - specs_namespace.m
    % Inputs:
    %   input_dirs: cell array containing the input directories
    %   contrasts_to_process: cell array containing the contrasts to process
    %   input_file_type: the input file type according to the json
    %   input_filter_regexp_: the input filter regular expression (optional)
    % Outputs:
    %   output: a struct containing the validation status and the data
    %   output.validation_status: the validation status
    %   output.data: the data
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    validation_status = 1;
    exclusion_list = cell(1, length(contrasts_to_process));
    input_filter_regexp = get_input_filter_regexp(input_file_type);
    if isempty(input_filter_regexp)
        TypeOther = 1;
        input_filter_regexp = input_filter_regexp_;
    else
        TypeOther = 0;
    end
    if TypeOther
        data = get_paths_regexp(input_dirs, contrasts_to_process, input_filter_regexp);
        validation_status = data.validation_status && validation_status;
        SPM_data = data.data;
        paths_array = data.paths_array;
        exclusion_list = data.exclusion_list;
    else
        SPM_data = struct();
        paths_array = cell(length(input_dirs), length(contrasts_to_process));
        for i = 1:length(input_dirs)
            try
                SPM_ = load(fullfile(input_dirs{i}, 'SPM.mat'));
            catch
                warning('The SPM.mat file does not exist for %s. First level analysis needs to be executed first.', input_dirs{i});
                output.execute_first_level = 1;
                continue;
            end
            if ~isfield(SPM_.SPM, 'Vbeta') % in case something failed during first level model estimation
                warning('No beta files found for %s. The subject will be excluded.', input_dirs{i});
                for j = 1:length(contrasts_to_process)
                    exclusion_list{1, j} = [exclusion_list{1, j}, i];
                end
                continue;
            end
            for j = 1:length(contrasts_to_process)
                contrast_name = contrasts_to_process{j};
                output_SPM = get_contrast_index(SPM_.SPM, contrast_name, input_file_type);
                contrast_index = output_SPM.contrast_index;
                contrast_file_name = output_SPM.file_name;
                if isempty(contrast_index) || isempty(contrast_file_name)
                    exclusion_list{1, j} = [exclusion_list{1, j}, i];
                    warning('The contrast name %s does not exist for %s. The subject will be excluded for this contrast.', contrast_name, input_dirs{i});
                else
                    SPM_data(i).input_dir = input_dirs{i};
                    SPM_data(i).contrast{j}.contrast_index = contrast_index;
                    SPM_data(i).contrast{j}.contrast_file_name = contrast_file_name;
                    SPM_data(i).contrast{j}.contrast_name = contrast_name;
                    SPM_data(i).contrast{j}.contrast_file_path = fullfile(input_dirs{i}, contrast_file_name);
                    validation_status = fct_lib.check_file(SPM_data(i).contrast{j}.contrast_file_path, sprintf('%s', SPM_data(i).contrast{j}.contrast_file_path)) && validation_status;
                    paths_array{i, j} = SPM_data(i).contrast{j}.contrast_file_path;
                end
            end
            clear SPM_;
        end
    end

    output.validation_status = validation_status;
    output.data = SPM_data;
    output.paths_array = paths_array;
    output.exclusion_list = exclusion_list;

end