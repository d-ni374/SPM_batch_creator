function status = execute_SPM_job(matlabbatch)
    % called from SPM_batch_creator.m
    % execute_SPM_job tries to execute an SPM job
    %   status = execute_SPM_job(matlabbatch) executes a SPM job
    %   specified in the matlabbatch structure and returns the status of the
    %   execution.
    %
    %   matlabbatch: a structure containing the SPM job
    %   status: a boolean indicating the status of the execution
    %
    % Daniel Huber, University of Innsbruck, November 2024

    jobs{1} = matlabbatch;
    try
        spm('defaults', 'fmri');
        spm_get_defaults('custom', struct('normhrf', 0));
        spm_jobman('initcfg');
        spm_jobman('serial', jobs);
        spm_get_defaults('custom', struct('normhrf', 0));
        status = true;
    catch ERR
        fprintf('The SPM job could not be executed.\n');
        warning(ERR.identifier, '%s', ERR.message);
        status = false;
    end

end