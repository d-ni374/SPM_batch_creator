function value = get_default_values(variable)
    % get_default_values - Get default values for a variable
    %
    % Usage:
    %   value = get_default_values(variable)
    %
    % Input:
    %   variable (str) - Variable name
    %
    % Output:
    %   value (any) - Default value for the variable
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % Default values - These values can be adapted by the user
    % referring to SPM_batch_creator:
    missing_data_indicator = {'NA', 'na', 'N/A', 'n/a'}; % add more if necessary
    raw_data_dir = '1_rawdata'; % default raw data directory for non-BIDS datasets
    preproc_data_dir = '2_preprocessed'; % default preprocessed data directory for non-BIDS datasets
    first_level_dir = '3_first_levels'; % default first level directory for non-BIDS datasets
    second_level_dir = '4_second_levels'; % default second level directory for non-BIDS datasets
    % referring to ui_spm_batch_creator:
    BIDSModelVersion = '1.0.0-rc1';
    NodeNameFirstLevel = 'first_level_stats';
    NodeNameSecondLevel = 'second_level_stats';
    TransformerName = 'spm12-spec-v1'; % can be changed if necessary
    InstructionNameFirstLevel = 'fmri_model_specification'; % required to use SPM_batch_creator.m
    InstructionNameSecondLevel = 'factorial_design_specification'; % required to use SPM_batch_creator.m
    ContrastNamesSeparator = ',';
    FileRegexpNamesSeparator = ',';
    CovariateNamesSeparator = ',';
    CovColNamesSeparator = ','; % separator for covariate column names (in ui_spm_batch_creator)
    ThresholdValueMaskAbs = 100; % default value (SPM)
    ThresholdValueMaskRel = 0.8; % default value (SPM)
    OverallGrandMeanScalingValue = 50; % default value (SPM)

    % Set output value - Do not change
    if strcmp(variable, 'missing_data_indicator')
        value = missing_data_indicator;
    elseif strcmp(variable, 'raw_data_dir')
        value = raw_data_dir;
    elseif strcmp(variable, 'preproc_data_dir')
        value = preproc_data_dir;
    elseif strcmp(variable, 'first_level_dir')
        value = first_level_dir;
    elseif strcmp(variable, 'second_level_dir')
        value = second_level_dir;
    elseif strcmp(variable, 'BIDSModelVersion')
        value = BIDSModelVersion;
    elseif strcmp(variable, 'NodeNameFirstLevel')
        value = NodeNameFirstLevel;
    elseif strcmp(variable, 'NodeNameSecondLevel')
        value = NodeNameSecondLevel;
    elseif strcmp(variable, 'TransformerName')
        value = TransformerName;
    elseif strcmp(variable, 'InstructionNameFirstLevel')
        value = InstructionNameFirstLevel;
    elseif strcmp(variable, 'InstructionNameSecondLevel')
        value = InstructionNameSecondLevel;
    elseif strcmp(variable, 'ContrastNamesSeparator')
        value = ContrastNamesSeparator;
    elseif strcmp(variable, 'FileRegexpNamesSeparator')
        value = FileRegexpNamesSeparator;
    elseif strcmp(variable, 'CovariateNamesSeparator')
        value = CovariateNamesSeparator;
    elseif strcmp(variable, 'CovColNamesSeparator')
        value = CovColNamesSeparator;
    elseif strcmp(variable, 'ThresholdValueMaskAbs')
        value = ThresholdValueMaskAbs;
    elseif strcmp(variable, 'ThresholdValueMaskRel')
        value = ThresholdValueMaskRel;
    elseif strcmp(variable, 'OverallGrandMeanScalingValue')
        value = OverallGrandMeanScalingValue;
    else
        error('Variable not found');
    end

end