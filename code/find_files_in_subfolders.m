function properties = find_files_in_subfolders(files, task, sub_id, sess_ids)
    % find correct files in the folder structure of a single subject;
    % this function is only applied to non-BIDS datasets;
    % called from find_motion_files_regexp.m, find_events_files.m, and 
    % find_multi_cond_files.m
    % This script calls the following functions:
    % - session_assignation.m
    %
    % INPUTS
    % files: cell array; list of files
    % task: string; task name
    % sub_id: string; subject name
    % sess_ids: cell array; list of session ids
    %
    % OUTPUTS
    % properties: struct; properties of the files
    %
    % EXAMPLE
    % properties = find_motion_files_subfolders(file_paths, 'foraging', 'sub-01', {'01', '02'})
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    % define variables
    properties = struct('sub', {}, 'ses', {}, 'task', {}, 'run', {}, 'file', {}, 'ext', {});
    valid_ext = {'.tsv', '.mat', '.txt'};
    task_regexp = ['(', task, ')'];
    sub_regexp = ['(', sub_id, ')'];
    if ~isempty(sess_ids) && ~isempty(sess_ids{1})
        sess_ids_regexp = strjoin(string(sess_ids), '$|');
    end

    % determine properties
    for i = 1:length(files)
        properties(i).file = files{i};
        file_parts = strsplit(files{i}, filesep);
        % get file parts
        [~, name, ext] = fileparts(files{i});
        properties(i).ext = ext;
        % get tokens
        runs = regexpi(name, 'run[-_]*(\d+)', 'tokens');
        tasks = regexpi(name, task_regexp, 'tokens');
        subs = regexpi(name, sub_regexp, 'tokens');
        if ~isempty(sess_ids) && ~isempty(sess_ids{1})
            sess = regexp(file_parts(1:end-1), strcat(sess_ids_regexp, '$'), 'match'); % session_id needs to match end of sub-folder name
            if sum(~cellfun(@isempty, regexp(sess_ids, '[a-zA-Z]$'))) == length(sess_ids) % check if session_id ends with a letter
                % the character before the session_id must not be a letter in this case
                ses_val = ~cellfun(@isempty, regexp(file_parts(1:end-1), strcat('[0-9-_](', sess_ids_regexp, ')$'), 'tokens'));
                properties = session_assignation(properties, i, ses_val, sess, file_parts, files);
            elseif sum(~cellfun(@isempty, regexp(sess_ids, '[0-9]$'))) == length(sess_ids) % check if session_id ends with a number
                % the character before the session_id must not be a number in this case
                ses_val = ~cellfun(@isempty, regexp(file_parts(1:end-1), strcat('[a-zA-Z-_](', sess_ids_regexp, ')$'), 'tokens'));
                properties = session_assignation(properties, i, ses_val, sess, file_parts, files);
            else
                error('Invalid session_id format. All session_ids need to end with letter OR number.');
            end
        else
            run_idx_match = cellfun(@(x) regexpi(x, 'run[-_]*(\d+)', 'tokens'), file_parts(1:end-1), 'UniformOutput', false);
            run_idx = find(~cellfun(@isempty, run_idx_match));
            if length(run_idx) > 1
                warning('Ambiguous folder naming. Cannot assign the file %s to a single run.', files{i});
            else
                if run_idx
                    properties(i).run = run_idx_match{run_idx}{1};
                end
            end
        end
        if ~isempty(runs)
            if length(runs) > 1 && ~all(cellfun(@(x) strcmp(x, runs{1}), runs)) % check if all runs are the same
                warning('Ambiguous file naming. Cannot assign the file %s to a single run.', files{i});
            else
                if ~isempty(properties(i).run) && ~strcmp(properties(i).run, runs{1})
                    warning('Ambiguous file naming. The file name of %s does not match its run folder name.', files{i});
                end 
                properties(i).run = runs{1}{1};
            end
        end
        if ~isempty(tasks)
            properties(i).task = tasks{1}{1};
        end
        if ~isempty(subs)
            properties(i).sub = subs{1}{1};
        end
    end
    % delete entries with wrong extension
    for i = length(properties):-1:1
        if ~any(strcmp(properties(i).ext, valid_ext))
            properties(i) = [];
        end
    end
    % delete entries with wrong task
    for i = length(properties):-1:1
        if ~isempty(properties(i).task)
            if ~strcmp(properties(i).task, task)
                properties(i) = [];
            end
        end
    end
    % delete entries with wrong sub
    for i = length(properties):-1:1
        if ~isempty(properties(i).sub)
            if ~strcmp(properties(i).sub, sub)
                properties(i) = [];
            end
        end
    end
end