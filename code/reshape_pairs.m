function reshaped_pairs = reshape_pairs(value_pairs)
    % This function reshapes the pairs (e.g. covariates), which are originally 
    % stored in a cell array, where each pair occupies two rows, into a cell 
    % array where each pair is stored in a single row.
    % Inverse function of reshape_values.m
    % Called from get_paths_lv2.m
    %
    % Daniel Huber, University of Innsbruck, Nov 2024

    reshaped_pairs = cell(size(value_pairs, 1)/2, size(value_pairs, 2) * 2);
    for i = 1:size(value_pairs, 1)
        for j = 1:size(value_pairs, 2)
            if mod(i, 2) == 1
                reshaped_pairs{(i-1)/2+1, j} = value_pairs{i, j};
            else
                reshaped_pairs{i/2, j + size(value_pairs, 2)} = value_pairs{i, j};
            end
        end
    end

end