function output = find_correct_file(properties, task, sub, ses_id, run_id)
    % this function filters a struct containing properties of available files
    % based on the task, subject, session, and run;
    % called from get_conditions_regressors.m
    % This script calls the following functions:
    % - specs_namespace.m
    %
    % INPUTS
    % properties: struct; properties of the files
    % task: string; task name
    % sub: string; subject name
    % ses_id: string; session id
    % run_id: string; run id
    %
    % OUTPUTS
    % file: string; path to the file
    %
    % EXAMPLE
    % file = find_correct_file(properties, 'foraging', 'sub-01', '01', '01')
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % filter for task
    if ~all(cellfun(@isempty, {properties.task})) && ~isempty(task)
        filtered_props = properties(strcmp({properties.task}, task));
    else
        filtered_props = properties;
    end
    
    % filter for subject
    if ~all(cellfun(@isempty, {filtered_props.sub})) && ~isempty(sub)
        filtered_props = filtered_props(strcmp({filtered_props.sub}, sub));
    end
    
    % filter for session
    if ~all(cellfun(@isempty, {filtered_props.ses})) && ~isempty(ses_id)
        filtered_props = filtered_props(strcmp({filtered_props.ses}, ses_id));
    end

    % filter for run
    if ~all(cellfun(@isempty, {filtered_props.run})) && ~isempty(run_id)
        filtered_props = filtered_props(strcmp({filtered_props.run}, run_id));
    end

    % check if only one file is left
    if isempty(filtered_props)
        warning('No file found for: "task: %s", "sub: %s", "ses_id: %s", "run_id: %s".', task, sub, ses_id, run_id);
        output.status = 0; % no file found
    elseif length(filtered_props) > 1
        warning('More than one file found for: "task: %s", "sub: %s", "ses_id: %s", "run_id: %s".', task, sub, ses_id, run_id);
        output.filtered_props = filtered_props;
        output.status = 2; % more than one file found
    else
        output.file = filtered_props.file;
        output.filtered_props = filtered_props;
        output.status = 1; % one file found
    end

end
