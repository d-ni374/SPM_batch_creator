function raw_dir = get_raw_from_preproc_dir(preproc_dir)
    % gets the raw directory from the preprocessed directory 
    % for a non-BIDS dataset;
    % called from find_events_files.m, find_motion_files_regexp.m, and 
    % find_multi_cond_files.m
    % 
    % INPUTS
    % preproc_dir: string; path to preprocessed directory
    % 
    % OUTPUTS
    % raw_dir: string; path to raw directory
    % 
    % EXAMPLE
    % raw_dir = get_raw_from_preproc_dir('path/to/preprocessed/directory')
    %
    % Daniel Huber, University of Innsbruck, 2024

    preproc_parts = strsplit(preproc_dir, filesep);
    preproc_idx = find(cellfun(@(x) strcmp(x, get_default_values('preproc_data_dir')), preproc_parts));
    if length(preproc_idx) > 1
        error('More than one preprocessed directory found in the path. Invalid folder structure.');
    end
    preproc_parts{preproc_idx} = get_default_values('raw_data_dir');

    % get the raw directory
    raw_dir = fullfile(preproc_parts{:});

    % check if the raw directory exists / look for alternative raw directory
    if ~isfolder(raw_dir)
        search_dir = fullfile(preproc_parts{1:preproc_idx});
        alt_dirs = strsplit(genpath(search_dir), ';'); % potential raw_dirs for subject
        for i = 1:length(alt_dirs)
            dir_split = strsplit(alt_dirs{i}, filesep);
            if strcmp(dir_split{end}, preproc_parts{end})
                raw_dir = alt_dirs{i};
                break;
            end
        end
    end

end