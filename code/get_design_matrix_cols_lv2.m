function output = get_design_matrix_cols_lv2(matlabbatch)
    % gets the design matrix columns using SPM functions;
    % called from json_validator_bids_values.m
    % This script calls the following functions:
    % - spm_run_fmri_spec_noSave.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    SPM_ = spm_run_factorial_design_noSave(matlabbatch{1,1}.spm.stats.factorial_design);
    output.design_matrix_column_names = SPM_.xX.name;

end