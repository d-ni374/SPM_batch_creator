function lib = specs_namespace()
% The functions contained in this library check specific inputs or folder
% structures and convert inputs to SPM readable syntax. Some functions
% might be redundant (since already integrated in Matlab), but provide 
% customized output messages or are not known by the author.
% Daniel Huber, University of Innsbruck, July-September 2023

    timespecs = {'secs', 'units'};
    lib.parsetimespec = @(spec) ismember(spec, timespecs); % checks if timespecs are defined correctly
    lib.get_subject_dirs = @get_subject_dirs; % returns a cell array of all sub-directories of the input directory
    lib.get_valid_subdirs = @get_valid_subdirs; % returns subdirectories which comply with a specified regular expression
    lib.get_data_dirs = @get_data_dirs; % gets all subfolders of input_dir which contain files (the data)
    lib.get_file_names = @get_file_names; % returns all files in a directory which comply with a regular expression
    lib.recursdir = @recursdir; % a recursive search to find files that match the search expression; Author: Jason J. Smoker
    lib.recursdir_folder = @recursdir_folder; % a recursive search to find sub-folders that match the search expression; Modification of previous function
    lib.check_options = @check_options; % checks if a value is member of a list with valid options
    lib.check_class = @check_class; % checks if the class of a field is valid
    lib.check_type = @check_type; % checks if the type of a field is correct for processing
    lib.check_type_weights = @check_type_weights; % checks if the given weights have the correct format for processing
    lib.check_dir = @check_dir; % checks if a valid directory is given
    lib.info_dir_exist = @info_dir_exist; % checks if a directory already exists
    lib.check_file = @check_file; % checks if a valid file is given
    lib.check_regexp = @check_regexp; % checks if a valid regular expression is given
    lib.check_positive_number = @check_positive_number; % checks if a positive number is given
    lib.check_nonnegative_number = @check_nonnegative_number; % checks if number is not negative
    lib.check_length = @check_length; % checks if a vector or call array has the correct length
    lib.check_vector_length = @check_vector_length; % checks if a 1d vector is given with the correct length
    lib.check_same_length = @check_same_length; % checks if two input arrays have the same length
    lib.check_cond_dim = @check_cond_dim; % checks if dimensions of conditions matrix fits number of images and returns which index matches
    lib.check_matching_indices = @check_matching_indices; % checks if all subjects have the same number of conditions 
    lib.check_arrays = @check_arrays; % checks if arrays have the same lengths
    lib.check_array_size = @check_array_size; % checks if two arrays match in size (as is or transposed)
    lib.check_size = @check_size; % checks if array dimensions are correct
    lib.check_matrix = @check_matrix; % checks if matrix dimension corresponds to array
    lib.check_file_type = @check_file_type; % checks if file is correct file type
    lib.check_file_name = @check_file_name; % checks if file name is compatible with a regular expression
    lib.get_ReplicateOverSessions = @get_ReplicateOverSessions; % gives SPM readable variable for ReplicateOverSessions option
    lib.check_order = @check_order; % checks if elements of contrasts are correctly sorted with respect to conditions
    lib.check_virtual_folder = @check_virtual_folder; % checks if a folder does not contain illeagal characters (which are given by regular expression)
    lib.check_name_validity = @check_name_validity; % checks if a contrast name is unique ignoring capitalisation
    lib.check_contrast_condition_list = @check_contrast_condition_list; % checks if the contrast Condition.List is in agreement with X
    lib.check_hrf_variables = @check_hrf_variables; % checks if the HRF variables are in agreement with X
    lib.check_subject_id = @check_subject_id; % checks if the array subject_id is in agreement with the all_participants list
    lib.check_contrast_name = @check_contrast_name; % checks if the array contrast_names is an agreement with all_contrasts list
    lib.cellarray_to_array = @cellarray_to_array; % transforms 1D-cell array to array of numbers
    lib.cellarray2d_to_matrix = @cellarray2d_to_matrix; % transforms 2d-cell array to matrix of numbers
    lib.check_structure_field = @check_structure_field; % checks if a structure contains a required field
    lib.convert_to_cell_array = @convert_to_cell_array; % checks if input is a cell array and converts to cell array if it is not
    lib.find_key = @find_key; % checks if a key exists in a (cell) array
    lib.check_contrast_list = @check_contrast_list; % checks if the elements in the list are ordered according to the short_list
    lib.convert_iCFI = @convert_iCFI; % converts char input for covariate interactions (iCFI) to SPM readable number_id
    lib.convert_iCC = @convert_iCC; % converts char input for covariate centering (iCC) to SPM readable number_id
    lib.convert_design_type = @convert_design_type; % converts design type of second level analysis to number_id
    lib.convert_variance_setting = @convert_variance_setting; % converts variance setting of the design to number_id
    lib.get_index = @get_index; % get the row and/or column index of cell containing the first match for a regular expression
    lib.save_log = @save_log; % save the console output (options 'start'/'stop', 'output_path')

    function subject_dirs = get_subject_dirs(input_dir) % returns a cell array of all sub-directories of the input directory
        all_files = dir(input_dir);
        dir_flags = [all_files.isdir];
        subfolders = all_files(dir_flags);
        subject_dirs = {subfolders(3:end).name};
    end

    function out_dirs = get_valid_subdirs(input_dir, regexpr, case_insensitivity_flag) % returns subdirectories which comply with a specified regular expression
        %case_insensitivity_flag = 0 (case sensitive) | 1 (case insensitive)
        out_dirs = [];
        all_dirs = get_subject_dirs(input_dir);
        for dir_idx = 1:length(all_dirs)
            if nargin < 3 || case_insensitivity_flag == 0
                if ~isempty(regexp(all_dirs{dir_idx},regexpr,'match'))
                    out_dirs = [out_dirs; fullfile(input_dir, all_dirs(dir_idx))];
                end
            elseif case_insensitivity_flag == 1
                if ~isempty(regexpi(all_dirs{dir_idx},regexpr,'match'))
                    out_dirs = [out_dirs; fullfile(input_dir, all_dirs(dir_idx))];
                end
            else
                warning('Regexp command skipped because case_insensitivity_flag not set correctly (0|1).');
            end
        end
    end

    function dirs = get_data_dirs(input_directory) % gets all subfolders of input_dir which contain files (the data)
        dirs = regexp(genpath(input_directory),['[^;]*'],'match'); %genpath creates a ';'-separated text with all (sub-)folders -> separation in cells via regexp
        dirs(1) = [];
        for i = length(dirs):-1:1
            t = false;
            subdir = dir(dirs{i});
            for j = 1:length(subdir)
                if t, break; end
                if ~isfolder(fullfile(subdir(j).folder, subdir(j).name))
                    t = true;
                end
                if j == length(subdir) && t == false
                    dirs(i) = [];
                end
            end
        end
    end

    function file_names = get_file_names(folder, regexpr) % returns all files in a directory which comply with a regular expression
        dir_files = dir(folder);
        files = {dir_files.name};
        files_regexpr = regexp(files, regexpr);
        bool_mask = [];
        for i = 1:length(files_regexpr)
            if isempty(files_regexpr{i})
                bool_mask = [bool_mask, 0];
            else
                bool_mask = [bool_mask, files_regexpr{i}];
            end
            bool_mask = logical(bool_mask);
        end
        file_names = files(bool_mask);
    end

    function Outfiles=recursdir(baseDir,searchExpression)
    % OUTFILES = RECURSDIR(BASEDIRECTORY,SEARCHEXPRESSION)
    % A recursive search to find files that match the search expression
    %
    % Inputs:   BASEDIRECTYORY = root directory for the search
    %           SEARCHEXPRESSION = a regular expression used to locate the
    %                               desired file.
    %
    % Outputs:  OUTFILES = a cell containing the output files from the search
    %
    % Author: Jason J. Smoker
    % Created: November 25, 2014
    dstr = dir(baseDir);%search current directory and put results in structure
    Outfiles = {};
    for II = 1:length(dstr)
        if ~dstr(II).isdir && ~isempty(regexp(dstr(II).name,searchExpression,'match'))
            Outfiles{length(Outfiles)+1} = fullfile(baseDir,dstr(II).name);
        elseif dstr(II).isdir && ~strcmp(dstr(II).name,'.') && ~strcmp(dstr(II).name,'..')%if it is a directory(and not current or up a level), search in that
            pname = fullfile(baseDir,dstr(II).name);
            OutfilesTemp=recursdir(pname,searchExpression);
            if ~isempty(OutfilesTemp)
                Outfiles((length(Outfiles)+1):(length(Outfiles)+length(OutfilesTemp))) = OutfilesTemp;
            end
        end
    end
    end

    function Outfolders=recursdir_folder(baseDir,searchExpression)
        % OUTFOLDERS = RECURSDIR_FOLDER(BASEDIRECTORY,SEARCHEXPRESSION)
        % A recursive search to find folders that match the search expression
        %
        % Inputs:   BASEDIRECTYORY = root directory for the search
        %           SEARCHEXPRESSION = a regular expression used to locate the
        %                               desired sub-folder.
        %
        % Outputs:  OUTFOLDERS = a cell containing the output folders from the search
        %
        % Author of original script RECURSDIR: Jason J. Smoker
        % Created: November 25, 2014
        % Modified for folder output by Daniel Huber, August 23, 2024
        dstr = dir(baseDir);%search current directory and put results in structure
        Outfolders = {};
        for II = 1:length(dstr)
            if dstr(II).isdir && ~isempty(regexp(dstr(II).name,searchExpression,'match'))
                Outfolders{length(Outfolders)+1} = fullfile(baseDir,dstr(II).name);
            elseif dstr(II).isdir && ~strcmp(dstr(II).name,'.') && ~strcmp(dstr(II).name,'..')%if it is a directory(and not current or up a level), search in that
                pname = fullfile(baseDir,dstr(II).name);
                OutfoldersTemp=recursdir_folder(pname,searchExpression);
                if ~isempty(OutfoldersTemp)
                    Outfolders((length(Outfolders)+1):(length(Outfolders)+length(OutfoldersTemp))) = OutfoldersTemp;
                end
            end
        end
    end

    function validation_status = check_options(value, valid_options, var_name) % checks if a value is member of a list with valid options
        validation_status = true;
        options_string = '[';
        if isa(valid_options(1), 'double')
            for i = 1:length(valid_options)
                if i < length(valid_options)
                    options_string = [options_string, num2str(valid_options(i)), ', '];
                else 
                    options_string = [options_string, num2str(valid_options(i)), ']'];
                end    
            end
            if ~ismember(value, valid_options)
                validation_status = false;
                warning('Invalid value: %s has to be one of %s', var_name, options_string);
            end
        elseif isa(valid_options(1), 'cell')
            if isa(valid_options{1}, 'char')
                for i = 1:length(valid_options)
                    if i < length(valid_options)
                        options_string = [options_string, num2str(valid_options{i}), ', '];
                    else 
                        options_string = [options_string, num2str(valid_options{i}), ']'];
                    end
                end
                if ~ismember(lower(value), lower(valid_options))
                    validation_status = false;
                    warning('Invalid value: %s has to be one of %s', var_name, options_string);
                end
            end
        end
    end

    function validation_status = check_class(value, valid_type, var_name) % checks if the class of a field is valid
        validation_status = true;
        if ~isa(value, valid_type)
            validation_status = false;
            warning('Invalid class: %s has to be class %s', var_name, valid_type);
        end
    end
    
    function validation_status = check_type(value, valid_type, var_name) % checks if the type of a field is correct for processing
        validation_status = true;
        if ~isempty(value) %added after primary function checks
            if isa(value(1), 'cell')
                if ~all(cellfun(@(x) isa(x, valid_type), value))
                    validation_status = false;
                    warning('Invalid type: %s has to be class %s', var_name, valid_type);
                end
            else
                if ~isa(value(1), valid_type)
                    validation_status = false;
                    warning('Invalid type: %s has to be class %s', var_name, valid_type);
                end
            end
        end
    end

    function validation_status = check_type_weights(weight_matrix, var_name) % checks if the given weights have the correct format for processing
        validation_status = true;
        if class(weight_matrix) ~= "double"
            sym_vector = vpa(weight_matrix);
            try
                double(sym_vector);
            catch
                validation_status = false;
                warning('Invalid type: %s has to be class double or a convertible fraction (e.g. "1/3")', var_name);
            end
        end
    end

    function validation_status = check_dir(value, var_name) % checks if a valid directory is given
        validation_status = true;
        if ~isfolder(value)
            validation_status = false;
            warning('Invalid type: %s has to be a valid directory', var_name);
        end
    end

    function info = info_dir_exist(value, var_name) % checks if a directory already exists
        info = false;
        if isfolder(value)
            info = true;
            fprintf('The directory for %s already exists: %s\n', var_name, value);
        end
    end

    function validation_status = check_file(value, var_name) % checks if a valid file is given
        validation_status = true;
        if ~isfile(value)
            validation_status = false;
            warning('Invalid input: %s has to be a valid file', var_name);
        end
    end

    function validation_status = check_regexp(value, var_name) % checks if a valid regular expression is given
        validation_status = true;
        try regexpPattern(value);
        catch 
            validation_status = false;
            warning('Invalid type: %s has to be a regular expression', var_name);
        end
    end

    function validation_status = check_positive_number(value, var_name) % checks if a positive number is given
        validation_status = true;
        if ~isa(value, 'double')
            validation_status = false;
            warning('Invalid number: %s has to be a positive number', var_name);
        elseif value <= 0
            validation_status = false;
            warning('Invalid number: %s has to be positive', var_name);
        end
    end
    
    function validation_status = check_nonnegative_number(value, var_name) % checks if number is not negative
        validation_status = true;
        if ~isa(value, 'double')
            validation_status = false;
            warning('Invalid number: %s has to be a number >=0', var_name);
        elseif value < 0
            validation_status = false;
            warning('Invalid number: %s must not be negative', var_name);
        end
    end

    function validation_status = check_length(array, required_length, var_name) % checks if a vector or call array has the correct length
        validation_status = true;
        if length(array) ~= required_length
            validation_status = false;
            warning('Length mismatch: %s must have length %d', var_name, required_length);
        end
    end

    function validation_status = check_vector_length(vector, required_length, var_name) % checks if a 1d vector is given with the correct length
        validation_status = true;
        if check_length(vector, required_length, var_name)
            if min(size(vector)) > 1
                validation_status = false;
                warning('%s must be 1d vector', var_name);
            end
        end
    end

    function validation_status = check_same_length(array1, array2, var_name1, var_name2) % checks if two input arrays have the same length
        validation_status = true;
        if length(array1) ~= length(array2)
            validation_status = false;
            warning('%s and %s must have the same length', var_name1, var_name2);
        end
    end

    function [validation_status, non_matching_index] = check_cond_dim(matrix, required_length, var_name_1) % checks if dimensions of conditions matrix fits number of images and returns which index does NOT match
        validation_status = true;
        if ~(any(size(matrix) == required_length))
            validation_status = false;
            matching_index = nan;
            warning('Dimension mismatch: %s must have length %d', var_name_1, required_length);
        else
            if size(matrix, 1) == required_length
                non_matching_index = 2;
            else
                non_matching_index = 1;
            end
        end
    end

    function validation_status = check_matching_indices(act_matching_index, prev_matching_index, act_cond_array, prev_cond_array, var_name) % checks if all subjects have the same number of conditions 
        validation_status = true;
        if size(act_cond_array, act_matching_index) ~= size(prev_cond_array, prev_matching_index)
            validation_status = false;
            warning('Dimensions of %s do not match the conditions of the previous subject', var_name);
        end
    end

    function validation_status = check_arrays(array1, array2, var_name1, var_name2) % checks if arrays have the same lengths
        validation_status = true;
        if length(array1) ~= length(array2)
            validation_status = false;
            warning('Array mismatch: %s and %s must have same length', var_name1, var_name2);
        end
    end

    function validation_status = check_array_size(array_1, array_2, var_name_1, var_name_2) % checks if two arrays match in size (as is or transposed)
        validation_status = true;
        if ~(all(size(array_1) == size(array_2)) || all(size(array_1) == size(array_2')))
            validation_status = false;
            warning('Dimension mismatch of arrays %s and %s', var_name_1, var_name_2);
        end
    end

    function validation_status = check_size(array, req_rows, req_cols, var_name) % checks if array dimensions are correct
        validation_status = true;
        if ~(all(size(array) == [req_rows, req_cols]))
            validation_status = false;
            warning('Dimension mismatch: array %s must have %d rows and %d columns', var_name, req_rows, req_cols);
        end
    end

    function validation_status = check_matrix(array, matrix, array_name, matrix_name) % checks if matrix dimension corresponds to array
        validation_status = true;
        if isa(matrix, 'cell')
            if ~all(cellfun(@length, matrix))
                validation_status = false;
                warning('Dimension mismatch: rows of %s have different lenghts', matrix_name);
            else
                if length(array) ~= length(matrix{1})
                    validation_status = false;
                    warning('Dimension mismatch: %s and %s must have same length', array_name, matrix_name);
                end
            end
        %if any(cellfun(@iscell, matrix))
        else    
            if length(array) ~= size(matrix, 2)
                validation_status = false;
                warning('Dimension mismatch: %s and %s must have same length', array_name, matrix_name);
            end
        end
    end

    function validation_status = check_file_type(value, regexpr, var_name) % checks if file is correct file type
        validation_status = true;
        if check_file(value, var_name) == true
            if isempty(regexp(value, regexpr, 'match'))
                validation_status = false;
                warning('Unsupported file type: %s must satisfy regexp %s', var_name, regexpr);
            end
        else
            validation_status = false;
            %warning('Invalid type: %s has to be a valid file', var_name);
        end
    end

    function validation_status = check_file_name(value, regexpr, var_name) % checks if file name is compatible with a regular expression
        validation_status = true;
        if isempty(regexp(value, regexpr, 'match'))
            validation_status = false;
            warning('Unsupported file name: %s must satisfy regexp %s', var_name, regexpr);
        end
    end

    function replicate_over_sessions = get_ReplicateOverSessions(input) % gives SPM readable variable for ReplicateOverSessions option
        if any(regexp(strtrim(lower(input)), '^dont.*replicate$')) || lower(input) == "none" % option 'Dont replicate'
            replicate_over_sessions = 'none';
        elseif lower(input) == "replicate" || lower(input) == "repl" % option 'Replicate'
            replicate_over_sessions = 'repl';
        elseif any(regexp(strtrim(lower(input)), '^replicate.*scale$')) || lower(input) == "replsc" % option 'Replicate&Scale'
            replicate_over_sessions = 'replsc';
        elseif any(regexp(strtrim(lower(input)), '^create.*session$')) || lower(input) == "sess" % option 'Create per session'
            replicate_over_sessions = 'sess';
        elseif any(regexp(strtrim(lower(input)), '^both.*replicate.*scale.*session$')) || lower(input) == "bothsc" % option: 'Both: Replicate&Scale + Create per session'
            replicate_over_sessions = 'bothsc';
        elseif any(regexp(strtrim(lower(input)), '^both.*replicate.*session$')) || lower(input) == "both" % option 'Both: Replicate + Create per session'
            replicate_over_sessions = 'both';
        else
            warning('Unsupported input for Nodes.Model.Software.SPM.ReplicateOverSessions');
        end
    end

    function validation_status = check_order(array1, array2) % checks if elements of contrasts are correctly sorted with respect to conditions
        %code works for length(array1) <= length(array2)
        validation_status = true;
        for i = 1:length(array1)
            if isa(array2(i), 'char')
                if string(array1{i}) ~= string(array2(i))
                    validation_status = false;
                    warning('Elements of array do not correspond: %s <-> %s', array1{i}, array2(i));
                end
            elseif isa(array2(i), 'cell')
                if string(array1{i}) ~= string(array2{i})
                    validation_status = false;
                    warning('Elements of array do not correspond: %s <-> %s', array1{i}, array2{i});
                end
            end
        end
    end

    function validation_status = check_virtual_folder(folder, regexpr, var_name) % checks if a folder does not contain illeagal characters (which are given by regular expression)
        validation_status = true;
        if ~isempty(regexp(folder(3:end), regexpr, 'match')) % (3:end) -> exclude drive at start of the path
            validation_status = false;
            warning('Folder definition for %s seems to be incorrect: %s', var_name, folder);
        end
    end

    function validation_status = check_name_validity(name, names_list, type) % checks if a contrast name is unique ignoring capitalisation
        validation_status = true;
        if ismember(lower(name), lower(names_list))
            validation_status = false;
            warning('Duplicated name: %s; %s names must be unique', name, type);
        end
    end

    function validation_status = check_contrast_condition_list(condition_list, x_list) % checks if the contrast Condition.List is in agreement with X
        validation_status = true;
        if isempty(x_list)
            warning('Predictors list X is empty.');
        else
            for i = 1:length(condition_list)
                if ~any(cellfun(@(x)isequal(x,condition_list{i}), x_list))
                    validation_status = false;
                    warning('Contrast condition %s is not in predictors list X', condition_list{i});
                end
            end
        end
    end

    function validation_status = check_hrf_variables(variables_list, var_list) % checks if the HRF variables are in agreement with X
        validation_status = true;
        for i = 1:length(variables_list)
            if isempty(var_list)
                validation_status = false;
                warning('Predictors list X is empty, while HRF.Variables is not.'); 
            else
                if ~any(cellfun(@(x)isequal(x,variables_list{i}), var_list))
                    validation_status = false;
                    warning('HRF variable %s is not in predictors list X', variables_list{i});
                end
            end
        end
    end

    function validation_status = check_subject_id(subject_id, all_participants, var_name) % checks if the array subject_id is in agreement with the all_participants list
        validation_status = true;
        if isempty(all_participants)
            warning('The participants list is empty.');
        else
            for i = 1:length(subject_id)
                if ~any(cellfun(@(x)isequal(x,subject_id{i}), all_participants))
                    validation_status = false;
                    warning('%s: Subject %s is not in the participants list', var_name, subject_id{i});
                end
            end
        end
    end

    function validation_status = check_contrast_name(contrast_names, all_contrasts) % checks if the array contrast_names is an agreement with all_contrasts list
        validation_status = true;
        if isempty(all_contrasts)
            warning('The all_contrasts list is empty.');
        else
            for i = 1:length(contrast_names)
                if ~any(cellfun(@(x)isequal(x,contrast_names{i}), all_contrasts))
                    validation_status = false;
                    warning('Contrast %s is not in defined in the first level node', contrast_names{i});
                end
            end
        end
    end

    function array_out = cellarray_to_array(cell_array_1d) % transforms 1D-cell array to array of numbers
        array_out = [];
        for i = 1:length(cell_array_1d)
            if isa(cell_array_1d{i}, 'char')
                array_out(i) = str2num(cell_array_1d{i});
            else
                array_out(i) = cell_array_1d{i};
            end
            array_out = array_out';
        end
    end

    function matrix_out = cellarray2d_to_matrix(cell_array_2d) % transforms 2d-cell array to matrix of numbers
        matrix_out = [];
        for i = 1:length(cell_array_2d)
            if isa(cell_array_2d{i}, 'cell')
                matrix_out = [matrix_out, cellarray_to_array(cell_array_2d{i})'];
            else
                matrix_out = [matrix_out, cell_array_2d{i}];
            end
        end
        matrix_out = matrix_out';
    end

    function validation_status = check_structure_field(structure, req_field_name, source) % checks if a structure contains a required field
        validation_status = true;
        if ~isfield(structure, req_field_name)
            validation_status = false;
            warning('Required field missing: "%s" has to be included in %s', req_field_name, source);
        end
    end

    function output_cell_array = convert_to_cell_array(input) % checks if input is a cell array and converts to cell array if it is not
        if ~isempty(input)
            output_cell_array = cell(1, length(input));
            if ~iscell(input)
                for i = 1:length(input)
                    output_cell_array{i} = input(i);
                end
            else
                for i = 1:length(input)
                    output_cell_array{i} = input{i};
                end
            end
        end
    end

    function valid_key = find_key(input, key) % checks if a key is present in a (cell) array
        if iscell(input)
            valid_key = isfield(input{1}, key);
        else
            valid_key = isfield(input, key);
        end
    end

    function validation_status = check_contrast_list(list, short_list) % checks if the elements in the list are ordered according to the short_list
        validation_status = true;
        for i = 1:size(list, 2)
            if mod(i, length(short_list)) == 0
                comp_idx = length(short_list);
            else
                comp_idx = mod(i, length(short_list));
            end
            if string(list{1, i}) ~= string(short_list{comp_idx})
                validation_status = false;
                warning('The contrasts of %s do not match the first subject.', list{2, i});
            end
        end
    end

    function number_id = convert_iCFI(input) % converts char input for covariate interactions (iCFI) to SPM readable number_id
        if lower(input) == "none" % option 'None'
            number_id = 1;
        elseif any(regexp(strtrim(lower(input)), '^with.*factor.*1$')) || any(regexp(strtrim(lower(input)), '^factor.*1$')) || any(regexp(strtrim(lower(input)), '^with.*factor.*one$')) || any(regexp(strtrim(lower(input)), '^factor.*one$')) % option 'With Factor 1'
            number_id = 2;
        elseif any(regexp(strtrim(lower(input)), '^with.*factor.*2$')) || any(regexp(strtrim(lower(input)), '^factor.*2$')) || any(regexp(strtrim(lower(input)), '^with.*factor.*two$')) || any(regexp(strtrim(lower(input)), '^factor.*two$')) % option 'With Factor 2'
            number_id = 3;
        elseif any(regexp(strtrim(lower(input)), '^with.*factor.*3$')) || any(regexp(strtrim(lower(input)), '^factor.*3$')) || any(regexp(strtrim(lower(input)), '^with.*factor.*three$')) || any(regexp(strtrim(lower(input)), '^factor.*three$')) % option 'With Factor 3'
            number_id = 4;
        else
            warning('Unsupported input for Nodes.Transformations.Instructions.Input.Covariates.Interactions');
            fprintf('Valid input options: None|With Factor 1|With Factor 2|With Factor 3\n');
            number_id = nan;
        end
    end

    function number_id = convert_iCC(input) % converts char input for covariate centering (iCC) to SPM readable number_id
        if any(regexp(strtrim(lower(input)), '^overall.*mean$')) % option 'Overall mean'
            number_id = 1;
        elseif any(regexp(strtrim(lower(input)), '^factor.*1.*mean$')) || any(regexp(strtrim(lower(input)), '^factor.*one.*mean$')) % option 'Factor 1 mean'
            number_id = 2;
        elseif any(regexp(strtrim(lower(input)), '^factor.*2.*mean$')) || any(regexp(strtrim(lower(input)), '^factor.*two.*mean$')) % option 'Factor 2 mean'
            number_id = 3;
        elseif any(regexp(strtrim(lower(input)), '^factor.*3.*mean$')) || any(regexp(strtrim(lower(input)), '^factor.*three.*mean$')) % option 'Factor 3 mean'
            number_id = 4;
        elseif any(regexp(strtrim(lower(input)), '^no.*centering$')) || lower(input) == "none" % option 'No centering'
            number_id = 5;
        elseif any(regexp(strtrim(lower(input)), '^user.*value$')) || any(regexp(strtrim(lower(input)), '^user.*specified$')) % option 'User specified value'
            number_id = 6;
        elseif lower(input) == "as implied by ancova" || lower(input) == "as_implied_by_ancova" || lower(input) == "ancova" % option 'As implied by ANCOVA'
            number_id = 7;
        elseif lower(input) == "gm" % option 'GM'
            number_id = 8;
        else
            warning('Unsupported input for Nodes.Transformations.Instructions.Input.Covariates.Centering');
            fprintf('Valid input options: Overall mean|Factor 1 mean|Factor 2 mean|Factor 3 mean|No centering|User specified value|As implied by ANCOVA|GM\n');
            number_id = nan;
        end
    end

    function number_id = convert_design_type(input) % converts design type of second level analysis to number_id
        if any(regexp(strtrim(lower(input)), '^one.*t.*test$')) % option OneSampleTTest
            number_id = 1;
        elseif any(regexp(strtrim(lower(input)), '^two.*t.*test$')) % option TwoSampleTTest
            number_id = 2;
        elseif any(regexp(strtrim(lower(input)), '^paired.*t.*test$')) % option PairedTTest
            number_id = 3;
        elseif any(regexp(strtrim(lower(input)), '^multi.*regression$')) || any(regexp(strtrim(lower(input)), '^multi.*reg$')) % option MultipleRegression
            number_id = 4;
        elseif any(regexp(strtrim(lower(input)), '^one.*way.*anova$')) % option OneWayANOVA
            number_id = 5;
        elseif any(regexp(strtrim(lower(input)), '^one.*way.*anova.*subject$')) || any(regexp(strtrim(lower(input)), '^one.*way.*anova.*subj$')) || any(regexp(strtrim(lower(input)), '^one.*way.*anova.*sub$')) % option OneWayANOVA_WithinSubject
            number_id = 6;
        elseif any(regexp(strtrim(lower(input)), '^full.*factorial$')) || any(regexp(strtrim(lower(input)), '^full.*fact$')) % option FullFactorial
            number_id = 7;
        elseif any(regexp(strtrim(lower(input)), '^flex.*factorial$')) || any(regexp(strtrim(lower(input)), '^flex.*fact$')) % option FlexibleFactorial
            number_id = 8;
        else
            warning('Unsupported input for Nodes.Transformations.Instructions.Input.Design.Type');
            fprintf('Valid input options: OneSampleTTest|TwoSampleTTest|PairedTTest|MultipleRegression|OneWayANOVA|OneWayANOVA_WithinSubject|FullFactorial|FlexibleFactorial\n');
            number_id = nan;
        end
    end

    function number_id = convert_variance_setting(input) % converts variance setting of the design to number_id
        if lower(input) == "equal"
            number_id = 0;
        elseif lower(input) == "unequal"
            number_id = 1;
        else
            warning('Unsupported input for Nodes.Transformations.Instructions.Input.Design..Variance');
            fprintf('Valid input options: equal|unequal\n');
            number_id = nan;
        end
    end

    function idx = get_index(cell_array, regexpr, search_direction, fixed_index) % get the row and/or column index of cell containing the first match for a regular expression
    % search direction defines if the array is searched row by row ('r') or
    % column by column ('c')
        idx = nan;
        if nargin < 3
            error('Not enough input arguments');
        elseif nargin == 3
            flag = 0;
            if search_direction == "r"
                for i = 1:size(cell_array, 1)
                    for j = 1:size(cell_array, 2)
                        if isa(cell_array{i, j}, 'char')
                            if regexp(cell_array{i, j}, regexpr, 'once')
                                idx = [i, j];
                                flag = 1;
                                break;
                            end
                        end
                    end
                    if flag == 1
                        break;
                    end
                end
            elseif search_direction == "c"
                for j = 1:size(cell_array, 2)
                    for i = 1:size(cell_array, 1)
                        if isa(cell_array{i, j}, 'char')
                            if regexp(cell_array{i, j}, regexpr, 'once')
                                idx = [i, j];
                                flag = 1;
                                break;
                            end
                        end
                    end
                    if flag == 1
                        break;
                    end
                end
            else
                error('Invalid input for search direction (must be "r" for row-by-row search, "c" for column-by-column search)');
            end
        elseif nargin == 4
            if search_direction == "c"
                for i = 1:size(cell_array, 1)
                    if isa(cell_array{i, fixed_index}, 'char')
                        if regexp(cell_array{i, fixed_index}, regexpr, 'once')
                            idx = i;
                            break;
                        end
                    end
                end
            elseif search_direction == "r"
                for i = 1:size(cell_array, 2)
                    if isa(cell_array{fixed_index, i}, 'char')
                        if regexp(cell_array{fixed_index, i}, regexpr, 'once')
                            idx = i;
                            break;
                        end
                    end
                end
            else
                error('Invalid input for search direction (must be "r" for row-by-row search, "c" for column-by-column search)');
            end  
        else
            error('Too many input arguments');
        end
        if isnan(idx)
            warning('No matching entry found in the cell array.');
        end
    end

    function save_log(option, file_path) % save the console output (options 'start'/'stop', 'output_path')
        if nargin == 0 || nargin > 2
            error('Invalid number of input arguments. Use save_log("start"|"stop", optional "output_path")');
        elseif nargin == 2
            out_path = file_path;
            [path, ~, ~] = fileparts(out_path);
            if ~isfolder(path)
                error('Logfile path must contain a valid directory');
            end
        else
            out_path = fullfile(pwd, 'matlab_log.txt');
        end
        if option == "start"
            diary(out_path);
        elseif option == "stop"
            diary('off');
        else
            error('Invalid options: use "start" or "stop".');
        end
    end

end