function participants_data = read_participants_file(participants_file_path, covariates_names)
    % This function reads the participants.tsv file and returns the data;
    % called from get_covariates.m
    % This script calls the following functions:
    % - convert_categories_to_double.m
    % 
    % INPUTS
    % participants_file_path: string; path to the participants.tsv file
    % covariates_names: optional cell array; list of column names of covariates
    %
    % OUTPUTS
    % participants_data: table; participants data
    %
    % EXAMPLE
    % participants_data = read_participants_file('participants.tsv')
    %
    % Daniel Huber, University of Innsbruck, November 2024

    status = true;
    % read file
    if ~exist(participants_file_path, 'file')
        warning('The file %s does not exist.', participants_file_path);
        participants_data.status = false;
        return
    else
        data = readtable(participants_file_path, "FileType", "text", "Delimiter", "\t", "NumHeaderLines", 0, "TreatAsMissing", get_default_values('missing_data_indicator'));
    end
    if isempty(data)
        warning('No data found in the file %s.', participants_file_path);
        participants_data.status = false;
        return
    else
        % validate data
        if ~ismember('participant_id', data.Properties.VariableNames)
            warning('Missing required column "participant_id" in the file %s.', participants_file_path);
            participants_data.status = false;
            return
        end
        % validate covariates
        cov_json_idx = 1:length(covariates_names); % to keep track of the indices of the covariates
        for i = length(covariates_names):-1:1
            if ~ismember(covariates_names{i}, data.Properties.VariableNames)
                warning('Missing covariate "%s" in the file %s.', covariates_names{i}, participants_file_path);
                covariates_names(i) = [];
                cov_json_idx(i) = [];
                status = false;
            end
        end
    end

    % check and modify the format of the participant_id
    if isa(data.('participant_id'), 'double') % convert to cell array of char in case of double
        data.('participant_id') = num2cell(data.('participant_id'));
        data.('participant_id') = cellfun(@(x) num2str(x), data.('participant_id'), 'UniformOutput', false);
    end
    data.('participant_id') = strip(data.('participant_id'), ''''); % remove quotes from the participant_id (might be the case for numeric quoted IDs)

    % get column indices for all required parameters
    idx_sub_id = find(strcmp(data.Properties.VariableNames, 'participant_id'));
    % get column indices for covariates
    idx_covariates = cell(1, length(covariates_names));
    for i = 1:length(covariates_names)
        idx_covariates{i} = find(strcmp(data.Properties.VariableNames, covariates_names{i}));
    end
    % filter data
    data = data(:, [idx_sub_id, idx_covariates{:}]);
    
    % exclude incomplete rows
    idx = find(any(ismissing(data), 2));
    if ~isempty(idx)
        for i = 1:length(idx)
            fprintf('Excluding participant %s: incomplete data in the file %s.\n', data.('participant_id'){idx(i)}, participants_file_path);
        end
        data(idx, :) = [];
        status = false;
    end

    % get participants data
    participants_data.covariates_names = covariates_names;
    participants_data.cov_json_idx = cov_json_idx;
    participants_data.participant_id = data.('participant_id');
    cov_categories = {};
    for i = 1:length(covariates_names)
        participants_data.covariates_data_orig{i} = data.(covariates_names{i});
        if isa(data.(covariates_names{i}), 'cell')
            try
                data.(covariates_names{i}) = cellfun(@str2num, data.(covariates_names{i}));
            catch
                warning('Covariate "%s" is not numeric in the file %s.', covariates_names{i}, participants_file_path);
                conversion = convert_categories_to_double(data.(covariates_names{i}), cov_categories);
                cov_categories = conversion.categories;
                data.(covariates_names{i}) = conversion.data;
            end
        end
        participants_data.covariates_data{i} = data.(covariates_names{i});
    end

    participants_data.status = status;
    participants_data.covariates_names = covariates_names;

end