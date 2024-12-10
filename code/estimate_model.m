function matlabbatch = estimate_model(matlabbatch, nodes, node_idx, software_index_spm)
    % this function adds a batch job to estimate the first level model of an 
    % existing batch job;
    % the function is called by the SPM_batch_creator.m;
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % add job for model estimation
    output_dir = matlabbatch{end}.spm.stats.fmri_spec.dir; % requires the first level design definition batch job to be executed directly before
    matlabbatch{end+1}.spm.stats.fmri_est.spmmat = fullfile(output_dir,'SPM.mat');
    matlabbatch{end}.spm.stats.fmri_est.write_residuals = nodes{node_idx}.Model.Software{software_index_spm}.SPM.WriteResiduals;
    if lower(nodes{node_idx}.Model.Software{software_index_spm}.SPM.Method.Type) == "classical"
        matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
    elseif lower(nodes{node_idx}.Model.Software{software_index_spm}.SPM.Method.Type) == "bayesian 2nd-level"
        matlabbatch{end}.spm_stats_fmri_est.method.Bayesian2 = 1;
    %clarify if Bayesian 1st-level should be included (-> several options have to be added)
    %elseif nodes{node_idx}.Model.Software{software_index_spm}.SPM.Method.Type == "Bayesian1st-level"
    end

end