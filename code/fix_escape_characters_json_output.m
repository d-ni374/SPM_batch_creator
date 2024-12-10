function nodes = fix_escape_characters_json_output(nodes, first_lv_node_idx, fmri_model_idx, second_lv_node_idx, factorial_design_idx, design_type)
    % This function replaces escape characters ('\') used in regular 
    % expressions by ('\\') compatible with json files. This step is 
    % necessary to avoid errors when updating json files.
    % Called from json_update_dm.m and json_update_dm_lv2.m;
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % first level section
    nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputDirectory = strrep(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputDirectory, '\', '/');
    nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp = insert_escape_character(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp);
    nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory = strrep(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory, '\', '/');
    for i = 1:length(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions)
        nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.EventsRegexp = insert_escape_character(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.EventsRegexp);
        if isfield(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'ConditionsRegexp')
            nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.ConditionsRegexp = insert_escape_character(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.ConditionsRegexp);
        end
        if isfield(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'RegressorsRegexp')
            nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.RegressorsRegexp = insert_escape_character(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.RegressorsRegexp);
        end
    end
    % second level section
    if second_lv_node_idx == 0
        return;
    else
        nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.MainProjectFolder = strrep(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.MainProjectFolder, '\', '/');
        nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.OutputDirectory = strrep(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.OutputDirectory, '\', '/');
        switch design_type
            case 1 % 'OneSampleTTest'
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans, 'InputFilterRegexp')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp);
                end
            case 2 % 'TwoSampleTTest'
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup1')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1 = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1);
                end
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans, 'InputFilterRegexpGroup2')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2 = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2);
                end
            case 3 % 'PairedTTest'
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans, 'InputFilterRegexp1')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp1 = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp1);
                end
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans, 'InputFilterRegexp2')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp2 = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.Scans.InputFilterRegexp2);
                end
            case 4 % 'MultipleRegression'
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans, 'InputFilterRegexp')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp);
                end
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression, 'Covariates') && ~isempty(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates)
                    for i = 1:length(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates)
                        if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{i}, 'CovariatesFileRegexp')
                            nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{i}.CovariatesFileRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{i}.CovariatesFileRegexp);
                        end
                    end
                end
            case 5 % 'OneWayANOVA'
                for i = 1:length(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells)
                    if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}, 'InputFilterRegexpGroup')
                        nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.InputFilterRegexpGroup = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Cells{i}.InputFilterRegexpGroup);
                    end
                end
            case 6 % 'OneWayANOVAWithinSubject'
                for i = 1:length(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects)
                    if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}, 'InputFilterRegexp')
                        nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFilterRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.InputFilterRegexp);
                    end
                end
            case 7 % 'FullFactorial'
                for i = 1:length(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells)
                    if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}, 'InputFilterRegexp')
                        nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.InputFilterRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{i}.InputFilterRegexp);
                    end
                end
            case 8 % 'FlexibleFactorial'
                for i = 1:length(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects)
                    if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}, 'InputFilterRegexp')
                        nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFilterRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.InputFilterRegexp);
                    end
                end
        end
        if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'Covariates') && ~isempty(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates)
            for i = 1:length(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates)
                if isfield(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}, 'CovariatesFileRegexp')
                    nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.CovariatesFileRegexp = insert_escape_character(nodes{second_lv_node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.CovariatesFileRegexp);
                end
            end
        end
    end

end