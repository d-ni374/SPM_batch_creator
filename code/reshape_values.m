function vector = reshape_values(pair_array)
    % This function reshapes the pairs (e.g. covariates), which are originally 
    % stored in a cell array, where the first value of a pair is stored in the
    % first column and the second value of a pair is stored in the second column,
    % into a single column cell array or array if the values are numeric.
    % Inverse function of reshape_pairs.m
    % Called from filter_global_calculation_pairs.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if isempty(pair_array)
        vector = [];
        return
    end

    if isnumeric(pair_array{1, 1})
        vector = zeros(size(pair_array, 1) * 2, 1);
        for i = 1:size(pair_array, 1)
            vector(i * 2 - 1) = pair_array{i, 1};
            vector(i * 2) = pair_array{i, 2};
        end
    else
        vector = cell(size(pair_array, 1) * 2, 1);
        for i = 1:size(pair_array, 1)
            vector{i * 2 - 1} = pair_array{i, 1};
            vector{i * 2} = pair_array{i, 2};
        end
    end