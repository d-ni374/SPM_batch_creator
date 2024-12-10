function matlabbatch = define_contrasts_lv2(matlabbatch, nodes, node_idx, software_index_spm, con_idx, dm_col_names_dataset, contrasts_to_process)
    % this function adds a batch job that defines the contrasts to an 
    % existing batch job;
    % the function is called by the SPM_batch_creator.m script;
    % This script calls the following functions:
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % add job for contrast definition
    spmmat_path = matlabbatch{end}.spm.stats.fmri_est.spmmat; % requires the estimation batch job to be executed directly before
    design_matrix_col_names = dm_col_names_dataset{con_idx}; %nodes{node_idx}.Model.X;
    matlabbatch{end+1}.spm.stats.con.spmmat = spmmat_path;
    % generate contrasts from Contrasts section of json file
    l = 1; % counter for contrast index
    if isfield(nodes{node_idx}, 'Contrasts') && ~isempty(nodes{node_idx}.Contrasts) && iscell(nodes{node_idx}.Contrasts) && fct_lib.find_key(nodes{node_idx}.Contrasts, 'Name')
        for i = 1:length(nodes{node_idx}.Contrasts)
            if isa(nodes{node_idx}.Contrasts{i}.Weights, 'cell')
                if any(cellfun(@iscell, nodes{node_idx}.Contrasts{i}.Weights))
                    contrast(i).weights = nodes{node_idx}.Contrasts{i}.Weights;
                    nodes{node_idx}.Contrasts{i}.Weights = fct_lib.cellarray2d_to_matrix(nodes{node_idx}.Contrasts{i}.Weights);
                else
                    contrast(i).weights = nodes{node_idx}.Contrasts{i}.Weights;
                    nodes{node_idx}.Contrasts{i}.Weights = fct_lib.cellarray_to_array(nodes{node_idx}.Contrasts{i}.Weights);
                end
            end
            if lower(nodes{node_idx}.Contrasts{i}.Test) == "t"
                weights = zeros(1, length(design_matrix_col_names));
                for j = 1:length(design_matrix_col_names)
                    if isempty(find(ismember(nodes{node_idx}.Contrasts{i}.ConditionList, design_matrix_col_names{j}),1))
                        weights(j) = 0;
                    else
                        weights(j) = nodes{node_idx}.Contrasts{i}.Weights(find(ismember(nodes{node_idx}.Contrasts{i}.ConditionList,design_matrix_col_names{j})));
                    end
                end
                if ~validate_contrast_weights(weights, nodes{node_idx}.Contrasts{i}.Weights)
                    if ~isempty(contrasts_to_process)
                        warning('Second level contrast %s could not be created for contrast %s.', nodes{node_idx}.Contrasts{i}.Name, contrasts_to_process{con_idx});
                    else
                        warning('Second level contrast %s could not be created.', nodes{node_idx}.Contrasts{i}.Name);
                    end
                else
                    matlabbatch{end}.spm.stats.con.consess{l}.tcon.name = nodes{node_idx}.Contrasts{i}.Name;
                    matlabbatch{end}.spm.stats.con.consess{l}.tcon.convec = weights;
                    matlabbatch{end}.spm.stats.con.consess{l}.tcon.sessrep = fct_lib.get_ReplicateOverSessions(nodes{node_idx}.Model.Software{software_index_spm}.SPM.ReplicateOverSessions);
                    l = l + 1;
                end
            elseif lower(nodes{node_idx}.Contrasts{i}.Test) == "f"
                if length(nodes{node_idx}.Contrasts{i}.Weights) == numel(nodes{node_idx}.Contrasts{i}.Weights)
                    weights = zeros(1, length(design_matrix_col_names));
                    for j = 1:length(design_matrix_col_names)
                        if isempty(find(ismember(nodes{node_idx}.Contrasts{i}.ConditionList, design_matrix_col_names{j}),1))
                            weights(j) = 0;
                        else
                            weights(j) = nodes{node_idx}.Contrasts{i}.Weights(find(ismember(nodes{node_idx}.Contrasts{i}.ConditionList,design_matrix_col_names{j})));
                        end
                    end
                    if ~validate_contrast_weights(weights, nodes{node_idx}.Contrasts{i}.Weights)
                        if ~isempty(contrasts_to_process)
                            warning('Second level contrast %s could not be created for contrast %s.', nodes{node_idx}.Contrasts{i}.Name, contrasts_to_process{con_idx});
                        else
                            warning('Second level contrast %s could not be created.', nodes{node_idx}.Contrasts{i}.Name);
                        end
                    else
                        matlabbatch{end}.spm.stats.con.consess{l}.fcon.name = nodes{node_idx}.Contrasts{i}.Name;
                        matlabbatch{end}.spm.stats.con.consess{l}.fcon.convec = weights;
                        matlabbatch{end}.spm.stats.con.consess{l}.fcon.sessrep = fct_lib.get_ReplicateOverSessions(nodes{node_idx}.Model.Software{software_index_spm}.SPM.ReplicateOverSessions);
                        l = l + 1;
                    end
                else
                    number_of_lines = size(nodes{node_idx}.Contrasts{i}.Weights,1);
                    transposed_weights = nodes{node_idx}.Contrasts{i}.Weights';
                    weights = zeros(number_of_lines, length(design_matrix_col_names))';
                    for k = 1:number_of_lines
                        for j = 1:length(design_matrix_col_names)
                            if isempty(find(ismember(nodes{node_idx}.Contrasts{i}.ConditionList, design_matrix_col_names{j}),1))
                                weights(j+(k-1)*length(design_matrix_col_names)) = 0;
                            else
                                weights(j+(k-1)*length(design_matrix_col_names)) = transposed_weights(find(ismember(nodes{node_idx}.Contrasts{i}.ConditionList,design_matrix_col_names{j}))+(k-1)*size(nodes{node_idx}.Contrasts{i}.Weights,2));
                            end
                        end
                    end
                    weights_validation_status = 1;
                    for j = 1:size(transposed_weights, 1)
                        if ~validate_contrast_weights(weights(j,:), transposed_weights(j,:))
                            weights_validation_status = 0;
                        end
                    end
                    if ~weights_validation_status 
                        if ~isempty(contrasts_to_process)
                            warning('Second level contrast %s could not be created for contrast %s.', nodes{node_idx}.Contrasts{i}.Name, contrasts_to_process{con_idx});
                        else
                            warning('Second level contrast %s could not be created.', nodes{node_idx}.Contrasts{i}.Name);
                        end
                    else
                        matlabbatch{end}.spm.stats.con.consess{l}.fcon.name = nodes{node_idx}.Contrasts{i}.Name;
                        matlabbatch{end}.spm.stats.con.consess{l}.fcon.convec = weights';
                        matlabbatch{end}.spm.stats.con.consess{l}.fcon.sessrep = fct_lib.get_ReplicateOverSessions(nodes{node_idx}.Model.Software{software_index_spm}.SPM.ReplicateOverSessions);
                        l = l + 1;
                    end
                end
            end
        end
    end
    % generate contrasts from DummyContrasts section of json file
    if isfield(nodes{node_idx}, 'DummyContrasts') && ~isempty(nodes{node_idx}.DummyContrasts) && ~isempty(nodes{node_idx}.DummyContrasts.Contrasts)
        for i = 1:length(nodes{node_idx}.DummyContrasts.Contrasts)
            if lower(nodes{node_idx}.DummyContrasts.Test) == "t"
                weights = zeros(1, length(design_matrix_col_names));
                for j = 1:length(design_matrix_col_names)
                    if isempty(find(ismember(nodes{node_idx}.DummyContrasts.Contrasts(i), design_matrix_col_names{j}),1))
                        weights(j) = 0;
                    else
                        weights(j) = 1;
                    end
                end
                if sum(weights) ~= 1
                    if ~isempty(contrasts_to_process)
                        warning('Second level dummy contrast %s could not be created for contrast %s.', nodes{node_idx}.DummyContrasts.Contrasts{i}, contrasts_to_process{con_idx});
                    else
                        warning('Second level dummy contrast %s could not be created.', nodes{node_idx}.DummyContrasts.Contrasts{i});
                    end
                else
                    matlabbatch{end}.spm.stats.con.consess{l}.tcon.name = nodes{node_idx}.DummyContrasts.Contrasts{i};
                    matlabbatch{end}.spm.stats.con.consess{l}.tcon.convec = weights;
                    matlabbatch{end}.spm.stats.con.consess{l}.tcon.sessrep = fct_lib.get_ReplicateOverSessions(nodes{node_idx}.Model.Software{software_index_spm}.SPM.ReplicateOverSessions);
                    l = l + 1;
                end
            end
        end
    end
    matlabbatch{end}.spm.stats.con.delete = nodes{node_idx}.Model.Software{software_index_spm}.SPM.DeleteExistingContrasts;

end