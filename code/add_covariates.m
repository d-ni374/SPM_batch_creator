function matlabbatch = add_covariates(matlabbatch, nodes, node_idx, validation_output_lv2, con_idx)
    % This function adds the covariates identified from the json file to the
    % existing batch job;
    % called by define_model_lv2.m;
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    factorial_design_idx = validation_output_lv2.factorial_design_idx;
    design_type = validation_output_lv2.design_type;

    if ismember(design_type, [1, 2, 3, 4]) % applies to 'OneSampleTTest', 'TwoSampleTTest', 'PairedTTest', 'MultipleRegression'
        if isfield(validation_output_lv2.data, 'covariates_array') && ~isempty(validation_output_lv2.data(con_idx).covariates_array)
            for i = 1:size(validation_output_lv2.data(con_idx).covariates_array, 2)
                if design_type == 1 % 'OneSampleTTest'
                    matlabbatch{1}.spm.stats.factorial_design.cov(i).c = [validation_output_lv2.data(con_idx).covariates_array{:,i}]';
                elseif design_type == 2 % 'TwoSampleTTest'
                    matlabbatch{1}.spm.stats.factorial_design.cov(i).c = [validation_output_lv2.data(con_idx).covariates_array_group1{:,i}, validation_output_lv2.data(con_idx).covariates_array_group2{:,i}]';
                elseif design_type == 3 % 'PairedTTest'
                    n_covariates = size(validation_output_lv2.data(1).covariates_array, 2) / 2; % the array contains two sets of covariates
                    covariates_array_batch = [];
                    if i <= n_covariates
                        for j = 1:length(validation_output_lv2.data) % loop through the number of pair definitions (array elements in the json file)
                            covariates_array_batch_ = [];
                            for k = 1:size(validation_output_lv2.data(j).covariates_array, 1) % loop through the number of pairs (all pairs determined from the pair definition)
                                covariates_array_batch_ = [covariates_array_batch_, validation_output_lv2.data(j).covariates_array{k, i}, validation_output_lv2.data(j).covariates_array{k, i+n_covariates}];
                            end
                            covariates_array_batch = [covariates_array_batch, covariates_array_batch_];
                        end
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).c = covariates_array_batch';
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Name;
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Interactions);
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Centering);
                    end
                elseif design_type == 4 % 'MultipleRegression'
                    matlabbatch{1}.spm.stats.factorial_design.cov(i).c = [validation_output_lv2.data(con_idx).covariates_array{:,i}]';
                    n_covariates_main = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates);
                    if i <= n_covariates_main
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Name;
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Interactions);
                        matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Centering);
                    %else % additional covariates for multiple regression % needs to be assigned in define_model_lv2.m
                    %    matlabbatch{1}.spm.stats.factorial_design.cov(i).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{i-n_covariates_main}.Name;
                    %    matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI = 1; % default value
                    %    matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{i-n_covariates_main}.Centering);
                    end
                end
                if ismember(design_type, [1, 2])
                    matlabbatch{1}.spm.stats.factorial_design.cov(i).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Name;
                    matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Interactions);
                    matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Centering);
                end
            end
        else
            matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        end
    elseif ismember(design_type, [5, 7]) % applies to 'OneWayANOVA', 'FullFactorial'
        if isfield(validation_output_lv2.cells, 'covariates_array') && ~isempty(validation_output_lv2.cells(1).covariates_array)
            for i = 1:size(validation_output_lv2.cells(1).covariates_array, 2)
                covariates_array_batch = [];
                for j = 1:length(validation_output_lv2.cells)
                    covariates_array_batch = [covariates_array_batch, validation_output_lv2.cells(j).covariates_array{:,i}];
                end
                matlabbatch{1}.spm.stats.factorial_design.cov(i).c = covariates_array_batch';
                matlabbatch{1}.spm.stats.factorial_design.cov(i).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Name;
                matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Interactions);
                matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Centering);
            end
        end
    elseif ismember(design_type, [6, 8]) % applies to 'OneWayANOVAWithinSubject', 'FlexibleFactorial'
        if isfield(validation_output_lv2.subjects, 'covariates_array') && ~isempty(validation_output_lv2.subjects(1).covariates_array)
            for i = 1:size(validation_output_lv2.subjects(1).covariates_array, 1)
                covariates_array_batch = [];
                for j = 1:length(validation_output_lv2.subjects)
                    covariates_array_batch = [covariates_array_batch, validation_output_lv2.subjects(j).covariates_array{i,:}];
                end
                matlabbatch{1}.spm.stats.factorial_design.cov(i).c = covariates_array_batch';
                matlabbatch{1}.spm.stats.factorial_design.cov(i).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Name;
                matlabbatch{1}.spm.stats.factorial_design.cov(i).iCFI = fct_lib.convert_iCFI(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Interactions);
                matlabbatch{1}.spm.stats.factorial_design.cov(i).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{i}.Centering);
            end
        end
    end

end