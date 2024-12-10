function status = validate_contrast_weights(weights_design_matrix, weights_contrast)
    % This function validates the weights of a contrast against the design matrix.
    % The function returns 1 if the weights are valid, 0 otherwise.
    % Called from define_contrasts.m and define_contrasts_lv2.m;
    % Input:
    % weights_design_matrix: the weights related to the order of the design matrix (corresponds to Model.X)
    % weights_contrast: the weights defined in the contrast section of the json
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % initialize status
    status = 1;

    % check if the weights are empty
    if isempty(weights_contrast) || isempty(weights_design_matrix)
        status = 0;
    end
    % transpose the weights if necessary
    if size(weights_contrast, 2) == 1
        weights_contrast = weights_contrast';
    end
    % get all values of the weights
    bins_con = unique(weights_contrast);
    bins_dm = unique(weights_design_matrix);
    % remove zeros from the bins
    bins_con(bins_con == 0) = [];
    bins_dm(bins_dm == 0) = [];
    % check if the bins are the same
    if ~isequal(bins_con, bins_dm)
        status = 0;
    else
        % count elements in the bins
        for i = 1:length(bins_con)
            if ~isequal(sum(weights_contrast == bins_con(i), 'all'), sum(weights_design_matrix == bins_dm(i), 'all'))
                status = 0;
            end
        end
    end

end