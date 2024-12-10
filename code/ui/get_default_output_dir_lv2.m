function default_output_dir_lv2 = get_default_output_dir_lv2(output_dir_lv1, flag)
    % get_default_output_dir_lv2 - Get default output directory
    % The flag "vis" is used to insert escape characters for visualization in the GUI.
    %
    % Usage:
    %   default_output_dir_lv2 = get_default_output_dir_lv2(output_dir_lv1, flag)
    %
    % Input:
    %   output_dir_lv1 (str) - Output directory of the first levels
    %   flag (str) - Flag for visualization (default: 'none')
    %
    % Output:
    %   default_output_dir_lv2 (str) - Default output directory for the second levels
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if nargin < 2
        flag = 'none';
    end
    output_dir_lv1 = strrep(output_dir_lv1, '\', '/');
    output_dir_lv1_split = strsplit(output_dir_lv1, '/');
    if any(cellfun(@(x) strcmp(x, 'bidspm_stats'), output_dir_lv1_split))
        bidspm_idx = find(cellfun(@(x) strcmp(x, 'bidspm_stats'), output_dir_lv1_split));
        output_dir = fullfile(output_dir_lv1_split{1:bidspm_idx(end)-1}); % takes the last bidspm_stats directory in folder structure if there were multiple
        default_output_dir_lv2 = fullfile(output_dir, 'group_stats');
    elseif any(cellfun(@(x) strcmp(x, get_default_values('first_level_dir')), output_dir_lv1_split))
        preproc_idx = find(cellfun(@(x) strcmp(x, get_default_values('first_level_dir')), output_dir_lv1_split));
        output_dir = fullfile(output_dir_lv1_split{1:preproc_idx(end)-1}); % takes the last "first_levels" directory in folder structure if there were multiple
        default_output_dir_lv2 = fullfile(output_dir, get_default_values('second_level_dir'));
    else
        if length(output_dir_lv1_split) > 2
            output_dir = fullfile(output_dir_lv1_split{1:end-1});
        else
            output_dir = output_dir_lv1;
        end
        default_output_dir_lv2 = fullfile(output_dir, 'group_stats');
    end
    % fix escape characters
    default_output_dir_lv2 = strrep(default_output_dir_lv2, '\', '/');
    if flag == "vis"
        default_output_dir_lv2 = strrep(default_output_dir_lv2, '_', '\_');
    end

end