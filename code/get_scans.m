function output = get_scans(nodes, node_idx, fmri_model_idx, participant_dir, task, sess_id, run_id, bids_flag)
    % This functions searches for the scans (preprocessed files) related to task, session, and run;
    % called from define_model.m
    % INPUTS:
    % nodes: cell array with the nodes of the json file
    % node_idx: index of the node to be processed
    % fmri_model_idx: index of the fmri model instruction to be processed
    % participant_dir: path to the participant directory
    % task: task name
    % sess_id: session id
    % run_id: run id
    % bids_flag: flag to indicate if the dataset is BIDS-compliant
    % OUTPUTS:
    % output: structure with the following fields
    % - scans: cell array with the paths to the scans
    % - number_images: number of images acquired in the scan
    % - nodes: cell array with the updated nodes of the json file
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % get files
    if bids_flag
        scans = fct_lib.recursdir(participant_dir, nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp)';
        % filter scans according to entities (task, session, run)
        taskregexp = ['.*task-', lower(task), '.*'];
        task_filter = cellfun(@(x) regexpi(x, taskregexp), scans, 'UniformOutput', false);
        task_filter = ~cellfun(@isempty, task_filter);
        scans = scans(task_filter);
        if ~isempty(sess_id)
            sessregexp = ['.*ses-', sess_id, '.*'];
            sess_filter = cellfun(@(x) regexpi(x, sessregexp), scans, 'UniformOutput', false);
            sess_filter = ~cellfun(@isempty, sess_filter);
            scans = scans(sess_filter);
        end
        if ~isempty(run_id)
            runregexp = ['.*run-', run_id, '.*'];
            run_filter = cellfun(@(x) regexpi(x, runregexp), scans, 'UniformOutput', false);
            run_filter = ~cellfun(@isempty, run_filter);
            scans = scans(run_filter);
        end
    else
        % look for scans related to sess_id
        if ~isempty(sess_id)
            sessregexp = ['.*', sess_id, '$']; % Session_id is expected at the end of the sub-folder name (not needed for single session experiments)
            subdir = fct_lib.get_valid_subdirs(participant_dir, sessregexp, 1); % sess_id is case insensitive (change last argument to 0 for case sensitive search)
            if isempty(subdir)
                subdir = fct_lib.recursdir_folder(participant_dir, sessregexp);
            end
            if isempty(subdir)
                error('No subfolder found for session %s in %s.', sess_id, participant_dir);
            end
            for i = 1:length(subdir)
                scans = fct_lib.recursdir(subdir{i}, nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp)';
                if ~isempty(scans)
                    break; % it is assumed that files compliant with InputFilterRegexp are only in one subfolder
                end
            end
        else
            scans = fct_lib.recursdir(participant_dir, nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputFilterRegexp)';
        end
        % filter scans according to run_id
        if ~isempty(run_id)
            runregexp = ['.*run[_-]?', lower(run_id), '.*'];
            run_filter = cellfun(@(x) regexpi(x, runregexp), scans, 'UniformOutput', false);
            run_filter = ~cellfun(@isempty, run_filter);
            scans_ = scans(run_filter);
            if isempty(scans_)
                runregexp = [lower(run_id), '\.nii$'];
                run_filter = cellfun(@(x) regexpi(x, runregexp), scans, 'UniformOutput', false);
                run_filter = ~cellfun(@isempty, run_filter);
                scans_ = scans(run_filter);
            end
            scans = scans_;
        end
    end
    % check if scans are found
    if isempty(scans)
        error('No scans found for task %s, session %s, run %s in %s.', task, sess_id, run_id, participant_dir);
    end
    % get numbers of images acquired in the scan (needed to validate parametric modulators)
    if nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType == "3d"
        number_images = size(scans, 1);
        if number_images == 1 % check if it is a 4D image
            warning('Only one image found for task "%s", session "%s", run "%s" in %s.', task, sess_id, run_id, participant_dir);
            fprintf('Checking if it is a 4D image.\n');
            hdr = spm_vol(scans{1});
            number_images = size(hdr, 1);
            if number_images == 1
                error('Only one image found for task "%s", session "%s", run "%s" in %s.', task, sess_id, run_id, participant_dir);
            else
                fprintf('The image is 4D with %d volumes.\n', number_images);
                fprintf('Updating ImageType to 4d.\n');
                nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType = "4d";
            end
        end
    elseif nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType == "4d"
        if size(scans, 1) > 1 % check if 3d images are found
            warning('More than one image found for task "%s", session "%s", run "%s" in %s.', task, sess_id, run_id, participant_dir);
            fprintf('Checking the first one for its dimensionality.\n');
            hdr = spm_vol(scans{1});
            number_images = size(hdr, 1);
            if number_images == 1
                fprintf('The first image is 3D. Assuming all are 3D.\n');
                fprintf('Updating ImageType to 3d.\n');
                nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType = "3d";
                number_images = size(scans, 1);
            else
                fprintf('The first image is 4D with %d volumes.\n', number_images);
            end
        else
            hdr = spm_vol(scans{1});
            number_images = size(hdr, 1);
        end
    else
        if size(scans, 1) > 1
            number_images = size(scans, 1);
        else
            hdr = spm_vol(scans{1});
            number_images = size(hdr, 1);
        end
    end

    %create output
    output.scans = scans;
    output.number_images = number_images;
    output.nodes = nodes;

end