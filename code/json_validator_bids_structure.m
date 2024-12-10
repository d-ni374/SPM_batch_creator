function output = json_validator_bids_structure(json, nodes, edges)
    % Validate a json file for its compatibility with the BIDS Stats Models Specification;
    % Called from bids_validation_json.m
    %
    % Daniel Huber, University of Innsbruck, Novemeber 2024

    % import function library
    fct_lib = specs_namespace();

    % check if required fields are present
    validation_status = true;
    validation_status = fct_lib.check_structure_field(json, 'Name', inputname(1)) && validation_status;
    validation_status = fct_lib.check_structure_field(json, 'BIDSModelVersion', inputname(1)) && validation_status;
    validation_status = fct_lib.check_structure_field(json, 'Input', inputname(1)) && validation_status; % not required for BIDS, but for SPM
    validation_status = fct_lib.check_structure_field(json, 'Nodes', inputname(1)) && validation_status;

    % check Input fields (not required for BIDS)
    if isfield(json, 'Input')
        valid_fields = {'task', 'run', 'session', 'subject'}; % might be extended in the future
        entries = fieldnames(json.Input);
        for i = 1:length(entries)
            validation_status = fct_lib.check_options(entries{i}, valid_fields, sprintf('%s.Input.%s', inputname(1), entries{i})) && validation_status;
        end
    end

    % check if all nodes are valid
    if isempty(nodes)
        validation_status = false;
        warning('No nodes found in the json file.');
    else
        for i = 1:length(nodes)
            validation_status = fct_lib.check_structure_field(nodes{i}, 'Level', sprintf('%s.Nodes{%d}', inputname(1), i)) && validation_status;
            validation_status = fct_lib.check_structure_field(nodes{i}, 'Name', sprintf('%s.Nodes{%d}', inputname(1), i)) && validation_status;
            validation_status = fct_lib.check_structure_field(nodes{i}, 'GroupBy', sprintf('%s.Nodes{%d}', inputname(1), i)) && validation_status;
            validation_status = fct_lib.check_structure_field(nodes{i}, 'Transformations', sprintf('%s.Nodes{%d}', inputname(1), i)) && validation_status; % not required for BIDS, but for SPM
            if isfield(nodes{i}, 'Transformations')
                validation_status = fct_lib.check_structure_field(nodes{i}.Transformations, 'Transformer', sprintf('%s.Nodes{%d}.Transformations', inputname(1), i)) && validation_status;
                validation_status = fct_lib.check_structure_field(nodes{i}.Transformations, 'Instructions', sprintf('%s.Nodes{%d}.Transformations', inputname(1), i)) && validation_status;
                if isfield(nodes{i}.Transformations, 'Instructions') % not required for BIDS, but for SPM -> contains parameters for batch creation
                    for j = 1:length(nodes{i}.Transformations.Instructions)
                        validation_status = fct_lib.check_structure_field(nodes{i}.Transformations.Instructions{j}, 'Name', sprintf('%s.Nodes{%d}.Transformations.Instructions{%d}', inputname(1), i, j)) && validation_status;
                        validation_status = fct_lib.check_structure_field(nodes{i}.Transformations.Instructions{j}, 'Input', sprintf('%s.Nodes{%d}.Transformations.Instructions{%d}', inputname(1), i, j)) && validation_status;
                    end
                end
            end
            validation_status = fct_lib.check_structure_field(nodes{i}, 'Model', sprintf('%s.Nodes{%d}', inputname(1), i)) && validation_status;
            if isfield(nodes{i}, 'Model')
                validation_status = fct_lib.check_structure_field(nodes{i}.Model, 'Type', sprintf('%s.Nodes{%d}.Model', inputname(1), i)) && validation_status;
                validation_status = fct_lib.check_structure_field(nodes{i}.Model, 'X', sprintf('%s.Nodes{%d}.Model', inputname(1), i)) && validation_status;
                if isfield(nodes{i}.Model, 'HRF') % not required for BIDS, but for event related analyses
                    validation_status = fct_lib.check_structure_field(nodes{i}.Model.HRF, 'Model', sprintf('%s.Nodes{%d}.Model.HRF', inputname(1), i)) && validation_status;
                    validation_status = fct_lib.check_structure_field(nodes{i}.Model.HRF, 'Variables', sprintf('%s.Nodes{%d}.Model.HRF', inputname(1), i)) && validation_status;
                end
            end
            if isfield(nodes{i}, 'Contrasts')
                for j = 1:length(nodes{i}.Contrasts)
                    validation_status = fct_lib.check_structure_field(nodes{i}.Contrasts{j}, 'Name', sprintf('%s.Nodes{%d}.Contrasts{%d}', inputname(1), i, j)) && validation_status;
                    validation_status = fct_lib.check_structure_field(nodes{i}.Contrasts{j}, 'ConditionList', sprintf('%s.Nodes{%d}.Contrasts{%d}', inputname(1), i, j)) && validation_status;
                    validation_status = fct_lib.check_structure_field(nodes{i}.Contrasts{j}, 'Test', sprintf('%s.Nodes{%d}.Contrasts{%d}', inputname(1), i, j)) && validation_status;
                end
            end
            if isfield(nodes{i}, 'DummyContrasts')
                validation_status = fct_lib.check_structure_field(nodes{i}.DummyContrasts, 'Test', sprintf('%s.Nodes{%d}.DummyContrasts', inputname(1), i)) && validation_status;
                validation_status = fct_lib.check_structure_field(nodes{i}.DummyContrasts, 'Contrasts', sprintf('%s.Nodes{%d}.DummyContrasts', inputname(1), i)) && validation_status; % not required for BIDS
            end
        end
    end

    % check if all edges are valid
    if ~isempty(edges) %exist('edges', 'var')
        for i = 1:length(edges)
            validation_status = fct_lib.check_structure_field(edges{i}, 'Source', sprintf('%s.Edges{%d}', inputname(1), i)) && validation_status;
            validation_status = fct_lib.check_structure_field(edges{i}, 'Destination', sprintf('%s.Edges{%d}', inputname(1), i)) && validation_status;
        end
    end

    % create output
    output.validation_status = validation_status;
    %output.nodes = nodes;
    %output.edges = edges;

end