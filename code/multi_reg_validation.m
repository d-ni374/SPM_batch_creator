function output = multi_reg_validation(multi_reg_file_path, check_size, verbose)
    % This function validates, if a .mat|.txt|.tsv file containing multiple regressors 
    % is compatible with the SPM12 requirements;
    % The length of the confounder data must match the number of images given by check_size.
    % called from get_conditions_regressors.m
    % This script calls the following functions:
    % - specs_namespace.m
    % - convert_mov_tsv_to_mat.m
    % - replace_nan.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    validation_status = true; % default status

    if ~isempty(multi_reg_file_path)
        validation_status = fct_lib.check_file_type(multi_reg_file_path,'.*(mat|txt|tsv)$', multi_reg_file_path) && validation_status;
        [path,file,ext] = fileparts(multi_reg_file_path);
        if strcmp(ext, '.mat')
            multiple_regressors = load(multi_reg_file_path);
            if ~isfield(multiple_regressors, 'R')
                warning('Required variable R for multiple regressors not found in %s \n', multi_reg_file_path);
                validation_status = false;
            else
                multiple_regressors_repl = replace_nan(multiple_regressors.R, multi_reg_file_path); % NaN are replaced by zeros
                if ~isfield(multiple_regressors, 'names') && verbose
                    fprintf('Optional variable names for multiple regressors not found in %s: Confounders named automatically \n', multi_reg_file_path);
                    if multiple_regressors_repl.replace
                        multi_reg_file_path = fullfile(path, strcat(file, '_repl.mat'));
                        R = multiple_regressors_repl.R;
                        save(multi_reg_file_path, 'R');
                    end
                else
                    if multiple_regressors_repl.replace
                        multi_reg_file_path = fullfile(path, strcat(file, '_repl.mat'));
                        R = multiple_regressors_repl.R;
                        reg_names = multiple_regressors.names;
                        save(multi_reg_file_path, 'R', 'reg_names');
                    end
                    if size(multiple_regressors.R, 2) ~= length(multiple_regressors.names)
                        warning('The number of columns in the file %s does not match the number of names.', multi_reg_file_path);
                    end
                end
                if size(multiple_regressors.R, 1) ~= check_size
                    warning('The number of rows in the file %s does not match the number of images.', multi_reg_file_path);
                    validation_status = false;
                end
            end
        elseif strcmp(ext, '.tsv')
            status_convert = convert_mov_tsv_to_mat(multi_reg_file_path, check_size);
            if ~status_convert
                warning('Conversion of .tsv file to .mat file failed: %s', multi_reg_file_path);
                validation_status = false;
            else
                multi_reg_file_path = fullfile(path, strcat(file, '.mat'));
            end
        elseif strcmp(ext, '.txt')
            multiple_regressors = load(multi_reg_file_path);
            multiple_regressors_repl = replace_nan(multiple_regressors, multi_reg_file_path); % NaN are replaced by zeros
            if multiple_regressors_repl.replace
                multi_reg_file_path = fullfile(path, strcat(file, '_repl.mat'));
                R = multiple_regressors_repl.R;
                save(multi_reg_file_path, 'R');
            end
            if size(multiple_regressors, 1) ~= check_size
                warning('The number of rows in the file %s does not match the number of images.', multi_reg_file_path);
                validation_status = false;
            end
        end
    end

    % create output
    output.status = validation_status;
    output.multi_reg_file_path = multi_reg_file_path;

end