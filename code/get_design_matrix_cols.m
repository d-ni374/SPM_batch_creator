function output = get_design_matrix_cols(matlabbatch)
    % gets the design matrix columns using SPM functions;
    % called from json_validator_bids_values.m
    % This script calls the following functions:
    % - spm_run_fmri_spec_noSave.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    SPM_ = spm_run_fmri_spec_noSave(matlabbatch{1,1}.spm.stats.fmri_spec);
    output.design_matrix_column_names = SPM_.xX.name;
    cond_col_names = cell(1, length(matlabbatch{1}.spm.stats.fmri_spec.sess));
    for sess_idx = 1:length(matlabbatch{1}.spm.stats.fmri_spec.sess)
        cond_col_names{sess_idx} = [SPM_.Sess(sess_idx).U.name];
        cond_col_names{sess_idx} = cellfun(@(x) ['Sn(', num2str(sess_idx), ') ', x], cond_col_names{sess_idx}, 'UniformOutput', false);
    end
    output.cond_column_names = [cond_col_names{:}];
    
end