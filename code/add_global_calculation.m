function matlabbatch = add_global_calculation(matlabbatch, validation_output_lv2, con_idx)
    % This function adds user defined global calculation values identified from 
    % the json file to the existing batch job;
    % called by define_model_lv2.m;
    %
    % Daniel Huber, University of Innsbruck, November 2024

    design_type = validation_output_lv2.design_type;

    switch design_type
        case 1 % 'OneSampleTTest'
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = validation_output_lv2.data(con_idx).global_calculation;
        case 2 % 'TwoSampleTTest'
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = validation_output_lv2.data(con_idx).global_calculation;
        case 3 % 'PairedTTest'
            global_values = [];
            for i = 1:length(validation_output_lv2.data)
                global_values = [global_values; validation_output_lv2.data(i).global_calculation];
            end
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = global_values;
        case 4 % 'MultipleRegression'
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = validation_output_lv2.data(con_idx).global_calculation;
        case 5 % 'OneWayANOVA'
            global_values = [];
            for i = 1:length(validation_output_lv2.cells)
                global_values = [global_values; validation_output_lv2.cells(i).global_calculation];
            end
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = global_values;
        case 6 % 'OneWayANOVAWithinSubject'
            global_values = [];
            for i = 1:length(validation_output_lv2.subjects)
                global_values = [global_values; validation_output_lv2.subjects(i).global_calculation];
            end
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = global_values;
        case 7 % 'FullFactorial'
            global_values = [];
            for i = 1:length(validation_output_lv2.cells)
                global_values = [global_values; validation_output_lv2.cells(i).global_calculation];
            end
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = global_values;
        case 8 % 'FlexibleFactorial'
            global_values = [];
            for i = 1:length(validation_output_lv2.subjects)
                global_values = [global_values; validation_output_lv2.subjects(i).global_calculation];
            end
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_user.global_uval = global_values;
    end

end