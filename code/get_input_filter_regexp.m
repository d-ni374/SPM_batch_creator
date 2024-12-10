function input_filter_regexp = get_input_filter_regexp(input_file_type)
    % Get the input filter regular expression;
    % Called from get_contrast_file_paths.m
    % Inputs:
    %   input_file_type: the input file type
    % Outputs:
    %   input_filter_regexp: the input filter regular expression
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if strcmpi(input_file_type, 'con')
        input_filter_regexp = '^con.*\.nii$';
    elseif strcmpi(input_file_type, 'ess')
        input_filter_regexp = '^ess.*\.nii$';
    elseif strcmpi(input_file_type, 'beta')
        input_filter_regexp = '^beta.*\.nii$';
    elseif strcmpi(input_file_type, 'other')
        input_filter_regexp = '';
    else
        error('Unknown input file type: %s.', input_file_type);
    end
end