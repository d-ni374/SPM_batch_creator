function output = get_paths_lv2(nodes, node_idx, task, validate_lv1, validate_lv2)
    % This function gets the input paths of the first level contrast files for 
    % the second level analysis. It validates the input data and covariates
    % and applies global calculations if specified by the user. Filters are
    % applied to remove missing data.
    % called from json_validator_bids_values.m
    % This script calls the following functions:
    % - get_contrast_file_paths.m
    % - get_subject_file_paths.m
    % - get_covariates.m
    % - apply_filters_con_cov.m
    % - apply_filters_con_cov_2.m
    % - expand_cov_array.m
    % - expand_global_calc_array.m
    % - filter_global_calculation.m
    % - filter_global_calculation_pairs.m
    % - assign_global_calc_values.m
    % - reshape_pairs.m
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % initialize output
    output = validate_lv2;

    validation_status = validate_lv2.validation_status;
    factorial_design_idx = validate_lv2.factorial_design_idx;
    design_type = validate_lv2.design_type;
    fmri_model_idx = validate_lv1.fmri_model_idx;
    find_design_def_instr = cellfun(@(x) x.Name == "factorial_design_specification", [nodes{node_idx}.Transformations.Instructions]);
    fprintf('Design type: %d\n', design_type);

    % find input folders for design definition (e.g. folders with contrast images)
    first_lv_node_idx = validate_lv1.first_lv_node_idx;
    input_dir_main = nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory;
    input_dirs = cell(1, length(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID));
    for sub_idx = 1:length(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID)
        % first level output directory is currently defined as output_directory/sub_id/task (could be changed to output_directory/task/sub_id -> must be changed accordingly in define_model.m):
        input_dirs{sub_idx} = fullfile(input_dir_main, nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{sub_idx}, task);
    end

    if any(find_design_def_instr)
        switch design_type
            case 1 % 'OneSampleTTest'
                % check availability of contrast files for the participants of the study
                input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans.InputFileType);
                if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans, 'InputFilterRegexp')
                    input_filter_regexp_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp;
                else
                    input_filter_regexp_ = '';
                end
                contrasts_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess;
                if isempty(contrasts_to_process)
                    error('No contrasts have been chosen for second level analysis. Insert contrast names in the json file.');
                end
                output.contrasts_to_process = contrasts_to_process;
                file_paths = get_contrast_file_paths(input_dirs, contrasts_to_process, input_file_type, input_filter_regexp_);
                validation_status = file_paths.validation_status && validation_status;
                %output.input_file_data = file_paths.data; % probably not needed (too much information)
                provisional.paths_array = file_paths.paths_array; % cell array with 1 line / participant & 1 column / contrast
                % validate user defined global calculation values
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    validation_status = fct_lib.check_vector_length(user_specified_values, length(validate_lv1.all_participant_ids), 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                % get and validate covariates for the participants of the study
                covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, validate_lv1.all_participant_ids, design_type);
                removed_indices = cell(1, size(provisional.paths_array, 2));
                % filter cell arrays for missing data (cons & covariates) and apply global calculation
                for con_idx = 1:size(provisional.paths_array, 2)
                    filtered_arrays = apply_filters_con_cov(provisional.paths_array(:, con_idx), covariates_array);
                    output.data(con_idx).paths_array = filtered_arrays.paths_array;
                    output.data(con_idx).covariates_array = filtered_arrays.cov_array;
                    removed_indices{con_idx} = filtered_arrays.removed_indices;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        global_calc_output = filter_global_calculation(user_specified_values, removed_indices{con_idx});
                        output.data(con_idx).global_calculation = global_calc_output.values;
                    end
                end
            case 2 % 'TwoSampleTTest'
                contrasts_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess;
                output.contrasts_to_process = contrasts_to_process;
                input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFileType);
                % input directories for group 1:
                subjects_group1 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1;
                n_subjects_group1 = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1);
                input_dirs_group1 = cell(1, n_subjects_group1);
                for sub_idx = 1:n_subjects_group1
                    % first level output directory is currently defined as output_directory/sub_id/task (could be changed to output_directory/task/sub_id -> must be changed accordingly in define_model.m):
                    input_dirs_group1{sub_idx} = fullfile(input_dir_main, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1{sub_idx}, task);
                end
                if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup1')
                    input_filter_regexp_group1_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1;
                else
                    input_filter_regexp_group1_ = '';
                end
                file_paths_group1 = get_contrast_file_paths(input_dirs_group1, contrasts_to_process, input_file_type, input_filter_regexp_group1_);
                validation_status = file_paths_group1.validation_status && validation_status;
                provisional.paths_array_group1 = file_paths_group1.paths_array; % cell array with 1 line / participant & 1 column / contrast
                %output.input_file_data_group1 = file_paths_group1.data; % probably not needed (too much information)
                % input directories for group 2:
                subjects_group2 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2;
                n_subjects_group2 = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2);
                input_dirs_group2 = cell(1, n_subjects_group2);
                for sub_idx = 1:n_subjects_group2
                    % first level output directory is currently defined as output_directory/sub_id/task (could be changed to output_directory/task/sub_id -> must be changed accordingly in define_model.m):
                    input_dirs_group2{sub_idx} = fullfile(input_dir_main, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2{sub_idx}, task);
                end
                if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup2')
                    input_filter_regexp_group2_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2;
                else
                    input_filter_regexp_group2_ = '';
                end
                file_paths_group2 = get_contrast_file_paths(input_dirs_group2, contrasts_to_process, input_file_type, input_filter_regexp_group2_);
                validation_status = file_paths_group2.validation_status && validation_status;
                provisional.paths_array_group2 = file_paths_group2.paths_array; % cell array with 1 line / participant & 1 column / contrast
                provisional.paths_array = [provisional.paths_array_group1; provisional.paths_array_group2]; % probably not needed
                %output.input_file_data_group2 = file_paths_group2.data; % probably not needed (too much information)
                % validate user defined global calculation values
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    required_length = n_subjects_group1 + n_subjects_group2;
                    validation_status = fct_lib.check_vector_length(user_specified_values, required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                % get and validate covariates for the participants of the study
                covariates_array_group1 = get_covariates(nodes, node_idx, task, factorial_design_idx, subjects_group1, design_type);
                covariates_array_group2 = get_covariates(nodes, node_idx, task, factorial_design_idx, subjects_group2, design_type);
                removed_indices_group1 = cell(1, size(provisional.paths_array_group1, 2));
                removed_indices_group2 = cell(1, size(provisional.paths_array_group2, 2));
                % filter cell arrays for missing data (cons & covariates) and apply global calculation
                for con_idx = 1:size(provisional.paths_array_group1, 2)
                    filtered_arrays_group1 = apply_filters_con_cov(provisional.paths_array_group1(:, con_idx), covariates_array_group1);
                    filtered_arrays_group2 = apply_filters_con_cov(provisional.paths_array_group2(:, con_idx), covariates_array_group2);
                    output.data(con_idx).paths_array_group1 = filtered_arrays_group1.paths_array;
                    output.data(con_idx).paths_array_group2 = filtered_arrays_group2.paths_array;
                    output.data(con_idx).covariates_array_group1 = filtered_arrays_group1.cov_array;
                    output.data(con_idx).covariates_array_group2 = filtered_arrays_group2.cov_array;
                    output.data(con_idx).covariates_array = [filtered_arrays_group1.cov_array; filtered_arrays_group2.cov_array];
                    removed_indices_group1{con_idx} = filtered_arrays_group1.removed_indices;
                    removed_indices_group2{con_idx} = filtered_arrays_group2.removed_indices;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        global_calc_output_group1 = filter_global_calculation(user_specified_values(1:n_subjects_group1), removed_indices_group1{con_idx});
                        global_calc_output_group2 = filter_global_calculation(user_specified_values(n_subjects_group1+1:end), removed_indices_group2{con_idx});
                        output.data(con_idx).global_calculation = [global_calc_output_group1.values; global_calc_output_group2.values];
                    end
                end
            case 3 % 'PairedTTest'
                % validate user defined global calculation values
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    % calculate required length for user specified values
                    global_calc_required_length_ = [];
                    for k = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans)
                        subjects1 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.Subjects1;
                        global_calc_required_length_ = [global_calc_required_length_, 2 * length(subjects1)];
                    end
                    global_calc_required_length = sum(global_calc_required_length_);
                    validation_status = fct_lib.check_vector_length(user_specified_values, global_calc_required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                % get and validate contrast images and covariates for the participants of the study
                removed_indices = cell(1, length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans));
                for k = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans)
                    contrasts1 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.Contrasts1;
                    contrasts2 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.Contrasts2;
                    subjects1 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.Subjects1;
                    subjects2 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.Subjects2;
                    input_file_type1 = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFileType1);
                    input_file_type2 = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFileType2);
                    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}, 'InputFilterRegexp1') && ...
                        iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFilterRegexp1) && ...
                        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFilterRegexp1{1})
                        input_filter_regexp1 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFilterRegexp1;
                    else
                        input_filter_regexp1 = cell(1, length(contrasts1));
                        input_filter_regexp1(1,:) = {''};
                    end
                    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}, 'InputFilterRegexp2') && ...
                        iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFilterRegexp2) && ...
                        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFilterRegexp2{1})
                        input_filter_regexp2 = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans{k}.InputFilterRegexp2;
                    else
                        input_filter_regexp2 = cell(1, length(contrasts2));
                        input_filter_regexp2(1,:) = {''};
                    end
                    input_dirs1 = cell(1, length(subjects1));
                    input_dirs2 = cell(1, length(subjects2));
                    for i = 1:length(subjects1)
                        input_dirs1{i} = fullfile(input_dir_main, subjects1{i}, task);
                        input_dirs2{i} = fullfile(input_dir_main, subjects2{i}, task);
                    end
                    pair_paths = struct('paths', {});
                    sub_list_pairs = cell(2 * length(contrasts1) * length(subjects1), 1);
                    path_list_pairs = cell(2 * length(contrasts1) * length(subjects1), 1);
                    pair_idx = 1;
                    for i = 1:length(subjects1)
                        for j = 1:length(contrasts1)
                            file_paths1 = get_contrast_file_paths(input_dirs1(i), contrasts1(j), input_file_type1, input_filter_regexp1{j});
                            validation_status = file_paths1.validation_status && validation_status;
                            input_file_data1 = file_paths1.data;
                            file_path_image1 = input_file_data1(1).contrast{1}.contrast_file_path;
                            file_paths2 = get_contrast_file_paths(input_dirs2(i), contrasts2(j), input_file_type2, input_filter_regexp2{j});
                            validation_status = file_paths2.validation_status && validation_status;
                            input_file_data2 = file_paths2.data;
                            file_path_image2 = input_file_data2(1).contrast{1}.contrast_file_path;
                            pair_paths(pair_idx).paths = {file_path_image1; file_path_image2};
                            pair_idx = pair_idx + 1;
                            sub_list_pairs{(i-1) * 2*length(contrasts1) + (j-1)*2 + 1} = subjects1{i};
                            sub_list_pairs{(i-1) * 2*length(contrasts1) + (j-1)*2 + 2} = subjects2{i};
                            path_list_pairs{(i-1) * 2*length(contrasts1) + (j-1)*2 + 1} = file_path_image1;
                            path_list_pairs{(i-1) * 2*length(contrasts1) + (j-1)*2 + 2} = file_path_image2;
                        end
                    end
                    provisional.pairs(k).paths = pair_paths;
                    % get re-strucured paths array for validation and output
                    paths_restructured = [provisional.pairs(k).paths(:).paths]'; % cell array with pairs in rows
                    % get and validate covariates for the participants of the study
                    covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, sub_list_pairs, design_type);
                    reshaped_cov_array = reshape_pairs(covariates_array); % reshapes the covariates array (pairs in rows)
                    % filter cell arrays for missing data (cons & covariates) and apply global calculation
                    filtered_arrays = apply_filters_con_cov(paths_restructured, reshaped_cov_array);
                    output.data(k).paths_array = filtered_arrays.paths_array;
                    output.data(k).covariates_array = filtered_arrays.cov_array;
                    removed_indices{k} = filtered_arrays.removed_indices;
                    if isempty(output.data(k).paths_array)
                        output.validation_status = false; % only relevant if the below line is changed to warning!
                        error('No data available for paired t-test input %d. Please check the input data.', k);
                    end
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        % assign the global calculation values to the respective pairs
                        reshaped_sub_list_pairs = reshape_pairs(sub_list_pairs);
                        if k == 1
                            starting_idx_input = 1;
                        else
                            starting_idx_input = sum(global_calc_required_length_(1:k-1)) + 1;
                        end
                        user_specified_values_input = user_specified_values(starting_idx_input:starting_idx_input + global_calc_required_length_(k) - 1);
                        global_calc_pairs = assign_global_calc_values(user_specified_values_input, reshaped_sub_list_pairs, length(contrasts1));
                        filtered_global_calc_values = filter_global_calculation_pairs(global_calc_pairs, removed_indices{k});
                        output.data(k).global_calculation = filtered_global_calc_values.values;
                    end
                end
                % validate user defined global calculation values
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    required_length = sum(global_calc_required_length);
                    validation_status = fct_lib.check_vector_length(user_specified_values, required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                output.contrasts_to_process = {}; % not applicable to paired t-test
            case 4 % 'MultipleRegression'
                input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans.InputFileType);
                if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans, 'InputFilterRegexp')
                    input_filter_regexp_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp;
                else
                    input_filter_regexp_ = '';
                end
                contrasts_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess;
                output.contrasts_to_process = contrasts_to_process;
                file_paths = get_contrast_file_paths(input_dirs, contrasts_to_process, input_file_type, input_filter_regexp_);
                validation_status = file_paths.validation_status && validation_status;
                provisional.paths_array = file_paths.paths_array; % cell array with 1 line / participant & 1 column / contrast
                % validate user defined global calculation values
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    validation_status = fct_lib.check_vector_length(user_specified_values, length(validate_lv1.all_participant_ids), 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                % get and validate covariates for the participants of the study
                covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, validate_lv1.all_participant_ids, design_type);
                removed_indices = cell(1, size(provisional.paths_array, 2));
                % filter cell arrays for missing data (cons & covariates) and apply global calculation
                for con_idx = 1:size(provisional.paths_array, 2)
                    filtered_arrays = apply_filters_con_cov(provisional.paths_array(:, con_idx), covariates_array);
                    output.data(con_idx).paths_array = filtered_arrays.paths_array;
                    output.data(con_idx).covariates_array = filtered_arrays.cov_array;
                    removed_indices{con_idx} = filtered_arrays.removed_indices;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        global_calc_output = filter_global_calculation(user_specified_values, removed_indices{con_idx});
                        output.data(con_idx).global_calculation = global_calc_output.values;
                    end
                end
            case 5 % 'OneWayANOVA'
                global_calc_required_length_ = [];
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells)
                    input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.InputFileTypeGroup);
                    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}, 'InputFilterRegexpGroup')
                        input_filter_regexp_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.InputFilterRegexpGroup;
                    else
                        input_filter_regexp_ = '';
                    end
                    contrast_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.ContrastToProcess;
                    cell_length = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.Subject_ID);
                    input_dirs_group = cell(1, cell_length);
                    for sub_idx = 1:cell_length
                        input_dirs_group{sub_idx} = fullfile(input_dir_main, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.Subject_ID{sub_idx}, task);
                    end
                    file_paths_group = get_contrast_file_paths(input_dirs_group, {contrast_to_process}, input_file_type, input_filter_regexp_);
                    validation_status = file_paths_group.validation_status && validation_status;
                    global_calc_required_length_ = [global_calc_required_length_, cell_length];
                    provisional.cells(i).paths_array = file_paths_group.paths_array; % cell array with 1 line / participant & 1 column / contrast
                end
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    global_calc_required_length = sum(global_calc_required_length_);
                    validation_status = fct_lib.check_vector_length(user_specified_values, global_calc_required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                for i = 1:length(provisional.cells)
                    provisional.cells(i).covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.Subject_ID, design_type);
                    provisional.cells(i).filtered_arrays = apply_filters_con_cov(provisional.cells(i).paths_array, provisional.cells(i).covariates_array);
                    output.cells(i).paths_array = provisional.cells(i).filtered_arrays.paths_array;
                    output.cells(i).covariates_array = provisional.cells(i).filtered_arrays.cov_array;
                    provisional.cells(i).removed_indices = provisional.cells(i).filtered_arrays.removed_indices;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        if i == 1
                            starting_idx_input = 1;
                        else
                            starting_idx_input = sum(global_calc_required_length_(1:i-1)) + 1;
                        end
                        user_specified_values_input = user_specified_values(starting_idx_input:starting_idx_input + global_calc_required_length_(i) - 1); % values for respective cell
                        global_calc_output = filter_global_calculation(user_specified_values_input, provisional.cells(i).removed_indices);
                        output.cells(i).global_calculation = global_calc_output.values;
                    end
                end
                output.contrasts_to_process = {}; % not applicable to one-way ANOVA
            case 6 % 'OneWayANOVAWithinSubject'
                global_calc_required_length_ = [];
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects)
                    input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFileType);
                    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}, 'InputFilterRegexp')
                        input_filter_regexp_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFilterRegexp;
                    else
                        input_filter_regexp_ = '';
                    end
                    contrasts_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.ContrastsToProcess;
                    subject_scan_def_number = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.Subject_ID);
                    input_dirs_subjects = cell(1, subject_scan_def_number);
                    for sub_idx = 1:subject_scan_def_number
                        input_dirs_subjects{sub_idx} = fullfile(input_dir_main, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.Subject_ID{sub_idx}, task);
                    end
                    file_paths_subject = get_subject_file_paths(input_dirs_subjects, contrasts_to_process, input_file_type, input_filter_regexp_);
                    validation_status = file_paths_subject.validation_status && validation_status;
                    global_calc_required_length_ = [global_calc_required_length_, subject_scan_def_number];
                    %provisional.input_file_data_subjects{i} = file_paths_subject.data; % probably not needed (too much information)
                    provisional.subjects(i).paths_array = file_paths_subject.paths_array; % cell array with 1 line / participant & 1 column / contrast
                end
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    global_calc_required_length = sum(global_calc_required_length_);
                    validation_status = fct_lib.check_vector_length(user_specified_values, global_calc_required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                for i = 1:length(provisional.subjects)
                    provisional.subjects(i).covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.Subject_ID, design_type);
                    provisional.subjects(i).covariates_array = provisional.subjects(i).covariates_array'; % transpose covariates array
                    provisional.subjects(i).filtered_arrays = apply_filters_con_cov_2(provisional.subjects(i).paths_array, provisional.subjects(i).covariates_array);
                    output.subjects(i).paths_array = provisional.subjects(i).filtered_arrays.paths_array;
                    provisional.subjects(i).filtered_arrays.cov_array = expand_cov_array(provisional.subjects(i).filtered_arrays.cov_array, contrasts_to_process); % expand covariates array to match the number of contrasts per subject
                    output.subjects(i).covariates_array = provisional.subjects(i).filtered_arrays.cov_array;
                    provisional.subjects(i).removed_indices = provisional.subjects(i).filtered_arrays.removed_indices;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        if i == 1
                            starting_idx_input = 1;
                        else
                            starting_idx_input = sum(global_calc_required_length_(1:i-1)) + 1;
                        end
                        user_specified_values_input = user_specified_values(starting_idx_input:starting_idx_input + global_calc_required_length_(i) - 1); % values for respective cell
                        global_calc_output = filter_global_calculation(user_specified_values_input, provisional.subjects(i).removed_indices);
                        global_calc_output.values = expand_global_calc_array(global_calc_output.values, contrasts_to_process); % expand global calculation array to match the number of contrasts per subject
                        output.subjects(i).global_calculation = global_calc_output.values;
                    end
                end
                output.contrasts_to_process = {}; % not applicable to one-way ANOVA within subject
            case 7 % 'FullFactorial'
                global_calc_required_length_ = [];
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells)
                    input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.InputFileType);
                    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}, 'InputFilterRegexp')
                        input_filter_regexp_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.InputFilterRegexp;
                    else
                        input_filter_regexp_ = '';
                    end
                    contrast_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.ContrastToProcess;
                    cell_length = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.Subject_ID);
                    input_dirs_cells = cell(1, cell_length);
                    for sub_idx = 1:cell_length
                        input_dirs_cells{sub_idx} = fullfile(input_dir_main, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.Subject_ID{sub_idx}, task);
                    end
                    file_paths_cells = get_contrast_file_paths(input_dirs_cells, {contrast_to_process}, input_file_type, input_filter_regexp_);
                    validation_status = file_paths_cells.validation_status && validation_status;
                    global_calc_required_length_ = [global_calc_required_length_, cell_length];
                    %provisional.input_file_data_cells{i} = file_paths_cells.data; % probably not needed (too much information)
                    provisional.cells(i).paths_array = file_paths_cells.paths_array; % cell array with 1 line / participant & 1 column / contrast
                end
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    global_calc_required_length = sum(global_calc_required_length_);
                    validation_status = fct_lib.check_vector_length(user_specified_values, global_calc_required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                for i = 1:length(provisional.cells)
                    provisional.cells(i).covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.Subject_ID, design_type);
                    provisional.cells(i).filtered_arrays = apply_filters_con_cov(provisional.cells(i).paths_array, provisional.cells(i).covariates_array);
                    output.cells(i).paths_array = provisional.cells(i).filtered_arrays.paths_array;
                    output.cells(i).covariates_array = provisional.cells(i).filtered_arrays.cov_array;
                    provisional.cells(i).removed_indices = provisional.cells(i).filtered_arrays.removed_indices;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        if i == 1
                            starting_idx_input = 1;
                        else
                            starting_idx_input = sum(global_calc_required_length_(1:i-1)) + 1;
                        end
                        user_specified_values_input = user_specified_values(starting_idx_input:starting_idx_input + global_calc_required_length_(i) - 1); % values for respective cell
                        global_calc_output = filter_global_calculation(user_specified_values_input, provisional.cells(i).removed_indices);
                        output.cells(i).global_calculation = global_calc_output.values;
                    end
                end
                output.contrasts_to_process = {}; % not applicable to full factorial
            case 8 % 'FlexibleFactorial'
                global_calc_required_length_ = [];
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects)
                    input_file_type = lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFileType);
                    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}, 'InputFilterRegexp')
                        input_filter_regexp_ = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFilterRegexp;
                    else
                        input_filter_regexp_ = '';
                    end
                    contrasts_to_process = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.ContrastsToProcess;
                    subject_scan_def_number = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.Subject_ID);
                    input_dirs_subjects = cell(1, subject_scan_def_number);
                    for sub_idx = 1:subject_scan_def_number
                        input_dirs_subjects{sub_idx} = fullfile(input_dir_main, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.Subject_ID{sub_idx}, task);
                    end
                    file_paths_subjects = get_subject_file_paths(input_dirs_subjects, contrasts_to_process, input_file_type, input_filter_regexp_);
                    validation_status = file_paths_subjects.validation_status && validation_status;
                    global_calc_required_length_ = [global_calc_required_length_, subject_scan_def_number];
                    %provisional.input_file_data_subjects{i} = file_paths_subjects.data; % probably not needed (too much information)
                    provisional.subjects(i).paths_array = file_paths_subjects.paths_array; % cell array with 1 line / participant & 1 column / contrast
                end
                if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                    user_specified_values = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
                    global_calc_required_length = sum(global_calc_required_length_);
                    validation_status = fct_lib.check_vector_length(user_specified_values, global_calc_required_length, 'GlobalCalculations.UserSpecifiedValues') && validation_status;
                end
                for i = 1:length(provisional.subjects)
                    provisional.subjects(i).covariates_array = get_covariates(nodes, node_idx, task, factorial_design_idx, nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.Subject_ID, design_type);
                    provisional.subjects(i).covariates_array = provisional.subjects(i).covariates_array.'; % transpose covariates array
                    provisional.subjects(i).filtered_arrays = apply_filters_con_cov_2(provisional.subjects(i).paths_array, provisional.subjects(i).covariates_array);
                    provisional.subjects(i).filtered_arrays.cov_array = expand_cov_array(provisional.subjects(i).filtered_arrays.cov_array, contrasts_to_process); % expand covariates array to match the number of contrasts per subject
                    output.subjects(i).paths_array = provisional.subjects(i).filtered_arrays.paths_array;
                    output.subjects(i).covariates_array = provisional.subjects(i).filtered_arrays.cov_array;
                    provisional.subjects(i).removed_indices = provisional.subjects(i).filtered_arrays.removed_indices;
                    output.subjects(i).conditions = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.Conditions;
                    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
                        if i == 1
                            starting_idx_input = 1;
                        else
                            starting_idx_input = sum(global_calc_required_length_(1:i-1)) + 1;
                        end
                        user_specified_values_input = user_specified_values(starting_idx_input:starting_idx_input + global_calc_required_length_(i) - 1); % values for respective cell
                        global_calc_output = filter_global_calculation(user_specified_values_input, provisional.subjects(i).removed_indices);
                        global_calc_output.values = expand_global_calc_array(global_calc_output.values, contrasts_to_process); % expand global calculation array to match the number of contrasts per subject
                        output.subjects(i).global_calculation = global_calc_output.values;
                    end
                end
                output.contrasts_to_process = {}; % not applicable to flexible factorial
        end
    end

    output.validation_status = validation_status;
    output.design_type = validate_lv2.design_type;
    if isfield(validate_lv2, 'maineffinteract_lst')
        output.maineffinteract_lst = validate_lv2.maineffinteract_lst;
    end

end