function output = valid_bids_lv2_dm(nodes, validation_status, node_idx, all_participant_ids)
    % This function validates second level nodes prior to contrast definition;
    % called by json_validator_bids_values.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % Validate main section of the node
    validation_status = fct_lib.check_type(nodes{node_idx}.Name, 'char', 'Nodes.Name') && validation_status;
    if ~isempty(nodes{node_idx}.GroupBy)
        for i = 1:length(nodes{node_idx}.GroupBy)
            validation_status = fct_lib.check_type(nodes{node_idx}.GroupBy{i}, 'char', 'Nodes.GroupBy') && validation_status;
        end
    end

    % Model section
    validation_status = fct_lib.check_options(nodes{node_idx}.Model.Type, {'glm', 'meta'}, 'Nodes.Model.Type') && validation_status;
    for i = 1:length(nodes{node_idx}.Model.X)
        if nodes{node_idx}.Model.X{i} ~= 1 % the value of 1 is a shortcut for the constant term (BIDS), but is not supported within this software
            validation_status = fct_lib.check_type(nodes{node_idx}.Model.X{i}, 'char', 'Nodes.Model.X') && validation_status;
        else
            warning('Definition of Model.X: The value 1 as a shortcut for the constant term is not supported within this software.');
        end
    end

    % Transformations section
    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Transformer, 'char', 'Nodes.Transformations.Transformer') && validation_status;
    for h = 1:length(nodes{node_idx}.Transformations.Instructions)
        fprintf('Validating Instruction %d\n', h);
        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Name, 'char', 'Nodes.Transformations.Instructions.Name') && validation_status;
        if isfield(nodes{node_idx}.Transformations.Instructions{h}, 'Script')
            validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Script, 'char', 'Nodes.Transformations.Instructions.Script') && validation_status;
        end
        if isfield(nodes{node_idx}.Transformations.Instructions{h}, 'Output')
            validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Output, 'char', 'Nodes.Transformations.Instructions.Output') && validation_status;
        end
        if nodes{node_idx}.Transformations.Instructions{h}.Name == "factorial_design_specification" % NAME CAN BE CHANGED
            second_lv_node_idx = node_idx;
            factorial_design_idx = h;
            validation_status = fct_lib.check_dir(nodes{node_idx}.Transformations.Instructions{h}.Input.MainProjectFolder, sprintf('Nodes.Transformations.Instructions{%d}.Input.MainProjectFolder', h)) && validation_status;
            validation_status = fct_lib.check_virtual_folder(nodes{node_idx}.Transformations.Instructions{h}.Input.OutputDirectory, '[#<$+%>!`&*}{?" =@:|]', sprintf('Nodes.Transformations.Instructions{%d}.Input.OutputDirectory', h)) && validation_status;
            if ~fct_lib.info_dir_exist(nodes{node_idx}.Transformations.Instructions{h}.Input.OutputDirectory, sprintf('Nodes.Transformations.Instructions{%d}.Input.OutputDirectory', h))
                mkdir(nodes{node_idx}.Transformations.Instructions{h}.Input.OutputDirectory);
            end
            design_type = fct_lib.convert_design_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.Type);
            validation_status = ~isnan(design_type) && validation_status;
            switch design_type
                case 1 % 'OneSampleTTest'
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.InputFileType, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneSampleTTest.Scans.InputFileType', h)) && validation_status;
                    if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.InputFileType) == "other"
                        validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans, 'InputFilterRegexp', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneSampleTTest.Scans', h)) && validation_status;
                        if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans, 'InputFilterRegexp')
                            ContrastsToProcess_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess;
                            InputFilterRegexp_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp;
                            validation_status = fct_lib.check_same_length(InputFilterRegexp_array, ContrastsToProcess_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp', h), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess', h)) && validation_status;
                            for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp)
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp{i}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp{%d}', h, i)) && validation_status;
                            end
                        end
                    end
                case 2 % 'TwoSampleTTest'
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess', h)) && validation_status;
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1', h)) && validation_status;
                    validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFileType, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.InputFileType', h)) && validation_status;
                    if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFileType) == "other"
                        validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup1', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans', h)) && validation_status;
                        if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup1')
                            ContrastsToProcess_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess;
                            InputFilterRegexpGroup1_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1;
                            validation_status = fct_lib.check_same_length(InputFilterRegexpGroup1_array, ContrastsToProcess_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1', h), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess', h)) && validation_status;
                            for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1)
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1{i}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1{%d}', h, i)) && validation_status;
                            end
                        end
                    end
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2', h)) && validation_status;
                    validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2', h)) && validation_status;
                    if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFileType) == "other"
                        validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup2', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans', h)) && validation_status;
                        if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup2')
                            ContrastsToProcess_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess;
                            InputFilterRegexpGroup2_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2;
                            validation_status = fct_lib.check_same_length(InputFilterRegexpGroup2_array, ContrastsToProcess_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2', h), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess', h)) && validation_status;
                            for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2)
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2{i}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2{%d}', h, i)) && validation_status;
                            end
                        end
                    end
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Independence, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Independence', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Variance, {'equal', 'unequal'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.Variance', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.GrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.GrandMeanScaling', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.ANCOVA, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputTwoSampleTTest.ANCOVA', h)) && validation_status;
                case 3 % 'PairedTTest'
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans)
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFileType1, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.InputFileType1', h, i)) && validation_status;
                        contrasts1_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Contrasts1;
                        contrasts2_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Contrasts2;
                        if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFileType1) == "other"
                            validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}, 'InputFilterRegexp1', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans', h)) && validation_status;
                            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}, 'InputFilterRegexp1')
                                InputFilterRegexp1_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFilterRegexp1;
                                validation_status = fct_lib.check_same_length(InputFilterRegexp1_array, contrasts1_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp1', h), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.Contrasts1', h, i)) && validation_status;
                                for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFilterRegexp1)
                                    validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFilterRegexp1{j}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp1{%d}', h, j)) && validation_status;
                                end
                            end
                        end
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFileType2, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.InputFileType2', h)) && validation_status;
                        if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFileType2) == "other"
                            validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}, 'InputFilterRegexp2', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans', h)) && validation_status;
                            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}, 'InputFilterRegexp2')
                                InputFilterRegexp2_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFilterRegexp2;
                                validation_status = fct_lib.check_same_length(InputFilterRegexp2_array, contrasts2_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp2', h), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.Contrasts2', h, i)) && validation_status;
                                for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFilterRegexp2)
                                    validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.InputFilterRegexp2{j}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp2{%d}', h, j)) && validation_status;
                                end
                            end
                        end
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Subjects1, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.Subjects1', h)) && validation_status;
                        validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Subjects1, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.Subjects1', h)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Subjects2, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.Subjects2', h)) && validation_status;
                        validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Subjects2, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.Subjects2', h)) && validation_status;
                        subjects1_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Subjects1;
                        subjects2_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Subjects2;
                        validation_status = fct_lib.check_same_length(subjects1_array, subjects2_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.Subjects1', h, i), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.Subjects2', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Contrasts1, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.Contrasts1', h)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Contrasts2, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans.Contrasts2', h)) && validation_status;
                        validation_status = fct_lib.check_same_length(contrasts1_array, contrasts2_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.Contrasts1', h, i), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.Scans{%d}.Contrasts2', h, i)) && validation_status;
                    end
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.GrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.GrandMeanScaling', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.ANCOVA, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputPairedTTest.ANCOVA', h)) && validation_status;
                case 4 % 'MultipleRegression'
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.InputFileType, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans.InputFileType', h)) && validation_status;
                    if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.InputFileType) == "other"
                        validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans, 'InputFilterRegexp', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans', h)) && validation_status;
                        if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans, 'InputFilterRegexp')
                            ContrastsToProcess_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess;
                            InputFilterRegexp_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp;
                            validation_status = fct_lib.check_same_length(InputFilterRegexp_array, ContrastsToProcess_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp', h), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess', h)) && validation_status;
                            for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp)
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp{i}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp{%d}', h, i)) && validation_status;
                            end
                            validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp', h)) && validation_status;
                        end
                    end
                    if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates) && iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates) && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates{1}.Name)
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates)
                            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates{i}.Name)
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates{i}.CovariatesFileRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Covariates{%d}.CovariatesFileRegexp', h, i)) && validation_status;
                                validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates{i}.Name, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Covariates{%d}.Name', h, i)) && validation_status;
                                validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates{i}.ColName, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Covariates{%d}.ColName', h, i)) && validation_status;
                                centering_id = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Covariates{i}.Centering);
                                validation_status = ~isnan(centering_id) && validation_status;
                                if ~(centering_id == 1 | centering_id == 5)
                                    warning('Centering options are restricted to "Overall mean" and "No centering" according to SPM.');
                                end
                            end
                        end
                    end
                    clear centering_id;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Intercept, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputMultipleRegression.Intercept', h)) && validation_status;
                case 5 % 'OneWayANOVA'
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells)
                        validation_status = fct_lib.check_class(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.ContrastToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Cells{%d}.ContrastsToProcess', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.Subject_ID, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Cells{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.Subject_ID, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Cells{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.InputFileTypeGroup, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Cells{%d}.InputFileTypeGroup', h, i)) && validation_status;
                        if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.InputFileTypeGroup) == "other"
                            validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}, 'InputFilterRegexpGroup', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Cells{%d}', h, i)) && validation_status;
                            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}, 'InputFilterRegexpGroup')
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.InputFilterRegexpGroup, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Cells{%d}.InputFilterRegexpGroup', h, i)) && validation_status;
                            end
                        end
                    end
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Independence, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Independence', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Variance, {'equal', 'unequal'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.Variance', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.GrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.GrandMeanScaling', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.ANCOVA, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVA.ANCOVA', h)) && validation_status;
                case 6 % 'OneWayANOVAWithinSubject'
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects)
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.ContrastsToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.ContrastsToProcess', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.Subject_ID, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.Subject_ID, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFileType, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.InputFileType', h, i)) && validation_status;
                        if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFileType) == "other"
                            validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}, 'InputFilterRegexp', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}', h, i)) && validation_status;
                            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}, 'InputFilterRegexp')
                                ContrastsToProcess_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.ContrastsToProcess;
                                InputFilterRegexp_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFilterRegexp;
                                validation_status = fct_lib.check_same_length(InputFilterRegexp_array, ContrastsToProcess_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.InputFilterRegexp', h, i), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.ContrastsToProcess', h, i)) && validation_status;
                                for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFilterRegexp)
                                    validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFilterRegexp{j}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{%d}.InputFilterRegexp{%d}', h, i, j)) && validation_status;
                                end
                            end
                        end
                    end
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Independence, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Independence', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Variance, {'equal', 'unequal'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.Variance', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.GrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.GrandMeanScaling', h)) && validation_status;
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.ANCOVA, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputOneWayANOVAWithinSubject.ANCOVA', h)) && validation_status;
                case 7 % 'FullFactorial'
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors)
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors{i}.Name, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Factors{%d}.Name', h, i)) && validation_status;
                        validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors{i}.Levels, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Factors{%d}.Levels', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors{i}.Independence, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Factors{%d}.Independence', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors{i}.Variance, {'equal', 'unequal'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Factors{%d}.Variance', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors{i}.GrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Factors{%d}.GrandMeanScaling', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors{i}.ANCOVA, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Factors{%d}.ANCOVA', h, i)) && validation_status;
                    end
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells)
                        validation_status = fct_lib.check_class(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.ContrastToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.ContrastsToProcess', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.Subject_ID, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.Subject_ID, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.InputFileType, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.InputFileType', h, i)) && validation_status;
                        if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.InputFileType) == "other"
                            validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}, 'InputFilterRegexp', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}', h, i)) && validation_status;
                            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}, 'InputFilterRegexp')
                                validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.InputFilterRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.InputFilterRegexp', h, i)) && validation_status;
                            end
                        end
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.Levels, 'double', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.Levels', h, i)) && validation_status;
                        validation_status = fct_lib.check_length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.Levels, length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Factors), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.Cells{%d}.Levels', h, i)) && validation_status;
                    end
                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.GenerateContrasts, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFullFactorial.GenerateContrasts', h)) && validation_status;
                case 8 % 'FlexibleFactorial'
                    factors_lst = cell(length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors), 1);
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors)
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors{i}.Name, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Factors{%d}.Name', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors{i}.Independence, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Factors{%d}.Independence', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors{i}.Variance, {'equal', 'unequal'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Factors{%d}.Variance', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors{i}.GrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Factors{%d}.GrandMeanScaling', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors{i}.ANCOVA, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Factors{%d}.ANCOVA', h, i)) && validation_status;
                        factors_lst{i} = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Factors{i}.Name;
                    end
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects)
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.Subject_ID, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_subject_id(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.Subject_ID, all_participant_ids, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.Subject_ID', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.ContrastsToProcess, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.ContrastsToProcess', h, i)) && validation_status;
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFileType, {'con', 'ess', 'beta', 'other'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.InputFileType', h, i)) && validation_status;
                        if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFileType) == "other"
                            validation_status = fct_lib.check_structure_field(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}, 'InputFilterRegexp', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}', h, i)) && validation_status;
                            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}, 'InputFilterRegexp')
                                ContrastToProcess_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.ContrastsToProcess;
                                InputFilterRegexp_array = nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFilterRegexp;
                                validation_status = fct_lib.check_same_length(InputFilterRegexp_array, ContrastToProcess_array, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.InputFilterRegexp', h, i), sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.ContrastsToProcess', h, i)) && validation_status;
                                for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFilterRegexp)
                                    validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFilterRegexp{j}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.InputFilterRegexp{%d}', h, i, j)) && validation_status;
                                end
                            end
                        end
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.Conditions, 'double', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.Subjects{%d}.Conditions', h, i)) && validation_status;
                    end
                    maineffinteract_lst = {};
                    maineffinteract_index = 1;
                    for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions)
                        validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.Type, {'MainEffect', 'Interaction'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{%d}.Type', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{%d}.FactorNames', h, i)) && validation_status;
                        
                        if any(regexp(strtrim(lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.Type)), '^interaction'))
                            for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames)
                                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames{j}, factors_lst, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{%d}.FactorNames{%d}', h, i, j)) && validation_status;
                            end
                            validation_status = fct_lib.check_length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames, 2, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{%d}.FactorNames', h, i)) && validation_status;
                            maineffinteract_lst{maineffinteract_index} = {'Interaction', nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames};
                            maineffinteract_index = maineffinteract_index + 1;
                        elseif any(regexp(strtrim(lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.Type)), '^main.*effect'))
                            if isa(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames, 'cell')
                                for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames)
                                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames{j}, factors_lst, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{%d}.FactorNames{%d}', h, i, j)) && validation_status;
                                end
                                for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames)
                                    maineffinteract_lst{maineffinteract_index} = {'MainEffect', nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames{j}};
                                    maineffinteract_index = maineffinteract_index + 1;
                                end
                            else % in case that "FactorNames" is entered as a string
                                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames, factors_lst, sprintf('Nodes.Transformations.Instructions{%d}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{%d}.FactorNames', h, i)) && validation_status;
                                maineffinteract_lst{maineffinteract_index} = {'MainEffect', nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{i}.FactorNames};
                                maineffinteract_index = maineffinteract_index + 1;
                            end
                        end
                    end
                    output.factors_lst = factors_lst;
                    output.maineffinteract_lst = maineffinteract_lst;
            end
            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates) && iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates) && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{1}.Name)
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates)
                    if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{i}.Name)
                        validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{i}.CovariatesFileRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Covariates{%d}.CovariatesFileRegexp', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{i}.Name, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Covariates{%d}.Name', h, i)) && validation_status;
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{i}.ColName, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Covariates{%d}.ColName', h, i)) && validation_status;
                        interactions_id = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{i}.Interactions);
                        validation_status = ~isnan(interactions_id) && validation_status;
                        centering_id = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{h}.Input.Covariates{i}.Centering);
                        validation_status = ~isnan(centering_id) && validation_status;
                    end
                end
                clear interactions_id centering_id;
            end
            %{
            % TODO: delete this validation, since covariates are solely taken from participants.tsv
            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates) && iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates) && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{1}.Files)
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates)
                    if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Files)
                        for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Files)
                            validation_status = fct_lib.check_file_type(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Files{j},'.*(mat|txt)$', sprintf('Nodes.Transformations.Instructions{%d}.Input.MultipleCovariates{%d}.Files{%d}', h, i, j)) && validation_status;
                            multiple_covariates = load(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Files{j});
                            if ~isempty(regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Files{j},'.*mat$', 'match'))
                                %{
                                if isfield(multiple_covariates, 'names') && isfield(multiple_covariates, 'R')
                                    for k = 1:length(multiple_covariates.names)
                                        predictors_list{predictors_list_index} = ['Sn(1)', multiple_covariates.names{k}];
                                        predictors_list_index = predictors_list_index + 1;
                                    end
                                elseif isfield(multiple_covariates, 'R')
                                    for k = 1:size(multiple_covariates.R, 2)
                                        predictors_list{predictors_list_index} = ['Sn(1)R', num2str(k)];
                                        predictors_list_index = predictors_list_index + 1;
                                    end
                                else
                                    warning('File containing multiple covariates does not contain the required variable "R": %s', nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates);
                                end
                                %}
                                if ~isfield(multiple_covariates, 'R')
                                    warning('File containing multiple covariates does not contain the required variable "R": %s', nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates);
                                end
                            %{
                            elseif ~isempty(regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates,'.*txt$', 'match'))
                                for i = 1:size(multiple_covariates, 2)
                                    predictors_list{predictors_list_index} = ['Sn(1)R', num2str(i)];
                                    predictors_list_index = predictors_list_index + 1;
                                end
                            %}
                            end
                        end
                        interactions_id = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Interactions);
                        validation_status = ~isnan(interactions_id) && validation_status;
                        centering_id = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{h}.Input.MultipleCovariates{i}.Centering);
                        validation_status = ~isnan(centering_id) && validation_status;
                    end
                end
                clear multiple_covariates interactions_id centering_id;
            end
            %}
            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking, 'ThresholdMasking')
                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ThresholdMasking.Type, {'None','Absolute','Relative'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.Masking.ThresholdMasking.Type', h)) && validation_status;
                if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ThresholdMasking.Type) == "absolute" || lower(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ThresholdMasking.Type) == "relative"
                    validation_status = fct_lib.check_nonnegative_number(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ThresholdMasking.ThresholdValue, sprintf('Nodes.Transformations.Instructions{%d}.Input.Masking.ThresholdMasking.ThresholdValue', h)) && validation_status;
                end
            end
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ImplicitMask, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Masking.ImplicitMask', h)) && validation_status;
            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ExplicitMask)
                validation_status = fct_lib.check_file_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Masking.ExplicitMask,'.*nii$', sprintf('Nodes.Transformations.Instructions{%d}.Input.Masking.ExplicitMask', h)) && validation_status;
            end
            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input, 'GlobalCalculation')
                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalCalculation.Type, {'Omit','None','User','Mean'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.GlobalCalculation.Type', h)) && validation_status;
                if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalCalculation.Type) == "user"
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalCalculation.UserSpecifiedValues, 'double', sprintf('Nodes.Transformations.Instructions{%d}.Input.GlobalCalculation.UserSpecifiedValues', h)) && validation_status;
                end
            end
            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input, 'GlobalNormalisation')
                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalNormalisation.OverallGrandMeanScaling, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.GlobalNormalisation.OverallGrandMeanScaling', h)) && validation_status;
                if nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalNormalisation.OverallGrandMeanScaling == 1
                    validation_status = fct_lib.check_nonnegative_number(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalNormalisation.UserSpecifiedValue, sprintf('Nodes.Transformations.Instructions{%d}.Input.GlobalNormalisation.UserSpecifiedValue', h)) && validation_status;
                end
                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalNormalisation.Normalisation, {'None','Proportional','ANCOVA'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.GlobalNormalisation.Normalisation', h)) && validation_status;
            end
        else
            warning('Unsupported transformation instructions for dataset level analysis for node "%s"', nodes{node_idx}.Name);
        end
    end

    %create output
    output.validation_status = validation_status;
    output.design_type = design_type;
    output.second_lv_node_idx = second_lv_node_idx;
    output.factorial_design_idx = factorial_design_idx;
    % output.factors_lst is defined in the switch-case statement above for FlexibleFactorial
    % output.maineffinteract_lst is defined in the switch-case statement above for FlexibleFactorial

end