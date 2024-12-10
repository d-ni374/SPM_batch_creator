function output = find_motion_files_regexp(directory, pattern, task, bids_flag, sess_ids)
    % finds files in a directory that match a regular expression pattern;
    % called from get_conditions_regressors.m
    % This script calls the following functions:
    % - specs_namespace.m
    % - determine_entities.m
    % - find_files_in_subfolders.m
    % - get_raw_from_preproc_dir.m
    % 
    % INPUTS
    % directory: string; path to directory
    % pattern: string; regular expression pattern
    % task: string; task name
    % bids_flag: boolean; if true, use BIDS file naming convention
    % sess_ids: cell array; list of session ids; only required for non-BIDS datasets (otherwise ignored)
    %
    % NOTE for sess_ids: all session_ids present in the dataset should be provided
    % to avoid misinterpretation of the session_id (i.e. intermixing with sub_id);
    % in case of non-BIDS datasets, the session_id must only contain letters or numbers, but not both
    % 
    % OUTPUTS
    % files: cell array; list of files that match the pattern
    % properties: struct; properties of the files (entities for BIDS datasets)
    % 
    % EXAMPLE
    % files = find_files_regexp('subjectPreprocDir', '^rp.*txt$', 'foraging', true, {'01', '02'})
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if isempty(pattern)
        output.status = 0; % no file found
        return
    end

    % import function library
    fct_lib = specs_namespace();

    % define variables
    valid_ext = {'.tsv', '.mat', '.txt'};
    if nargin < 5
        sess_ids = {};
    end

    output.status = 1; % default status
    if bids_flag
        motion_files = fct_lib.recursdir(directory, pattern);
        sub_id = regexp(directory, '(sub-\w*\d+)', 'tokens'); % get subject entity
        if isempty(motion_files)
            warning('No motion files found in the directory %s.', directory);
            output.status = 0; % no file found
        elseif length(motion_files) > 1
            entities = determine_entities(motion_files, valid_ext, task, sub_id{1}{1});
            output.files = {entities.file};
            output.properties = entities;
        else
            output.files = motion_files;
        end
    else
        motion_files = fct_lib.recursdir(directory, pattern);
        preproc_parts = strsplit(directory, filesep);
        sub_id = preproc_parts{end};
        if isempty(motion_files)
            warning('No motion files found in the directory %s. Trying to search in rawdata folders.', directory);
            raw_directory = get_raw_from_preproc_dir(directory);
            motion_files = fct_lib.recursdir(raw_directory, pattern);
        end
        if isempty(motion_files)
            warning('No motion files found in the directory %s.', raw_directory);
            output.status = 0; % no file found
        elseif length(motion_files) > 1
            properties = find_files_in_subfolders(motion_files, task, sub_id, sess_ids);
            output.files = {properties.file};
            output.properties = properties;
        else
            output.files = motion_files;
        end
    end
end
