function output = valid_bids_lv1_dm(nodes, validation_status, node_idx)
    % This function validates first level nodes prior to contrast definition;
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

    % Validate Model section
    validation_status = fct_lib.check_options(nodes{node_idx}.Model.Type, {'glm', 'meta'}, 'Nodes.Model.Type') && validation_status;
    for i = 1:length(nodes{node_idx}.Model.X)
        if nodes{node_idx}.Model.X{i} ~= 1 % the value of 1 is a shortcut for the constant term (BIDS), but is not supported within this software
            validation_status = fct_lib.check_type(nodes{node_idx}.Model.X{i}, 'char', 'Nodes.Model.X') && validation_status;
        else
            warning('Definition of Model.X: The value 1 as a shortcut for the constant term is not supported within this software.');
        end
    end
    if isfield(nodes{node_idx}.Model, 'HRF')
        validation_status = fct_lib.check_structure_field(nodes{node_idx}.Model.HRF, 'Model', 'Nodes.Model.HRF') && validation_status;
        validation_status = fct_lib.check_options(nodes{node_idx}.Model.HRF.Model, {'spm', 'spm + derivative', 'spm + derivative + dispersion', 'glover', 'glover + derivative', 'glover + derivative + dispersion', 'fir'}, 'Nodes.Model.HRF.Model') && validation_status;
        validation_status = fct_lib.check_structure_field(nodes{node_idx}.Model.HRF, 'Variables', 'Nodes.Model.HRF') && validation_status;
        validation_status = fct_lib.check_hrf_variables(nodes{node_idx}.Model.HRF.Variables, nodes{node_idx}.Model.X) && validation_status;
    end
    if isfield(nodes{node_idx}.Model, 'Options')
        if isfield(nodes{node_idx}.Model.Options, 'HighPassFilterCutoffHz')
            validation_status = fct_lib.check_type(nodes{node_idx}.Model.Options.HighPassFilterCutoffHz, 'double', 'Nodes.Model.Options.HighPassFilterCutoffHz') && validation_status;
        end
    end
    
    % Validate Transformations section
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
        if nodes{node_idx}.Transformations.Instructions{h}.Name == "fmri_model_specification"
            first_lv_node_idx = node_idx;
            fmri_model_idx = h;
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.BIDSflag, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.BIDSflag', h)) && validation_status;
            validation_status = fct_lib.check_dir(nodes{node_idx}.Transformations.Instructions{h}.Input.InputDirectory, sprintf('Nodes.Transformations.Instructions{%d}.Input.InputDirectory', h)) && validation_status;
            validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.InputFilterRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.InputFilterRegexp', h)) && validation_status;
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.ImageType, {'3d','4d','unknown'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.ImageType', h)) && validation_status;
            validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Participant_ID, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Participant_ID', h)) && validation_status;
            all_participant_ids = nodes{node_idx}.Transformations.Instructions{h}.Input.Participant_ID;
            validation_status = fct_lib.check_virtual_folder(nodes{node_idx}.Transformations.Instructions{h}.Input.OutputDirectory, '[#<$+%>!`&*}{?" =@:|]', sprintf('Nodes.Transformations.Instructions{%d}.Input.OutputDirectory', h)) && validation_status;
            if ~fct_lib.info_dir_exist(nodes{node_idx}.Transformations.Instructions{h}.Input.OutputDirectory, sprintf('Nodes.Transformations.Instructions{%d}.Input.OutputDirectory', h))
                mkdir(nodes{node_idx}.Transformations.Instructions{h}.Input.OutputDirectory);
            end
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.TimingParameters.UnitsForDesign, {'secs', 'scans'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.TimingParameters.UnitsForDesign', h)) && validation_status;
            validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.TimingParameters.InterscanInterval, sprintf('Nodes.Transformations.Instructions{%d}.Input.TimingParameters.InterscanInterval', h)) && validation_status;
            validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.TimingParameters.MicrotimeResolution, sprintf('Nodes.Transformations.Instructions{%d}.Input.TimingParameters.MicrotimeResolution', h)) && validation_status;
            validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.TimingParameters.MicrotimeOnset, sprintf('Nodes.Transformations.Instructions{%d}.Input.TimingParameters.MicrotimeOnset', h)) && validation_status;
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.Type, {'Canonical HRF','Fourier Set','Fourier Set (Hanning)','Gamma Functions','Finite Impulse Response','None'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.BasisFunctions.Type', h)) && validation_status;
            if lower(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.Type) == "canonical hrf"
                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives', h)) && validation_status;
                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives', h)) && validation_status;
                if nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives == 1 && nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives == 0
                    warning('SPM software does not support dispersion derivatives without time derivatives');
                end
                % check agreement of derivatives with nodes{node_idx}.Model.HRF.Model
                number_of_derivatives = nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives + nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives;
                validation_status_temp = validation_status;
                if number_of_derivatives == 0
                    validation_status = fct_lib.check_options(nodes{node_idx}.Model.HRF.Model, {'spm'}, 'Nodes.Model.HRF.Model') && validation_status;
                elseif number_of_derivatives == 1
                    validation_status = fct_lib.check_options(nodes{node_idx}.Model.HRF.Model, {'spm + derivative'}, 'Nodes.Model.HRF.Model') && validation_status;
                elseif number_of_derivatives == 2
                    validation_status = fct_lib.check_options(nodes{node_idx}.Model.HRF.Model, {'spm + derivative + dispersion'}, 'Nodes.Model.HRF.Model') && validation_status;
                end
                if validation_status_temp ~= validation_status
                    warning('The number of derivatives defined for the HRF is not in agreement with the HRF model "%s".', nodes{node_idx}.Model.HRF.Model);
                end
                clear validation_status_temp;
            elseif lower(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.Type) == "none"
                ;
            else
                validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs, sprintf('Nodes.Transformations.Instructions{%d}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs', h)) && validation_status;
                validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions, sprintf('Nodes.Transformations.Instructions{%d}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions', h)) && validation_status;
            end
            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions) && iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions) && fct_lib.find_key(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{1}, 'Session_id')
                for m = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions) 
                    conditions_names = {}; % needed later to check if contrasts are in agreement with conditions
                    %predictors_list = {}; % needed later to get the correct order of predictors in the design matrix, which is mandatory to define the contrasts correctly
                    %predictors_list_index = 1;
                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Session_id, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.Session_id', h, m)) && validation_status; % has to be changed if numeric identifiers are used
                    if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}, 'Run_ids')
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Run_ids, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.Run_ids', h, m)) && validation_status;
                    end
                    validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.EventsRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.EventsRegexp', h)) && validation_status;
                    if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions) && iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions) && fct_lib.find_key(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions, 'TrialType')
                        for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions)
                            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType)
                                validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.Conditions.TrialType', h, m)) && validation_status;
                                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TimeModulation, [0,1,2,3,4,5,6], sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.Conditions.TimeModulation', h, m)) && validation_status;
                                validation_status = fct_lib.check_name_validity(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType, conditions_names, 'condition') && validation_status;
                                conditions_names{i} = nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType;
                                %predictors_list{predictors_list_index} = ['Sn(1)', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType, '*bf(1)']; % maybe change to names that are more understandable for the user
                                %predictors_list_index = predictors_list_index + 1;
                                for k = 1:number_of_derivatives
                                    %predictors_list{predictors_list_index} = ['Sn(1)', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType, '*bf(', num2str(k+1), ')'];
                                    %predictors_list_index = predictors_list_index + 1;
                                end
                                for l = 1:nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TimeModulation
                                    for k = 1:number_of_derivatives + 1
                                        %predictors_list{predictors_list_index} = ['Sn(1)', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType, 'xtime^', num2str(l), '*bf(', num2str(k), ')'];
                                        %predictors_list_index = predictors_list_index + 1;
                                    end
                                end
                                if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}, 'ParametricModulations') && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations)
                                    if fct_lib.find_key(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations, 'Name')
                                        for j = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations)
                                            if iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations) && isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}, 'Name') && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name)
                                                validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name, 'char', 'Conditions.ParametricModulations.Name') && validation_status;
                                                if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.ColName)
                                                    validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.ColName, 'char', 'Conditions.ParametricModulations.ColName') && validation_status;
                                                else 
                                                    warning('Parametric modulation "%s" is incomplete!', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name);
                                                end
                                                if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Poly)
                                                    validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Poly, [1,2,3,4,5,6], 'Conditions.ParametricModulations.Poly') && validation_status;
                                                else 
                                                    warning('Parametric modulation "%s" is incomplete!', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name);
                                                end
                                                for l = 1:nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Poly
                                                    for k = 1:number_of_derivatives + 1
                                                        %predictors_list{predictors_list_index} = ['Sn(1)', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.TrialType, 'x', nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name, '^', num2str(l), '*bf(', num2str(k), ')'];
                                                        %predictors_list_index = predictors_list_index + 1;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.Conditions{i}.OrthogonaliseModulations, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.Conditions.OrthogonaliseModulations', h, m)) && validation_status;
                            end
                        end
                    end
                    if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}, 'ConditionsRegexp') && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.ConditionsRegexp)
                        validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.ConditionsRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.ConditionsRegexp', h, m)) && validation_status;
                    end
                    if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}, 'RegressorsRegexp') && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.RegressorsRegexp)
                        validation_status = fct_lib.check_regexp(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.RegressorsRegexp, sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.RegressorsRegexp', h, m)) && validation_status;
                    end
                    %predictors_list{predictors_list_index} = 'Sn(1)constant';
                    validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.Sessions{m}.HighPassFilterSecs, sprintf('Nodes.Transformations.Instructions{%d}.Input.Sessions{%d}.HighPassFilterSecs', h, m)) && validation_status;
                end
            end
            if isfield(nodes{node_idx}.Transformations.Instructions{h}.Input, 'FactorialDesign') && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign) && iscell(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign) && ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign{1}.Name)
                for i = 1:length(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign)
                    if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign{i}.Name)
                        validation_status = fct_lib.check_type(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign{i}.Name, 'char', sprintf('Nodes.Transformations.Instructions{%d}.Input.FactorialDesign.Name', h)) && validation_status;
                        validation_status = fct_lib.check_positive_number(nodes{node_idx}.Transformations.Instructions{h}.Input.FactorialDesign{i}.Levels, sprintf('Nodes.Transformations.Instructions{%d}.Input.FactorialDesign.Levels', h)) && validation_status;
                    end
                end
            end
            % section BasisFunctions was moved up (above Conditions)
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.ModelInteractionsVolterra, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.ModelInteractionsVolterra', h)) && validation_status;
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.GlobalNormalisation, [0,1], sprintf('Nodes.Transformations.Instructions{%d}.Input.GlobalNormalisation', h)) && validation_status;
            validation_status = fct_lib.check_nonnegative_number(nodes{node_idx}.Transformations.Instructions{h}.Input.MaskingThreshold, sprintf('Nodes.Transformations.Instructions{%d}.Input.MaskingThreshold', h)) && validation_status;
            if ~isempty(nodes{node_idx}.Transformations.Instructions{h}.Input.ExplicitMask)
                validation_status = fct_lib.check_file_type(nodes{node_idx}.Transformations.Instructions{h}.Input.ExplicitMask,'.*nii$', sprintf('Nodes.Transformations.Instructions{%d}.Input.ExplicitMask', h)) && validation_status;
            end
            validation_status = fct_lib.check_options(nodes{node_idx}.Transformations.Instructions{h}.Input.SerialCorrelations, {'none', 'AR(1)', 'FAST'}, sprintf('Nodes.Transformations.Instructions{%d}.Input.SerialCorrelations', h)) && validation_status;
        else
            warning('Unsupported transformation instructions for run/session/subject level analysis for node "%s"', nodes{node_idx}.Name);
        end
    end

    %create output
    output.validation_status = validation_status;
    output.conditions_names = conditions_names; % this list was produced from the input parameters
    output.first_lv_node_idx = first_lv_node_idx;
    output.fmri_model_idx = fmri_model_idx;
    output.all_participant_ids = all_participant_ids;
    %output.predictors_list = predictors_list; % this list was produced from the input parameters knowing the structure SPM applies to the design matrix

end