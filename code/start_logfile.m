function start_logfile(nodes, node_idx, instruction_idx)
% This function starts a logfile of the console output.
% Called from json_validator_bids_values.m
%
% Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    try
        log_path = fullfile(nodes{node_idx}.Transformations.Instructions{instruction_idx}.Input.OutputDirectory, 'matlab_log.txt');
        fct_lib.save_log('start', log_path);
    catch
        warning('Output directory not defined. Logfile will be saved in the current directory.');
        fct_lib.save_log('start');
    end

end
