function status = convert_mov_tsv_to_mat(mov_file_path, check_size)
    % convert_mov_tsv_to_mat converts a tsv file containing motion parameters to a mat file;
    % called from multi_reg_validation.m
    % This script calls the following functions:
    % - replace_nan.m
    %
    % This function converts a tsv file containing motion parameters to a mat file.
    % The tsv file is expected to contain 6 or more columns with the confounder names in 
    % the first row. If the first row contains data, the confounders will be automatically 
    % named 'R1', 'R2', etc. in the SPM software.
    % The mat file will contain two variables: cell array 'names' contains confounder names, 
    % and matrix 'R' contains the motion parameters.
    % If the first row contains data, the variable 'names' will not be created.
    % The length of the confounder data must match the number of images given by check_size. 
    % If the movement data contain NaN values, they will be replaced by zeros.
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if ~exist(mov_file_path, 'file')
        error('The file %s does not exist.', mov_file_path);
    end
    [path, name, ext] = fileparts(mov_file_path);
    if ~strcmp(ext, '.tsv')
        warning('The file %s can not be processed since it is not a tsv file.', mov_file_path);
        status = false;
        return
    else
        data = readtable(mov_file_path, "FileType", "text", "Delimiter", "\t");
        if isempty(data)
            warning('No data found in the file %s.', mov_file_path);
            status = false;
        else
            % get confounder names
            if size(data, 1) == check_size
                names = data.Properties.VariableNames;
            elseif size(data, 1) == check_size - 1
                names = cell(1, size(data, 2));
                for i = 1:size(data, 2)
                    names{i} = sprintf('R%d', i);
                end
                data = readtable(mov_file_path, "FileType", "text", "Delimiter", "\t", "ReadVariableNames", false);
            else
                warning('The number of rows in the file %s does not match the number of images.', mov_file_path);
                status = false;
                return
            end
            % get motion parameters
            R = table2array(data);
            
            % remove NaN values
            R_ = replace_nan(R, mov_file_path); % NaN are replaced by zeros
            R = R_.R;
            
            % save mat file
            save(fullfile(path, strcat(name, '.mat')), "names", "R");
            status = true;
        end
    end

end
