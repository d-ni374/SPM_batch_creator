function default_output_dir = get_default_output_dir(sub_folder_preproc, flag)
    % get_default_output_dir - Get default output directory
    % The flag "vis" is used to insert escape characters for visualization in the GUI.
    %
    % Usage:
    %   default_output_dir = get_default_output_dir(sub_folder_preproc, flag)
    %
    % Input:
    %   sub_folder_preproc (str) - Sub-folder for preprocessing
    %   flag (str) - Flag for visualization (default: 'none')
    %
    % Output:
    %   default_output_dir (str) - Default output directory for the first levels
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if nargin < 2
        flag = 'none';
    end
    subfolder_split = strsplit(sub_folder_preproc, filesep);
    if any(cellfun(@(x) strcmp(x, 'bidspm_preproc'), subfolder_split))
        bidspm_idx = find(cellfun(@(x) strcmp(x, 'bidspm_preproc'), subfolder_split));
        output_dir = fullfile(subfolder_split{1:bidspm_idx(end)-1}); % takes the last "bidspm_preproc" directory in folder structure if there were multiple
        default_output_dir = fullfile(output_dir, 'stats');
    elseif any(cellfun(@(x) strcmp(x, get_default_values('preproc_data_dir')), subfolder_split))
        preproc_idx = find(cellfun(@(x) strcmp(x, get_default_values('preproc_data_dir')), subfolder_split));
        output_dir = fullfile(subfolder_split{1:preproc_idx(end)-1}); % takes the last "preprocessed" directory in folder structure if there were multiple
        default_output_dir = fullfile(output_dir, get_default_values('first_level_dir'));
    else
        if length(subfolder_split) > 3
            output_dir = fullfile(subfolder_split{1:end-2});
        elseif length(subfolder_split) == 3
            output_dir = fullfile(subfolder_split{1:end-1});
        else
            output_dir = sub_folder_preproc;
        end
        default_output_dir = fullfile(output_dir, 'stats');
    end
    % fix escape characters
    default_output_dir = strrep(default_output_dir, '\', '/');
    if flag == "vis"
        default_output_dir = strrep(default_output_dir, '_', '\_');
    end

end