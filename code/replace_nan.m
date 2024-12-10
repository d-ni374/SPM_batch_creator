function output = replace_nan(R, mov_file_path)
    % This function replaces NaN values in a number array with a predefined value;
    % called from multi_reg_validation.m and convert_mov_tsv_to_mat.m
    % INPUTS
    % R: number array of movement parameters
    % mov_file_path: string; path to the movement parameters file
    %
    % OUTPUTS
    % output.R: number array; array of strings with NaN values replaced
    %
    % Daniel Huber, University of Innsbruck, November 2024

    output.R = R;
    output.replace = false;

    % remove NaN values
    if any(isnan(output.R(:)))
        output.replace = true;
        warning('NaN values found in the file %s. Replacing NaN values by zeros.', mov_file_path);
        output.R(isnan(output.R)) = 0;
    end
    
end