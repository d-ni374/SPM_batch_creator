function path_out = check_path(path_in)
    % this function checks if a file already exists and adds a number to the
    % filename if it does
    
    [path, name, ext] = fileparts(path_in);
    path_out = path_in;
    if exist(path_out, 'file')
        i = 1;
        while exist(path_out, 'file')
            path_out = fullfile(path, [name, '_', num2str(i), ext]);
            i = i + 1;
        end
    end

end