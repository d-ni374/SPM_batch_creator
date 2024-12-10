function output = get_paths_regexp(input_dirs, contrasts_to_process, input_filter_regexp)
    % This function extracts the paths from the input directories, given the input filter regular expression.
    % Called from get_contrast_file_paths.m and get_subject_file_paths.m
    %
    % Inputs:
    %   input_dirs: cell array containing the input directories
    %   contrasts_to_process: cell array containing the contrasts to process
    %   input_filter_regexp: cell array of the input filter regular expressions,
    %   one for each contrast (the order is assumed to match the order of contrasts_to_process)
    % Outputs:
    %   output: a struct containing the validation status and the data
    %   output.validation_status: the validation status
    %   output.data: the data
    %
    % Daniel Huber, University of Innsbruck, 2024

    % import function library
    fct_lib = specs_namespace();

    validation_status = 1; % Initialize the validation status
    % Get the paths
    data = struct();
    paths_array = cell(length(input_dirs), length(contrasts_to_process));
    exclusion_list = cell(1, length(contrasts_to_process));
    for i = 1:length(input_dirs)
        for j = 1:length(contrasts_to_process)
            file = fct_lib.get_file_names(input_dirs{i}, input_filter_regexp{j});
            if isempty(file)
                validation_status = 0;
                warning('No files found for regexp %s in %s. The subject will be excluded.', input_filter_regexp{j}, input_dirs{i});
                exclusion_list{1, j} = [exclusion_list{1, j}, i];
            elseif length(file) > 1
                validation_status = 0;
                warning('Multiple files found for regexp %s in %s. The subject will be excluded.', input_filter_regexp{j}, input_dirs{i});
                exclusion_list{1, j} = [exclusion_list{1, j}, i];
            else
                data(i).contrast{j}.contrast_name = contrasts_to_process{j};
                data(i).contrast{j}.contrast_file_name = file{1};
                data(i).contrast{j}.contrast_file_path = fullfile(input_dirs{i}, file{1});
                validation_status = fct_lib.check_file(data(i).contrast{j}.contrast_file_path, sprintf('%s', data(i).contrast{j}.contrast_file_path)) && validation_status;
                paths_array{i, j} = data(i).contrast{j}.contrast_file_path;
            end
        end
    end

    output.validation_status = validation_status;
    output.data = data;
    output.paths_array = paths_array;
    output.exclusion_list = exclusion_list;

end