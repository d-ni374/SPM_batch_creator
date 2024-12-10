function output = find_multi_cond_files(directory, pattern, task, bids_flag, sess_ids)
    % finds a file containing multiple conditions according to SPM12 definition in a 
    % directory that match a regular expression pattern;
    % called from get_conditions_regressors.m
    % This script calls the following functions:
    % - specs_namespace.m
    % - determine_entities.m
    % - find_files_in_subfolders.m
    % - get_raw_from_preproc_dir.m
    % - get_raw_from_preproc_bids.m
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
    % files = find_files_regexp('subjectPreprocDir', 'conditions.*mat$', 'foraging', true, {'01', '02'})
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if isempty(pattern)
        output.status = 0; % no file found
        return
    end

    % import function library
    fct_lib = specs_namespace();

    % define variables
    valid_ext = {'.mat'};
    if nargin < 5
        sess_ids = {};
    end

    output.status = 1; % default status
    if bids_flag
        sub_id = regexp(directory, '(sub-\w*\d+)', 'tokens'); % get subject entity
        raw_directory = get_raw_from_preproc_bids(directory, sub_id{1}{1});
        multi_cond_files = fct_lib.recursdir(raw_directory, pattern);
        if isempty(multi_cond_files)
            warning('No multiple conditions files found in the directory %s.', raw_directory);
            output.status = 0; % no file found
        elseif length(multi_cond_files) > 1
            entities = determine_entities(multi_cond_files, valid_ext, task, sub_id{1}{1});
            output.files = {entities.file};
            output.properties = entities;
        else
            output.files = multi_cond_files;
        end
    else
        raw_directory = get_raw_from_preproc_dir(directory);
        preproc_parts = strsplit(directory, filesep);
        sub_id = preproc_parts{end};
        multi_cond_files = fct_lib.recursdir(raw_directory, pattern);
        if isempty(multi_cond_files)
            warning('No multiple conditions files found in the directory %s. Trying to search in preprocessed folders.', raw_directory);
            multi_cond_files = fct_lib.recursdir(directory, pattern);
        end
        if isempty(multi_cond_files)
            warning('No multiple conditions files found in the directory %s.', directory);
            output.status = 0; % no file found
        elseif length(multi_cond_files) > 1
            properties = find_files_in_subfolders(multi_cond_files, task, sub_id, sess_ids);
            output.files = {properties.file};
            output.properties = properties;
        else
            output.files = multi_cond_files;
        end
    end