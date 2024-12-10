function output = get_contrast_index(SPM, contrast_name, input_file_type)
    % Get the contrast index;
    % Called from get_contrast_file_paths.m and get_subject_file_paths.m;
    % Inputs:
    %   SPM: the SPM structure
    %   contrast_name: the contrast name
    %   input_file_type: the input file type
    % Outputs:
    %   contrast_index: the contrast index
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if input_file_type == "beta"
        beta_list = {SPM.Vbeta.fname};
        beta_desc = {SPM.Vbeta.descrip};
        beta_desc_idx = cellfun(@(x) regexp(x, ' - ', 'once'), beta_desc, 'UniformOutput', false);
        beta_desc_ = cell(length(beta_desc), 1);
        for i = 1:length(beta_desc)
            beta_desc_{i} = beta_desc{i}(beta_desc_idx{i}+3:end);
        end
        contrast_index = find(ismember(beta_desc_, contrast_name));
        if isempty(contrast_index)
            %warning('The contrast name %s does not exist in the beta files.', contrast_name);
            file_name = '';
        else
            file_name = beta_list{contrast_index};
        end
    else
        con_list = {SPM.xCon.name};
        contrast_index = find(ismember(con_list, contrast_name));
        if isempty(contrast_index)
            %warning('The contrast name %s does not exist in the contrast files.', contrast_name);
            file_name = '';
        else
            if input_file_type == "con" || input_file_type == "ess"
                file_name = SPM.xCon(contrast_index).Vcon.fname;
            end
        end
    end

    output.contrast_index = contrast_index;
    output.file_name = file_name;

end
