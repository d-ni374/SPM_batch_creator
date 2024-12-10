function output = define_model(nodes, node_idx, task, fmri_model_idx, participant_dir, conditions_names, sub_idx, bids_flag)
    % define_model: defines the model for the first-level analysis
    % Inputs:
    %   nodes: cell array of the nodes read from the json file
    %   node_idx: the index of the node to define the model for
    %   task: the task of the model
    %   fmri_model_idx: the index of the Instruction within the node node_idx
    %   participant_dir: the directory of the participant
    %   conditions_names: cell array containing the condition names
    %   sub_idx: the index of the participant
    %   bids_flag: flag indicating BIDS compatibility
    % Outputs:
    %   output: struct containing the model definition
    %           output.matlabbatch: the SPM batch
    %           output.nodes: the updated nodes
    % Called from SPM_batch_creator and json_validator_bids_values.m
    % This script calls the following functions:
    % - get_scans.m
    % - get_conditions_regressors.m
    % - specs_namespace.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    % create batch
    % output directory is currently defined as output_directory/sub_id/task (could be changed to output_directory/task/sub_id -> must be changed accordingly in get_paths_lv2.m):
    matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.OutputDirectory, nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{sub_idx}, task)};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.TimingParameters.UnitsForDesign);
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.TimingParameters.InterscanInterval;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.TimingParameters.MicrotimeResolution;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.TimingParameters.MicrotimeOnset;
    if ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions) && iscell(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions) && fct_lib.find_key(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions, 'Session_id')
        batch_sess_id = 0;
        for m = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions)
            % get data from scans
            batch_sess_id = batch_sess_id + 1;
            sess_id = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Session_id;
            if isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}, 'Run_ids') && ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Run_ids)
                for n = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Run_ids)
                    if n > 1
                        batch_sess_id = batch_sess_id + 1;
                    end
                    run_id = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.Run_ids{n};
                    output_scans = get_scans(nodes, node_idx, fmri_model_idx, participant_dir, task, sess_id, run_id, bids_flag);
                    nodes = output_scans.nodes;
                    number_images = output_scans.number_images;
                    if nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType == "3d"
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).scans = output_scans.scans;
                    elseif nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType == "4d"
                        for i = 1:number_images
                            matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).scans{i, 1} = [output_scans.scans{1}, ',', num2str(i)];
                        end
                    end
                    % add data for conditions/trials and movement parameters
                    output_conditions_regressors = get_conditions_regressors(matlabbatch, batch_sess_id, nodes, node_idx, task, fmri_model_idx, participant_dir, number_images, conditions_names, sub_idx, bids_flag, sess_id, m, run_id);
                    matlabbatch = output_conditions_regressors.matlabbatch;
                    conditions_names = output_conditions_regressors.conditions_names;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).hpf = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.HighPassFilterSecs;
                end
            else
                output_scans = get_scans(nodes, node_idx, fmri_model_idx, participant_dir, task, sess_id, '', bids_flag);
                nodes = output_scans.nodes;
                number_images = output_scans.number_images;
                if nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType == "3d"
                    matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).scans = output_scans.scans;
                elseif nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ImageType == "4d"
                    for i = 1:number_images
                        matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).scans{i, 1} = [output_scans.scans{1}, ',', num2str(i)];
                    end
                end
                % get data for conditions/trials and movement parameters
                output_conditions_regressors = get_conditions_regressors(matlabbatch, batch_sess_id, nodes, node_idx, task, fmri_model_idx, participant_dir, number_images, conditions_names, sub_idx, bids_flag, sess_id, m, '');
                matlabbatch = output_conditions_regressors.matlabbatch;
                conditions_names = output_conditions_regressors.conditions_names;
                matlabbatch{1}.spm.stats.fmri_spec.sess(batch_sess_id).hpf = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Sessions{m}.HighPassFilterSecs;
            end
        end
    end
    if ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign) && iscell(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign) && fct_lib.find_key(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign, 'Name')
        for i = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign)
            if ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{i}.Name)
                matlabbatch{1}.spm.stats.fmri_spec.fact(i).name = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{i}.Name;
                matlabbatch{1}.spm.stats.fmri_spec.fact(i).levels = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{i}.Levels;
            elseif isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{i}.Name) && i == 1
                matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
            end
        end
    else
        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    end
    if lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.Type) == "none"
        matlabbatch{1}.spm.stats.fmri_spec.bases.none = true;
    elseif lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.Type) == "canonical hrf"
        if nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives && nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives
            matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1, 1];
        elseif nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives
            matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1, 0];
        else
            matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0, 0];
        end
    elseif lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.Type) == "fourier set"
        matlabbatch{1}.spm.stats.fmri_spec.bases.fourier.length = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs;
        matlabbatch{1}.spm.stats.fmri_spec.bases.fourier.order = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions;
    elseif lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.Type) == "fourier set (hanning)" 
        matlabbatch{1}.spm.stats.fmri_spec.bases.fourier_han.length = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs;
        matlabbatch{1}.spm.stats.fmri_spec.bases.fourier_han.order = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions;
    elseif lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.Type) == "gamma functions" 
        matlabbatch{1}.spm.stats.fmri_spec.bases.gamma.length = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs;
        matlabbatch{1}.spm.stats.fmri_spec.bases.gamma.order = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions;
    elseif lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.Type) == "finite impulse response" 
        matlabbatch{1}.spm.stats.fmri_spec.bases.fir.length = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs;
        matlabbatch{1}.spm.stats.fmri_spec.bases.fir.order = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions;
    end
    matlabbatch{1}.spm.stats.fmri_spec.volt = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ModelInteractionsVolterra + 1; %different assignment in json (compared to SPM)
    if nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.GlobalNormalisation == 0
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    elseif nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.GlobalNormalisation == 1
        matlabbatch{1}.spm.stats.fmri_spec.global = 'Scaling';
    end
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.MaskingThreshold;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {fullfile(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.ExplicitMask)};
    if lower(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.SerialCorrelations) == "none"
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';
    elseif upper(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.SerialCorrelations) == "AR(1)"
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    elseif upper(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.SerialCorrelations) == "FAST"
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
    end

    % define outputs
    output.matlabbatch = matlabbatch;
    output.nodes = nodes;

end