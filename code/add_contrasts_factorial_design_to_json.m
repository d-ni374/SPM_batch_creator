function nodes = add_contrasts_factorial_design_to_json(json, json_path_in, nodes, first_lv_node_idx, edges, fmri_model_idx, contrast_names_list, update_flag_cons, validation_output_lv2)
    % This function adds contrasts which are created automatically by SPM (when 
    % using the 'Factorial design' option) to the json file. The contrasts are
    % added to the first level node of the json file.
    % Since SPM will raise an error if any data is missing, the contrast 
    % information is only taken from the first subject.
    % Called from SPM_batch_creator.m
    % This script calls the following functions:
    % - fix_escape_characters_json_output.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % get parameters
    if nargin == 8 % relevant if no second level node is defined
        second_lv_node_idx = 0;
        factorial_design_idx = 0;
        design_type = 0;
    else
        second_lv_node_idx = validation_output_lv2.second_lv_node_idx;
        factorial_design_idx = validation_output_lv2.factorial_design_idx;
        design_type = validation_output_lv2.design_type;
    end

    % load SPM.mat file
    SPM_path = fullfile(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory, nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{1}, 'SPM.mat');
    SPM_ = load(SPM_path);
    SPM = SPM_.SPM;

    % get contrast names from SPM.mat file
    SPM_con_names = {SPM.xCon(:).name};

    % get contrast index in SPM.mat which is not already in contrast_names_list
    missing_indices = find(~cellfun(@(x) ismember(x, contrast_names_list), SPM_con_names));
    if isempty(missing_indices)
        return;
    end

    % get number of predefined contrasts in json file
    if isfield(nodes{first_lv_node_idx}, 'Contrasts') && ~isempty(nodes{first_lv_node_idx}.Contrasts) && ...
        iscell(nodes{first_lv_node_idx}.Contrasts) && fct_lib.find_key(nodes{first_lv_node_idx}.Contrasts, 'Name') && ...
        ~isempty(nodes{first_lv_node_idx}.Contrasts{1}.Name)
        n_predefined_contrasts = length(nodes{first_lv_node_idx}.Contrasts);
    else
        n_predefined_contrasts = 0;
        nodes{first_lv_node_idx}.Contrasts = {};
    end

    % add missing contrasts to json file
    for i = 1:length(missing_indices)
        con_idx = missing_indices(i);
        contrast_name = SPM.xCon(con_idx).name;
        contrast_condition_list = SPM.xX.name.';
        contrast_weights = SPM.xCon(con_idx).c;
        contrast_type = SPM.xCon(con_idx).STAT;
        if strcmp(contrast_type, 'T')
            contrast_type = 't';
        end
        % complete Contrasts section
        nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.Name = contrast_name;
        nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.ConditionList = contrast_condition_list;
        nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.Test = contrast_type;
        if strcmp(contrast_type, 'F')
            nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.Weights = contrast_weights.';
        elseif strcmp(contrast_type, 't')
            % delete zero rows in weights & condition list
            nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.Weights = contrast_weights;
            zero_rows = all(nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.Weights == 0, 2);
            nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.Weights(zero_rows, :) = [];
            nodes{first_lv_node_idx}.Contrasts{n_predefined_contrasts + i}.ConditionList(zero_rows) = [];
        end
    end

    % clear 'FactorialDesign' section to avoid additional contrasts on re-execution
    nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input = rmfield(nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input, 'FactorialDesign');
    nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{1}.Name = '';
    nodes{first_lv_node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{1}.Levels = 0;
    fprintf('json file updated with contrasts that were created automatically by SPM when using first level option "Factorial design".\n');
    fprintf ('Note: The added contrasts REPLACE the "FactorialDesign" section in the json file.\n');

    % fix escape characters
    nodes = fix_escape_characters_json_output(nodes, first_lv_node_idx, fmri_model_idx, second_lv_node_idx, factorial_design_idx, design_type);

    % apply changes
    first_level_json_out = json;
    first_level_json_out = rmfield(first_level_json_out, 'Nodes');
    first_level_json_out.Nodes = nodes;
    first_level_json_out.Edges = edges;

    % update json file
    if update_flag_cons
        json_path_out = json_path_in; % file will be overwritten
        fid = fopen(json_path_out, 'w');
        encodedJSON = jsonencode(first_level_json_out, PrettyPrint=true);
        fprintf(fid,encodedJSON);
        fclose(fid);
    end

end

