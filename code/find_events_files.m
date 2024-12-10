function output = find_events_files(directory, pattern, task, bids_flag, sess_ids)
    % finds files in a directory that match a regular expression pattern;
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
    % files = find_files_regexp('subjectPreprocDir', '_events.tsv$', 'foraging', true, {'01', '02'})
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % define variables
    valid_ext = {'.tsv'};
    if nargin < 5
        sess_ids = {};
    end

    output.status = 1; % default status
    if bids_flag
        sub_id = regexp(directory, '(sub-\w*\d+)', 'tokens'); % get subject entity
        raw_directory = get_raw_from_preproc_bids(directory, sub_id{1}{1});
        events_files = fct_lib.recursdir(raw_directory, pattern);
        if isempty(events_files)
            warning('No events files found in the directory %s.', raw_directory);
            output.status = 0; % no file found
        elseif length(events_files) > 1
            entities = determine_entities(events_files, valid_ext, task, sub_id{1}{1});
            output.files = {entities.file};
            output.properties = entities;
        else
            output.files = events_files;
        end
    else
        preproc_parts = strsplit(directory, filesep);
        sub_id = preproc_parts{end};
        try % try block to avoid errors if the raw directory is not found
            raw_directory = get_raw_from_preproc_dir(directory);
            events_files = fct_lib.recursdir(raw_directory, pattern);
            if isempty(events_files)
                warning('No events files found in the directory %s. Trying to search in preprocessed folders.', raw_directory);
                events_files = fct_lib.recursdir(directory, pattern);
            end
        catch
            warning('No raw directory found for the subject %s. Trying to search in preprocessed folders.', sub_id);
            events_files = fct_lib.recursdir(directory, pattern);
        end
        if isempty(events_files)
            warning('No events files found in the directory %s.', directory);
            output.status = 0; % no file found
        elseif length(events_files) > 1
            properties = find_files_in_subfolders(events_files, task, sub_id, sess_ids);
            output.files = {properties.file};
            output.properties = properties;
        else
            output.files = events_files;
        end
    end