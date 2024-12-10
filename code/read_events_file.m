function events = read_events_file(filename, parametric_modulators)
    % This function reads the events file and returns the events;
    % called from get_conditions_regressors.m
    % This script calls the following functions:
    % - convert_categories_to_double.m
    % 
    % INPUTS
    % filename: string; path to the events file
    % parametric_modulators: optional cell array; list of parametric modulators
    %
    % OUTPUTS
    % events: struct; event related data: onset, duration, trial_type, parametric modulators;
    %
    % EXAMPLE
    % events = read_events_file('sub-01_task-foraging_run-01_events.tsv')
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    % read file
    try
        data = readtable(filename, "FileType", "text", "Delimiter", "\t", "NumHeaderLines", 0, "TreatAsMissing", get_default_values('missing_data_indicator'));
    catch
        warning('The file %s could not be read (.tsv file required).', filename);
        events.status = false;
        return
    end
    status = true;
    if isempty(data)
        warning('No data found in the file %s.', filename);
        status = false;
    else
        % validate data
        if ~all(ismember({'onset', 'duration', 'trial_type'}, data.Properties.VariableNames))
            warning('Missing required columns in the file %s.', filename);
            status = false;
        end
        if nargin > 1
            % validate parametric modulators
            pmod_json_idx = 1:length(parametric_modulators); % to keep track of the indices of the parametric modulators
            for i = length(parametric_modulators):-1:1
                if ~ismember(parametric_modulators{i}, data.Properties.VariableNames)
                    warning('Missing parametric modulator "%s" in the file %s.', parametric_modulators{i}, filename);
                    parametric_modulators(i) = [];
                    pmod_json_idx(i) = [];
                    status = false;
                end
            end
            events.parametric_modulators = parametric_modulators;
            events.pmod_json_idx = pmod_json_idx;
        end
        % get column indices for all required parameters
        idx_onset = find(strcmp(data.Properties.VariableNames, 'onset'));
        idx_duration = find(strcmp(data.Properties.VariableNames, 'duration'));
        idx_trial_type = find(strcmp(data.Properties.VariableNames, 'trial_type'));
        if nargin > 1
            idx_parametric_modulators = cell(1, length(parametric_modulators));
            for i = 1:length(parametric_modulators)
                idx_parametric_modulators{i} = find(strcmp(data.Properties.VariableNames, parametric_modulators{i}));
            end
            % filter data
            data = data(:, [idx_onset, idx_duration, idx_trial_type, idx_parametric_modulators{:}]);
        else
            data = data(:, [idx_onset, idx_duration, idx_trial_type]);
        end
        % exclude incomplete rows
        idx = any(ismissing(data), 2);
        if sum(idx) > 0
            warning('Excluding %d incomplete row(s) in the file %s.', sum(idx), filename);
            data(idx, :) = [];
            status = false;
        end
        % get event data
        events.trial_type = unique(data.('trial_type'));
        for i = 1:length(events.trial_type)
            idx = strcmp(data.('trial_type'), events.trial_type{i});
            idx = find(idx);
            % get onsets, durations, and parametric modulators
            onsets = zeros(1, length(idx));
            durations = zeros(1, length(idx));
            if nargin > 1
                for k = 1:length(parametric_modulators)
                    events.parametric_modulators_data{i, k} = [];
                end
            end
            for j = 1:length(idx)
                onsets(j) = data.('onset')(idx(j));
                durations(j) = data.('duration')(idx(j));
                if nargin > 1
                    for k = 1:length(parametric_modulators)
                        events.parametric_modulators_data{i, k} = [events.parametric_modulators_data{i, k}, data.(parametric_modulators{k})(idx(j))];
                    end
                end
            end
            events.onsets{i, 1} = onsets;
            events.durations{i, 1} = durations;
        end
        if isfield(events, 'parametric_modulators_data')
            categories = {};
            for i = 1:size(events.parametric_modulators_data, 1)
                for j = 1:size(events.parametric_modulators_data, 2)
                    if isa(events.parametric_modulators_data{i, j}, 'cell')
                        try
                            events.parametric_modulators_data{i, j} = cellfun(@str2num, events.parametric_modulators_data{i, j});
                        catch
                            warning('Parametric modulator "%s" is not numeric in the file %s.', parametric_modulators{j}, filename);
                            conversion = convert_categories_to_double(events.parametric_modulators_data{i, j}, categories);
                            categories = conversion.categories;
                            events.parametric_modulators_data{i, j} = conversion.data;
                        end
                    end
                end
            end
        end
    end
    events.status = status;

end