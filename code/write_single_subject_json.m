function status = write_single_subject_json(first_level_json, json_path_in, nodes, node_idx, fmri_model_idx, design_matrix_col_names, dm_cond_col_names, sub_idx, matlabbatch, update_flag)
    % This function writes a json file for every single subject and stores it 
    % in a subfolder of the model output directory. The json file contains
    % real data (instead of regular expressions or file paths) and is mainly 
    % used for debugging purposes. The json file contains also the design matrix
    % column names and the HRF variables (if present) of the current subject;
    % called from json_validator_bids_values.m
    %
    % OPTION: replace design_matrix_col_names with predictors_list to use custom names
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();
    % initialize status
    status = 0;

    % change certain fields in the Transformations section (data of single participant)
    nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{sub_idx};
    nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory = strrep(fullfile(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory, nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID), '\', '/');
    for i = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions)
        nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i} = rmfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'EventsRegexp');
        cond_from_batch = cell(1, size(matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond, 2));
        for j = 1:size(matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond, 2)
            cond_from_batch{j}.Name = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).name;
            cond_from_batch{j}.Onsets = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).onset;
            cond_from_batch{j}.Durations = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).duration;
            cond_from_batch{j}.TimeModulation = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).tmod;
            if ~isempty(matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).pmod) % CHECK!!
                for k = 1:length(matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).pmod)
                    cond_from_batch{j}.ParametricModulations{k}.Name = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).pmod(k).name;
                    cond_from_batch{j}.ParametricModulations{k}.Param = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).pmod(k).param;
                    cond_from_batch{j}.ParametricModulations{k}.Poly = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).pmod(k).poly;
                end
            end
            cond_from_batch{j}.OrthogonaliseModulations = matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(j).orth;
        end
        nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.Conditions = cond_from_batch;
        if isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'ConditionsRegexp')
            nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i} = rmfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'ConditionsRegexp');
        end
        if ~isempty(matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi{1})
            nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.MultipleConditions = strrep(matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi{1}, '\', '/');
        end
        if isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'RegressorsRegexp')
            nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i} = rmfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}, 'RegressorsRegexp');
        end
        if ~isempty(matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg{1})
            nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.MultipleRegressors = strrep(matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg, '\', '/');
        end
    end

    % add contents of the design matrix to the json file
    nodes{node_idx}.Model.X = cell(1,length(design_matrix_col_names));
    for i = 1:length(design_matrix_col_names)
        nodes{node_idx}.Model.X{i} = design_matrix_col_names{i};
    end
    if isfield(nodes{node_idx}.Model, 'HRF')
        var_cnt = 0;
        nodes{node_idx}.Model.HRF.Variables = {};
        for i = 1:length(design_matrix_col_names)
            for j = 1:length(dm_cond_col_names)
                if strfind(design_matrix_col_names{i}, dm_cond_col_names{j})
                    var_cnt = var_cnt + 1;
                    nodes{node_idx}.Model.HRF.Variables{var_cnt} = design_matrix_col_names{i};
                end
            end
        end
    end
    
    % delete contrasts and dummy contrasts, which are invalid for the current participant
    if isfield(nodes{node_idx}, 'Contrasts') && ~isempty(nodes{node_idx}.Contrasts) && iscell(nodes{node_idx}.Contrasts) && fct_lib.find_key(nodes{node_idx}.Contrasts, 'Name')
        for i = 1:length(nodes{node_idx}.Contrasts)
            if any(~ismember(nodes{node_idx}.Contrasts{i}.ConditionList, design_matrix_col_names))
                nodes{node_idx}.Contrasts{i} = [];
            end
        end
        nodes{node_idx}.Contrasts = nodes{node_idx}.Contrasts(~cellfun('isempty',nodes{node_idx}.Contrasts));
    end
    if isfield(nodes{node_idx}, 'DummyContrasts') && ~isempty(nodes{node_idx}.DummyContrasts) && ~isempty(nodes{node_idx}.DummyContrasts.Contrasts)
        for i = 1:length(nodes{node_idx}.DummyContrasts.Contrasts)
            if any(~ismember(nodes{node_idx}.DummyContrasts.Contrasts(i), design_matrix_col_names))
                nodes{node_idx}.DummyContrasts.Contrasts{i} = [];
            end
        end
        nodes{node_idx}.DummyContrasts.Contrasts = nodes{node_idx}.DummyContrasts.Contrasts(~cellfun('isempty',nodes{node_idx}.DummyContrasts.Contrasts));
    end

    % fix escape characters
    nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp = strrep(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp, '\', '\\');

    % apply changes
    first_level_json_out = first_level_json;
    first_level_json_out = rmfield(first_level_json_out, 'Nodes');
    first_level_json_out.Nodes = nodes(node_idx); % only the first level node is relevant on subject level (at least for the actual design)
    if update_flag
        % write json file
        [path, name, ext] = fileparts(json_path_in);
        sub_id = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID;
        json_path_out = fullfile(path, sub_id, [name, '_', sub_id, ext]); % output path can be changed
        if ~isfolder(fullfile(path, sub_id))
            mkdir(fullfile(path, sub_id));
        end
        fid = fopen(json_path_out, 'w');
        encodedJSON = jsonencode(first_level_json_out, PrettyPrint=true);
        fprintf(fid,encodedJSON);
        fclose(fid);
        status = 1;
    end

end