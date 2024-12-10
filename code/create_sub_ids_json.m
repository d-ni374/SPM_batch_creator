function text = create_sub_ids_json(sub_ids, out_pth)
    % This script takes a cell array of subject IDs and creates a '","' 
    % separated string of the IDs which is returned as the output. The output 
    % can be used to manually create a JSON file with the subject IDs (copy
    % the text output to the json template).
    %
    % INPUTS
    % sub_ids: cell array; list of subject IDs
    % out_pth: string; path to the output file (optional)
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % extract subject IDs, if input are directories
    if isfolder(sub_ids{1})
        sub_folders = sub_ids;
        sub_ids = cell(length(sub_folders), 1);
        for i = 1:length(sub_folders)
            sub_dir_split = split(sub_folders{i}, '\');
            sub_ids{i} = sub_dir_split{end};
        end
    end
    % convert cell array to string
    text = strjoin(sub_ids, '","');
    text = ['"', text, '"'];

    if nargin == 2
        % save the string to a txt file
        fid = fopen(out_pth, 'w');
        fprintf(fid, text);
        fclose(fid);
    end

end