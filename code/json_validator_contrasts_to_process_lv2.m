function output = json_validator_contrasts_to_process_lv2(nodes, node_idx, contrast_names_list)
    % This function checks if the contrasts defined in the second level node of the json file are 
    % in agreement with the contrasts defined in the first level node.
    % called from json_validator_bids_values.m
    % This script calls the following functions:
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, 2024

    % import function library
    fct_lib = specs_namespace();

    validation_status = true;
    if lower(nodes{node_idx}.Level) == "dataset"
        for h = 1:length(nodes{node_idx}.Transformations.Instructions)
            if nodes{node_idx}.Transformations.Instructions{h}.Name == "factorial_design_specification" % NAME CAN BE CHANGED
                design_type = fct_lib.convert_design_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.Type);
                switch design_type
                    case 1 % 'OneSampleTTest'
                        validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess, contrast_names_list) && validation_status;
                    case 2 % 'TwoSampleTTest'
                        validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess, contrast_names_list) && validation_status;
                    case 3 % 'PairedTTest'
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans)
                            validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Contrasts1, contrast_names_list) && validation_status;
                            validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputPairedTTest.Scans{i}.Contrasts2, contrast_names_list) && validation_status;
                        end
                    case 4 % 'MultipleRegression'
                        validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess, contrast_names_list) && validation_status;
                    case 5 % 'OneWayANOVA'
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells)
                            validation_status = fct_lib.check_contrast_name({nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVA.Cells{i}.ContrastToProcess}, contrast_names_list) && validation_status;
                        end
                    case 6 % 'OneWayANOVAWithinSubject'
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects)
                            validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{i}.ContrastsToProcess, contrast_names_list) && validation_status;
                        end
                    case 7 % 'FullFactorial'
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells)
                            validation_status = fct_lib.check_contrast_name({nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFullFactorial.Cells{i}.ContrastToProcess}, contrast_names_list) && validation_status;
                        end
                    case 8 % 'FlexibleFactorial'
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects)
                            validation_status = fct_lib.check_contrast_name(nodes{node_idx}.Transformations.Instructions{h}.Input.Design.InputFlexibleFactorial.Subjects{i}.ContrastsToProcess, contrast_names_list) && validation_status;
                        end
                end
            end
        end
    end

    output.validation_status = validation_status;
