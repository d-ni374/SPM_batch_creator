function matlabbatch = define_model_lv2(model_name, nodes, node_idx, validation_output_lv2, con_idx)
    % define_model: defines the model for the first-level analysis
    % Inputs:
    %   model_name: the name of the model
    %   nodes: the nodes of the json file
    %   node_idx: the index of the node to define the model for
    %   validation_output_lv2: output struct of the second level validation of the json file
    %   con_idx: the index of the contrast to define the model for
    % Outputs:
    %   matlabbatch: the batch for the model definition
    % Called from SPM_batch_creator and json_validator_bids_values.m
    % This script calls the following functions:
    % - replace_invalid_characters.m
    % - add_covariates.m
    % - add_global_calculation.m
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    factorial_design_idx = validation_output_lv2.factorial_design_idx;
    design_type = validation_output_lv2.design_type;
    contrasts_to_process = validation_output_lv2.contrasts_to_process;

    % define output path (for one-sample t-test, two-sample t-test, and multiple regression, the contrast name will be 
    % used as the sub-folder name, since all mentioned contrasts are processed sequentially)
    if regexp(model_name, '[#<$+%>!`&*}{?" =@:|]')
        model_name = replace_invalid_characters(model_name);
    end
    if ~isempty(contrasts_to_process)
        con_name = contrasts_to_process{con_idx};
        if regexp(con_name, '[#<$+%>!`&*}{?" =@:|]')
            folder_name = replace_invalid_characters(con_name);
        else
            folder_name = con_name;
        end
        matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.OutputDirectory, model_name, folder_name)};
    else
        matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.OutputDirectory, model_name)};
    end

    switch design_type
        case 1 % 'OneSampleTTest'
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = validation_output_lv2.data(con_idx).paths_array;
        case 2 % 'TwoSampleTTest'
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = validation_output_lv2.data(con_idx).paths_array_group1;
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = validation_output_lv2.data(con_idx).paths_array_group2;
            matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = ~nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Independence; % inverted input
            matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = fct_lib.convert_variance_setting(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.Variance);
            matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.GrandMeanScaling;
            matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputTwoSampleTTest.ANCOVA;
        case 3 % 'PairedTTest'
            pair_idx = 0;
            for i = 1:length(validation_output_lv2.data)
                for j = 1:size(validation_output_lv2.data(i).paths_array, 1)
                    pair_idx = pair_idx + 1;
                    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(pair_idx).scans = cell(2, 1);
                    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(pair_idx).scans{1} = validation_output_lv2.data(i).paths_array{j, 1};
                    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(pair_idx).scans{2} = validation_output_lv2.data(i).paths_array{j, 2};
                end
            end
            matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.GrandMeanScaling;
            matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputPairedTTest.ANCOVA;
        case 4 % 'MultipleRegression'
            matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = validation_output_lv2.data(con_idx).paths_array;
            if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression, 'Covariates') && ...
                ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates) && ...
                iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates)
                if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'Covariates') && ...
                    ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates) && ...
                    iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates) && ...
                    ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{1}.ColName)
                    n_covariates_main = length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates);
                else
                    n_covariates_main = 0;
                end
                cov_bool = false;
                for j = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates)
                    if iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates) && ...
                        isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}, 'Name') && ...
                        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name)
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(j).c = [validation_output_lv2.data(con_idx).covariates_array{:,j+n_covariates_main}]';
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(j).cname = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name;
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(j).iCC = fct_lib.convert_iCC(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Centering);
                        cov_bool = true;
                    elseif isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}, 'Name') && isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Covariates{j}.Name) && cov_bool == false
                        matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
                    end
                end
            else
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
            end
            matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputMultipleRegression.Intercept;
        case 5 % 'OneWayANOVA'
            cell_idx = 0;
            for j = 1:length(validation_output_lv2.cells)
                if ~isempty(validation_output_lv2.cells(j).paths_array)
                    cell_idx = cell_idx + 1;
                    matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(cell_idx).scans = validation_output_lv2.cells(j).paths_array;
                else
                    warning('No scans remained for cell %d after filtering for file and covariate availability.', j);
                end
            end
            matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = ~nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Independence; % inverted input
            matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = fct_lib.convert_variance_setting(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.Variance);
            matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.GrandMeanScaling;
            matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVA.ANCOVA;
        case 6 % 'OneWayANOVAWithinSubject'
            sub_idx = 0;
            for i = 1:length(validation_output_lv2.subjects)
                if ~isempty(validation_output_lv2.subjects(i).paths_array)
                    for j = 1:size(validation_output_lv2.subjects(i).paths_array, 2) % subject scans are stored in columns for this design
                        sub_idx = sub_idx + 1;
                        matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(sub_idx).scans = validation_output_lv2.subjects(i).paths_array(:, j);
                        matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(sub_idx).conds = 1:size(validation_output_lv2.subjects(i).paths_array, 1);
                    end
                else
                    warning('No scans remained for subjects definition %d after filtering for file and covariate availability.', i);
                end
            end
            matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = ~nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Independence; % inverted input
            matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = fct_lib.convert_variance_setting(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.Variance);
            matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.GrandMeanScaling;
            matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputOneWayANOVAWithinSubject.ANCOVA;
        case 7 % 'FullFactorial'
            for j = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors)
                matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(j).name = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors{j}.Name;
                matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(j).levels = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors{j}.Levels;
                matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(j).dept = ~nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors{j}.Independence; % inverted input
                matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(j).variance = fct_lib.convert_variance_setting(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors{j}.Variance);
                matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(j).gmsca = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors{j}.GrandMeanScaling;
                matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(j).ancova = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Factors{j}.ANCOVA;
            end
            cell_idx = 0;
            for j = 1:length(validation_output_lv2.cells)
                if ~isempty(validation_output_lv2.cells(j).paths_array)
                    cell_idx = cell_idx + 1;
                    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(cell_idx).levels = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.Cells{j}.Levels;
                    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(cell_idx).scans = validation_output_lv2.cells(j).paths_array;
                else
                    warning('No scans remained for cell %d after filtering for file and covariate availability.', j);
                end
            end
            matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFullFactorial.GenerateContrasts;
        case 8 % 'FlexibleFactorial'
            factors_lst = validation_output_lv2.factors_lst;
            maineffinteract_lst = validation_output_lv2.maineffinteract_lst;
            sub_idx = 0;
            for j = 1:length(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Factors)
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(j).name = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Factors{j}.Name;
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(j).dept = ~nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Factors{j}.Independence; % inverted input
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(j).variance = fct_lib.convert_variance_setting(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Factors{j}.Variance);
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(j).gmsca = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Factors{j}.GrandMeanScaling;
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(j).ancova = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Factors{j}.ANCOVA;
            end
            %conditions_factor_matrix = []; % only needed for 'all' subject specification
            for i = 1:length(validation_output_lv2.subjects)
                if ~isempty(validation_output_lv2.subjects(i).paths_array)
                    for j = 1:size(validation_output_lv2.subjects(i).paths_array, 2) % subject scans are stored in columns for this design
                        sub_idx = sub_idx + 1;
                        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(sub_idx).scans = validation_output_lv2.subjects(i).paths_array(:, j);
                        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(sub_idx).conds = validation_output_lv2.subjects(i).conditions;
                    end
                    %conditions_factor_matrix = [conditions_factor_matrix; nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Design.InputFlexibleFactorial.Subjects{i}.Conditions]; % only needed for 'all' subject specification
                else
                    warning('No scans remained for subjects definition %d after filtering for file and covariate availability.', i);
                end
            end
            %matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = conditions_factor_matrix; % only needed for 'all' subject specification; column 1 with replication factor missing!
            for j = 1:length(maineffinteract_lst)
                if maineffinteract_lst{j}{1} == "MainEffect"
                    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{j}.fmain.fnum = find(strcmp(factors_lst, maineffinteract_lst{j}{2}));
                elseif maineffinteract_lst{j}{1} == "Interaction"
                    factors = [];
                    for k = 1:2
                        factors = [factors, find(strcmp(factors_lst, maineffinteract_lst{j}{2}{k}))];
                        matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{j}.inter.fnums = factors;
                    end
                end
            end
        otherwise
            error('Invalid design type in variable nodes.Transformations.Instructions.Input.Design.Type');
    end
    clear subject_files input_files cell_files input_files_1 input_files_2;

    if isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'Covariates') && ...
        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates) && ...
        iscell(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates) &&...
        ~isempty(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Covariates{1}.ColName)
        matlabbatch = add_covariates(matlabbatch, nodes, node_idx, validation_output_lv2, con_idx);
    else
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    end
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {}); % not supported anymore (all covariates are included in the covariate section)
    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ThresholdMasking.Type) == "none"  || ~isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking, 'ThresholdMasking')
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    elseif lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ThresholdMasking.Type) == "absolute"
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tma.athresh = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ThresholdMasking.ThresholdValue;
    elseif lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ThresholdMasking.Type) == "relative"
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tmr.rthresh = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ThresholdMasking.ThresholdValue;
    end
    matlabbatch{1}.spm.stats.factorial_design.masking.im = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ImplicitMask;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {fullfile(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.Masking.ExplicitMask)};
    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "omit" || lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "none" || ~isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'GlobalCalculation')
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    elseif lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "user"
        matlabbatch = add_global_calculation(matlabbatch, validation_output_lv2, con_idx);
        %matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.UserSpecifiedValues;
    elseif lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalCalculation.Type) == "mean"
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_mean = 1;
    end
    if nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalNormalisation.OverallGrandMeanScaling == 0 || ~isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'GlobalNormalisation')
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    elseif nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalNormalisation.OverallGrandMeanScaling == 1
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_yes.gmscv = nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalNormalisation.UserSpecifiedValue;
    end
    if lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalNormalisation.Normalisation) == "none" || ~isfield(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input, 'GlobalNormalisation')
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    elseif lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalNormalisation.Normalisation) == "proportional"
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 2;
    elseif lower(nodes{node_idx}.Transformations.Instructions{factorial_design_idx}.Input.GlobalNormalisation.Normalisation) == "ancova"
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 3;
    end

end