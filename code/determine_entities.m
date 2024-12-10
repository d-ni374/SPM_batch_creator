function entities = determine_entities(files, valid_ext, task, sub)
    % determines the entities in a list of files; applicable for BIDS datasets only;
    % called from find_motion_files_regexp.m, find_events_files.m, and 
    % find_multi_cond_files.m
    % 
    % INPUTS
    % files: cell array; list of files
    % valid_ext: cell array; list of valid file extensions
    % task: string; task name
    % sub: string; subject name
    % 
    % OUTPUTS
    % entities: struct; entities in the files
    % 
    % EXAMPLE
    % entities = determine_entities(files)
    %
    % Daniel Huber, University of Innsbruck, 2024

    % define variables
    entities = struct('sub', {}, 'ses', {}, 'task', {}, 'run', {}, 'file', {}, 'ext', {});

    % determine entities
    for i = 1:length(files)
        entities(i).file = files{i};
        % get file parts
        [~, name, ext] = fileparts(files{i});
        entities(i).ext = ext;
        % get tokens
        runs = regexp(name, '_run-(\w*\d+)_', 'tokens');
        sess = regexp(name, '_ses-(\w*\d+)_', 'tokens');
        tasks = regexp(name, '_task-(\w+)_', 'tokens');
        subs = regexp(name, '(sub-\w*\d+)_', 'tokens');
        if ~isempty(runs)
            entities(i).run = runs{1}{1};
        end
        if ~isempty(sess)
            entities(i).ses = sess{1}{1};
        end
        if ~isempty(tasks)
            entities(i).task = tasks{1}{1};
        end
        if ~isempty(subs)
            entities(i).sub = subs{1}{1};
        end
    end
    % delete entries with wrong extension
    for i = length(entities):-1:1
        if ~any(strcmp(entities(i).ext, valid_ext))
            entities(i) = [];
        end
    end
    % delete entries with wrong task
    for i = length(entities):-1:1
        if ~isempty(entities(i).task)
            if ~strcmp(entities(i).task, task)
                entities(i) = [];
            end
        end
    end
    % delete entries with wrong sub
    for i = length(entities):-1:1
        if ~isempty(entities(i).task)
            if ~strcmp(entities(i).sub, sub)
                entities(i) = [];
            end
        end
    end
    
end