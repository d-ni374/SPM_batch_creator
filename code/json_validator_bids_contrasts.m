function output = json_validator_bids_contrasts(nodes, node_idx)
    % Validate the content of a json file for its compatibility with the BIDS 
    % Stats Models Specification;
    % Called from json_validator_bids_values.m;
    % This script calls the following functions:
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, Novemeber 2024
    
    % import function library
    fct_lib = specs_namespace();

    validation_status = true;

    % validate Software section (estimation & contrasts)
    find_spm_params = cellfun(@(x) isfield(x, 'SPM'), [nodes{node_idx}.Model.Software]);
    software_index_spm = find(find_spm_params);
    validation_status = fct_lib.check_options(nodes{node_idx}.Model.Software{software_index_spm}.SPM.WriteResiduals, [0,1], sprintf('Nodes.Model.Software{%d}.SPM.WriteResiduals', software_index_spm)) && validation_status;
    validation_status = fct_lib.check_options(nodes{node_idx}.Model.Software{software_index_spm}.SPM.Method.Type, {'Classical', 'Bayesian 1st-level', 'Bayesian 2nd-level'}, sprintf('Nodes.Model.Software{%d}.SPM.Method.Type', software_index_spm)) && validation_status;
    validation_status = fct_lib.check_options(nodes{node_idx}.Model.Software{software_index_spm}.SPM.DeleteExistingContrasts, [0,1], sprintf('Nodes.Model.Software{%d}.SPM.DeleteExistingContrasts', software_index_spm)) && validation_status;
    validation_status = fct_lib.check_options(nodes{node_idx}.Model.Software{software_index_spm}.SPM.ReplicateOverSessions, {'Dont replicate', 'Replicate', 'Replicate&Scale', 'Create per session', 'Both: Replicate + Create per session', 'Both: Replicate&Scale + Create per session', 'none', 'repl', 'replsc', 'sess', 'both', 'bothsc'}, sprintf('Nodes.Model.Software{%d}.SPM.ReplicateOverSessions', software_index_spm)) && validation_status;
    
    % validate Contrasts
    contrast_names_list = {};
    if isfield(nodes{node_idx}, 'Contrasts') && ~isempty(nodes{node_idx}.Contrasts) && iscell(nodes{node_idx}.Contrasts) && ~isempty(nodes{node_idx}.Contrasts{1}.Name)
        for i = 1:length(nodes{node_idx}.Contrasts)
            if ~isempty(nodes{node_idx}.Contrasts{i}.Name)
                validation_status = fct_lib.check_type(nodes{node_idx}.Contrasts{i}.Name, 'char', 'Nodes.Contrasts.Name') && validation_status;
                validation_status = fct_lib.check_name_validity(nodes{node_idx}.Contrasts{i}.Name, contrast_names_list, 'contrast') && validation_status;
                contrast_names_list{end+1} = nodes{node_idx}.Contrasts{i}.Name;
                validation_status = fct_lib.check_type_weights(nodes{node_idx}.Contrasts{i}.Weights, 'Nodes.Contrasts.Weights') && validation_status;
                validation_status = fct_lib.check_options(nodes{node_idx}.Contrasts{i}.Test, {'t', 'f', 'skip'}, 'Nodes.Contrasts.Test') && validation_status;
                if isempty(nodes{node_idx}.Contrasts{i}.Weights)
                    nodes{node_idx}.Contrasts{i}.Weights = ones(length(nodes{node_idx}.Contrasts{i}.ConditionList),1); % if no weights are given, set them to 1
                else
                    if isa(nodes{node_idx}.Contrasts{i}.Weights, 'cell')
                        if any(cellfun(@iscell, nodes{node_idx}.Contrasts{i}.Weights))
                            validation_status = fct_lib.check_matrix(nodes{node_idx}.Contrasts{i}.ConditionList, nodes{node_idx}.Contrasts{i}.Weights, 'Nodes.Contrasts.ConditionList', 'Nodes.Contrasts.Weights') && validation_status;
                        else
                            validation_status = fct_lib.check_arrays(nodes{node_idx}.Contrasts{i}.ConditionList, nodes{node_idx}.Contrasts{i}.Weights, 'Nodes.Contrasts.ConditionList', 'Nodes.Contrasts.Weights') && validation_status;
                        end
                    else
                        if size(nodes{node_idx}.Contrasts{i}.Weights, 1) == 1 || size(nodes{node_idx}.Contrasts{i}.Weights, 2) == 1
                            validation_status = fct_lib.check_arrays(nodes{node_idx}.Contrasts{i}.ConditionList, nodes{node_idx}.Contrasts{i}.Weights, 'Nodes.Contrasts.ConditionList', 'Nodes.Contrasts.Weights') && validation_status;
                        else
                            validation_status = fct_lib.check_matrix(nodes{node_idx}.Contrasts{i}.ConditionList, nodes{node_idx}.Contrasts{i}.Weights, 'Nodes.Contrasts.ConditionList', 'Nodes.Contrasts.Weights') && validation_status;
                        end
                    end
                end
                validation_status = fct_lib.check_contrast_condition_list(nodes{node_idx}.Contrasts{i}.ConditionList, nodes{node_idx}.Model.X) && validation_status;
            end
        end
    end

    % validate DummyContrasts
    if isfield(nodes{node_idx}, 'DummyContrasts') && ~isempty(nodes{node_idx}.DummyContrasts) && ~isempty(nodes{node_idx}.DummyContrasts.Contrasts)
        validation_status = fct_lib.check_options(nodes{node_idx}.DummyContrasts.Test, {'t', 'skip'}, 'Nodes.DummyContrasts.Test') && validation_status;
        for i = 1:length(nodes{node_idx}.DummyContrasts.Contrasts)
            validation_status = fct_lib.check_options(nodes{node_idx}.DummyContrasts.Contrasts{i}, nodes{node_idx}.Model.X, sprintf('Nodes.DummyContrasts.Contrasts{%d}', i)) && validation_status;
            contrast_names_list{end+1} = nodes{node_idx}.DummyContrasts.Contrasts{i};
        end
    end

    % generate warning if validation failed
    if validation_status == false
        warning_ackn = tbx_input_ui('One or more contrasts are not in accordance with the design matrix (see command window)', '+1', 'ignore|abort', [1, 0], 0);
        if warning_ackn == 0
            error('Validation failed');
        end
    end
    % generate warning if no contrasts are defined
    if isempty(contrast_names_list)
        warning('No contrasts defined in the json file.');
    end

    % define output
    output.validation_status = validation_status;
    output.software_index_spm = software_index_spm;
    output.contrast_names_list = contrast_names_list;

end
