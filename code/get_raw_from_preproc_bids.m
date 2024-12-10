function raw_dir = get_raw_from_preproc_bids(preproc_dir, sub)
    % gets the raw directory from the preprocessed directory
    % for a BIDS dataset;
    % called from find_multi_cond_files.m and find_events_files.m
    %
    % INPUTS
    % preproc_dir: string; path to preprocessed directory
    % sub: string; subject name
    % 
    % OUTPUTS
    % raw_dir: string; path to raw directory
    % 
    % EXAMPLE
    % raw_dir = get_raw_from_preproc_bids('path/to/preprocessed/directory', 'sub-01')
    %
    % Daniel Huber, University of Innsbruck, 2024

    preproc_parts = strsplit(preproc_dir, filesep);
    preproc_idx = find(cellfun(@(x) strcmp(x, 'derivatives'), preproc_parts));
    if length(preproc_idx) > 1
        preproc_idx = min(preproc_idx);
    end

    % get the raw directory
    raw_dir = fullfile(preproc_parts{1:preproc_idx-1}, sub);

    % check if the raw directory exists
    if ~isfolder(raw_dir)
        warning('Raw directory %s not found.', raw_dir);
    end

end