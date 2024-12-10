function output = get_conditions_regressors(matlabbatch, batch_sess_id, nodes, node_idx, task, fmri_model_idx, participant_dir, number_images, conditions_names, sub_idx, bids_flag, sess_id, m, run_id)
    % Get the conditions for a given task and run from the events file or multi-condition file.
    % Inputs:
    %   matlabbatch: cell array of matlabbatch
    %   batch_sess_id: session index in the batch
    %   nodes: cell array of nodes
    %   node_idx: index of the node to get conditions for
    %   task: task name
    %   fmri_model_idx: index of the fMRI model
    %   participant_dir: path to the participant directory
    %   number_images: number of images (volumes)
    %   conditions_names: cell array of condition names
    %   sub_idx: subject index
    %   bids_flag: flag to indicate whether the dataset is in BIDS format
    %   sess_id: session ID
    %   m: session index (according to json)
    %   run_id: run ID
    % Outputs:
    %   output: struct with fields
    %       matlabbatch: updated matlabbatch
    %       conditions_names: updated cell array of condition names
    % Called by: define_model.m
    % This script calls the following functions:
    % - find_events_files.m
    % - find_correct_file.m
    % - read_events_file.m
    % - find_multi_cond_files.m
    % - multi_cond_validation.m
    % - find_motion_files_regexp.m
    % - multi_reg_validation.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % set verbosity
    verbosity = true;

    % get session_ids
    sess_ids = cell(length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions), 1);
    for i = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions)
            sess_ids{i} = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{i}.Session_id;
    end

    % subject ID
    sub_id = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{sub_idx};

    % get conditions from events file
    if isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}, 'Conditions') && ...
        ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions) && ...
        iscell(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions) && ...
        fct_lib.find_key(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions, 'TrialType')
        % get data from events.tsv
        events_regexp = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.EventsRegexp;
        events_files = find_events_files(participant_dir, events_regexp, task, bids_flag, sess_ids);
        if ~events_files.status
            error('No events files found in the directory %s.', participant_dir);
        end
        if length(events_files.files) > 1
            events_file = find_correct_file(events_files.properties, task, sub_id, sess_id, run_id);
            if events_file.status == 0
                warning('No events file found for the participant %s.', sub_id);
                events_file_path = '';
            elseif events_file.status == 2 % this should be handled differently (-> error message)
                warning('More than one events file found for the participant %s. Using first one...', sub_id);
                events_file_path = events_file.filtered_props(1).file;
            elseif events_file.status == 1
                events_file_path = events_file.filtered_props.file;
            end
        elseif length(events_files.files) == 1
            events_file_path = events_files.files{1};
        else
            warning('No events file found for participant %s.', sub_id);
        end
        if ~isempty(events_file_path)
            events = read_events_file(events_file_path);
            cond_cnt = 0;
            for i = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions)
                if ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.TrialType)
                    if ismember(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.TrialType, events.trial_type)
                        cond_cnt = cond_cnt + 1;
                        trial_type = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.TrialType;
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).name = trial_type;
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).tmod = ...
                        nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.TimeModulation;
                        if ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations) && ...
                            iscell(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations)
                            pmod_warning = false;
                            pmod_bool = false;
                            pmod_names = {};
                            pmod_cnt = 0;
                            for j = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations)
                                if iscell(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations) && ...
                                    isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}, 'Name') && ...
                                    ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name)
                                    pmod_cnt = pmod_cnt + 1;
                                    pmod_bool = true;
                                    pmod_names{pmod_cnt} = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.ColName;
                                elseif isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}, 'Name') && ...
                                    isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations{j}.Name) && pmod_bool == false
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod = struct('name', {}, 'param', {}, 'poly', {});
                                end
                            end
                            events_data = read_events_file(events_file_path, pmod_names);
                            trial_type_idx = find(cellfun(@(x) x==string(trial_type), events_data.trial_type, 'UniformOutput', 1));
                            for j = 1:length(events_data.parametric_modulators)
                                if ~isempty(trial_type_idx)
                                    pmod_params = events_data.parametric_modulators_data{trial_type_idx, j};
                                else
                                    warning('Subject %s: No data found for the parametric modulator "%s" of condition "%s".', sub_id, events_data.parametric_modulators{j}, trial_type);
                                    pmod_warning = true;
                                    break;
                                end
                                matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod(j).name = events_data.parametric_modulators{j};
                                matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod(j).poly = ...
                                nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.ParametricModulations{events_data.pmod_json_idx(j)}.Poly;
                                if ~any(isnan(pmod_params)) % this can only be the case if NaNs are "hidden" in categorical data
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod(j).param = pmod_params;
                                else
                                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod(j).param = zeros(1, length(pmod_params));
                                end
                            end
                        else
                            matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod = struct('name', {}, 'param', {}, 'poly', {});
                            events_data = read_events_file(events_file_path);
                            trial_type_idx = find(cellfun(@(x) x==string(trial_type), events_data.trial_type, 'UniformOutput', 1));
                        end
                        if pmod_warning == true
                            % treat the condition as if no parametric modulator was defined:
                            matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).pmod = struct('name', {}, 'param', {}, 'poly', {});
                            events_data = read_events_file(events_file_path);
                            trial_type_idx = find(cellfun(@(x) x==string(trial_type), events_data.trial_type, 'UniformOutput', 1));
                            % alternative: remove the condition if no data is found for the parametric modulator:
                            %cond_cnt = cond_cnt - 1;
                            %continue;
                        end
                        onsets = events_data.onsets(trial_type_idx);
                        durations = events_data.durations(trial_type_idx);
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).onset = onsets{1};
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).duration = durations{1};
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond(cond_cnt).orth = ...
                        nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.OrthogonaliseModulations;
                    end
                elseif isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Conditions{i}.TrialType) && i == 1
                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
                end
            end
        else
            matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        end
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    end

    % get conditions from multi-condition file
    if isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}, 'ConditionsRegexp') && ...
        ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.ConditionsRegexp)
        conditions_regexp = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.ConditionsRegexp;
        multi_cond_files = find_multi_cond_files(participant_dir, conditions_regexp, task, bids_flag, sess_ids);
        if multi_cond_files.status
            if length(multi_cond_files.files) > 1
                multi_cond_file = find_correct_file(multi_cond_files.properties, task, sub_id, sess_id, run_id);
                if multi_cond_file.status == 0
                    warning('No multi-condition file found for the participant %s.', sub_id);
                    multi_cond_file_path = '';
                elseif multi_cond_file.status == 2 % this should be handled differently (-> error message)
                    warning('More than one multi-condition file found for the participant %s. Using first one...', sub_id);
                    multi_cond_file_path = multi_cond_file.filtered_props(1).file;
                elseif multi_cond_file.status == 1
                    multi_cond_file_path = multi_cond_file.filtered_props.file;
                end
            elseif length(multi_cond_files.files) == 1
                multi_cond_file_path = multi_cond_files.files{1};
            end
        else
            multi_cond_file_path = '';
        end
        % separate validation for multi-condition file
        if ~isempty(multi_cond_file_path)
            multi_cond_validation_output = multi_cond_validation(multi_cond_file_path, conditions_names, verbosity);
            multi_cond_validation_status = multi_cond_validation_output.status;
            conditions_names = multi_cond_validation_output.conditions_names; % this might be needed for contrast definition/validation
            if multi_cond_validation_status == 0 % maybe progress the validation status further to the calling function??
                warning('The multi-condition file is not valid.');
                multi_cond_file_path = '';
            end
        end
    else
        multi_cond_file_path = '';
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).multi = {multi_cond_file_path};
    
    % user-defined regressors are not supported anymore
    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).regress = struct('name', {}, 'val', {}); % include empty struct
    
    % get motion regressors
    if isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}, 'RegressorsRegexp') && ...
        ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.RegressorsRegexp)
        multi_reg_regexp = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.RegressorsRegexp;
        multi_reg_files = find_motion_files_regexp(participant_dir, multi_reg_regexp, task, bids_flag, sess_ids);
        if multi_reg_files.status
            if length(multi_reg_files.files) > 1 % apply filter for sub_id, sess_id, run_id, if several files are found
                multi_reg_file = find_correct_file(multi_reg_files.properties, task, sub_id, sess_id, run_id);
                if multi_reg_file.status == 2
                    filtered_files = {multi_reg_file.filtered_props.file};
                elseif multi_reg_file.status == 1
                    filtered_files = {multi_reg_file.file};
                elseif multi_reg_file.status == 0 % use previously found files, if filter yields nothing(??)
                    filtered_files = multi_reg_files.files;
                end
            elseif length(multi_reg_files.files) == 1
                filtered_files = multi_reg_files.files;
            end
            multi_reg_file_cnt = 0;
            for j = 1:length(filtered_files)
                multi_reg_validation_output = multi_reg_validation(filtered_files{j}, number_images, verbosity);
                multi_reg_validation_status = multi_reg_validation_output.status;
                filtered_files{j} = multi_reg_validation_output.multi_reg_file_path;
                if multi_reg_validation_status == 0
                    warning('The multi-regressor file is not valid.');
                else
                    multi_reg_file_cnt = multi_reg_file_cnt + 1;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).multi_reg(multi_reg_file_cnt) = filtered_files(j);
                end
            end
            if ~multi_reg_file_cnt
                matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).multi_reg = {''};
            end
        else
            matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).multi_reg = {''};
        end
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).multi_reg = {''};
    end

    % create output
    output.matlabbatch = matlabbatch;
    output.conditions_names = conditions_names;
end
