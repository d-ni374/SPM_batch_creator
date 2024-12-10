function matlabbatch = estimate_model_lv2(matlabbatch, nodes, node_idx, software_index_spm)
    % this function adds a batch job to estimate the second level model of an 
    % existing batch job;
    % the function is called by the SPM_batch_creator.m;
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % add job for model estimation
    output_dir = matlabbatch{end}.spm.stats.factorial_design.dir; % requires the factorial design definition batch job to be executed directly before
    matlabbatch{end+1}.spm.stats.fmri_est.spmmat = fullfile(output_dir,'SPM.mat');
    matlabbatch{end}.spm.stats.fmri_est.write_residuals = nodes{node_idx}.Model.Software{software_index_spm}.SPM.WriteResiduals;
    if lower(nodes{node_idx}.Model.Software{software_index_spm}.SPM.Method.Type) == "classical"
        matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
    elseif lower(nodes{node_idx}.Model.Software{software_index_spm}.SPM.Method.Type) == "bayesian 2nd-level"
        matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1; % according to the SPM12 manual, Bayesian 2nd-level estimation requires classical estimation first
        matlabbatch{end+1}.spm.stats.fmri_est.spmmat = fullfile(output_dir,'SPM.mat'); % add another job for the Bayesian 2nd-level estimation
        matlabbatch{end}.spm.stats.fmri_est.write_residuals = nodes{node_idx}.Model.Software{software_index_spm}.SPM.WriteResiduals;
        matlabbatch{end}.spm_stats_fmri_est.method.Bayesian2 = 1;
    end

end