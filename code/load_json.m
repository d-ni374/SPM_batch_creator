function json_data = load_json(json_path_in)
    % Load a JSON file and return the data as a struct;
    % Called from SPM_batch_creator.m;
    % This scrtipt call the following functions:
    % - specs_namespace.m
    % - convert_to_cell_arrays.m
    %
    % INPUT
    % json_path: path to the JSON file
    % 
    % OUTPUT
    % json_data: struct with the data from the JSON file
    % 
    % Daniel Huber, University of Innbruck, 2024

    % import function library
    fct_lib = specs_namespace();

    % load json file
    json = jsondecode(fileread(json_path_in));

    % convert variables to cell arrays (necessary due to inconsistent translations of jsondecode/jsonencode, which lead to type mismatch errors)
    nodes = fct_lib.convert_to_cell_array(json.Nodes);
    nodes = convert_to_cell_arrays(nodes);
    try
        edges = fct_lib.convert_to_cell_array(json.Edges);
    catch
        warning('No edges defined in the json file.');
        edges = {};
    end

    % define output
    json_data.json = json;
    json_data.nodes = nodes;
    json_data.edges = edges;

end