function status = SPM_batch_creator(execution_level, logfile_flag, json_path_in, GUI_flag)
% This script generates a matlab spm batch file for a first and second level analysis from a json file.
% The json file has to comply with the BIDS Stats Models Specification.
%
% Inputs:
% execution_level: numeric, 1 for first level analysis, 2 for second level analysis
% logfile_flag: numeric, 1 to save a logfile, 0 to skip logfile, default is 1
% json_path_in: string, path to the json file (provided by GUI)
% GUI_flag: numeric, 1 if called from GUI, 0 if called from command line (default); 
%           GUI requires execution of the validation part only (fill X array)
%
% The script calls the following functions:
% - load_json.m
% - bids_validation_json.m
% - define_model.m
% - estimate_model.m
% - define_contrasts.m
% - execute_SPM_job.m
% - define_model_lv2.m
% - estimate_model_lv2.m
% - define_contrasts_lv2.m
% - specs_namespace.m
%
% Daniel Huber, University of Innsbruck, November 2024

if nargin < 1
    error('Please provide the execution level (1 or 2).');
elseif nargin < 2
    logfile_flag = 1;
end
if nargin < 3
    json_path_in = spm_select(1, 'json', 'Select json');
end
if nargin < 4
    GUI_flag = 0;
end

% stop logfile on cleanup
RAII.diary = onCleanup(@() diary('off'));

update_flag = 1; % this could be taken from external input
update_flag_cons = 1; % only relevant for 'Factorial design' in the first level analysis

% load json file
json_load = load_json(json_path_in);
json = json_load.json;
nodes = json_load.nodes;
edges = json_load.edges;

% validate json file
validation_output = bids_validation_json(json, json_path_in, nodes, edges, execution_level, update_flag, logfile_flag, GUI_flag);
if GUI_flag
    status = 1;
    return;
end
validation_status = validation_output.validation_status;

% check for filters
if isfield(json, 'Input')
    if isfield(json.Input, 'task')
        task = json.Input.task;
    else
        error('The task field is required for the analysis.');
    end
    if isfield(json.Input, 'run')
        run_id = json.Input.run; % not yet clear if needed
    end
    if isfield(json.Input, 'session')
        sess_id = json.Input.session; % not yet clear if needed
    end
    if isfield(json.Input, 'subject')
        sub_id = json.Input.subject; % not yet clear if needed
    end
end

% stop execution if json file is not valid
if ~validation_status
    error('The json file does not comply with the BIDS Stats Models Specification.');
end

% re-load json file to include any updates
json_load = load_json(json_path_in);
json = json_load.json;
nodes = json_load.nodes;
edges = json_load.edges;

% create spm matlab batch for first level analysis
for node_idx = 1:length(nodes)
    if (execution_level == 1) && (lower(nodes{node_idx}.Level) == "run" || lower(nodes{node_idx}.Level) == "session" || lower(nodes{node_idx}.Level) == "subject") % first level analysis
        % get parameters for first level analysis (from validation process)
        fmri_model_idx = validation_output.validation_output_lv1.fmri_model_idx;
        conditions_names = validation_output.conditions_names;
        dm_col_names = validation_output.dm_col_names;
        %all_dm_col_names = validation_output.all_dm_col_names; % not yet clear if needed
        software_index_spm = validation_output.software_index_spm;
        %contrast_names_list = validation_output.contrast_names_list; % not yet clear if needed
        %validation_output_lv1 = validation_output.validation_output_lv1; % not yet clear if needed
        bids_flag = nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.BIDSflag;
        for sub_idx = 1:length(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID)
            fprintf('\nCreating batch for participant "%s"\n', nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{sub_idx});
            % create batch for first level specification
            participant_dir = fullfile(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.InputDirectory, nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.Participant_ID{sub_idx});
            matlabbatch_ = define_model(nodes, node_idx, task, fmri_model_idx, participant_dir, conditions_names, sub_idx, bids_flag); % definition of the model according to the json file
            matlabbatch = matlabbatch_.matlabbatch;
            nodes = matlabbatch_.nodes; % update nodes with new information
            % create batch for first level estimation
            matlabbatch = estimate_model(matlabbatch, nodes, node_idx, software_index_spm{node_idx}); % estimation of the model according to the json file
            % create batch for contrasts
            matlabbatch = define_contrasts(matlabbatch, nodes, node_idx, fmri_model_idx, software_index_spm{node_idx}, sub_idx, dm_col_names); % definition of contrasts according to the json file
            % save batch
            [pth,~,~] = fileparts(matlabbatch{2}.spm.stats.fmri_est.spmmat);
            if ~exist(pth, 'dir')
                mkdir(pth);
            end
            fid = fopen(fullfile(pth, 'FirstLevelBatch_.m'), 'w'); % existing file will be overwritten
            [txt,~,~] = gencode(matlabbatch);
            fprintf(fid, '%s\n', txt{:});
            fclose(fid);
            % batch execution
            %
            status = execute_SPM_job(matlabbatch);
            %}
            % The following section transforms the "FactorialDesign" definition to "Contrasts" and adds them to the json file;
            % only executed for the very first subject, since the data must be complete for all subjects when choosing 'Factorial design'
            if sub_idx == 1 && status == 1 && ... 
                isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input, 'FactorialDesign') && ...
                ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign) && ...
                iscell(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign) && ...
                isfield(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{1}, 'Name') && ...
                ~isempty(nodes{node_idx}.Transformations.Instructions{fmri_model_idx}.Input.FactorialDesign{1}.Name)
                contrast_names_list = validation_output.contrast_names_list;
                if exist('validation_output_lv2', 'var')
                    add_contrasts_factorial_design_to_json(json, json_path_in, nodes, node_idx, edges, fmri_model_idx, contrast_names_list, update_flag_cons, validation_output_lv2);
                else % handle the case where there is no second level node
                    add_contrasts_factorial_design_to_json(json, json_path_in, nodes, node_idx, edges, fmri_model_idx, contrast_names_list, update_flag_cons);
                end
            end
        end
    elseif (execution_level == 2) && (lower(nodes{node_idx}.Level) == "dataset") % second level analysis
        % get parameters for second level analysis (from validation process)
        model_name = json.Name;
        software_index_spm = validation_output.software_index_spm;
        dm_col_names_dataset = validation_output.dm_col_names_dataset;
        %all_dm_col_names_dataset = validation_output.all_dm_col_names_dataset; % not yet clear if needed
        %contrast_names_list_lv2 = validation_output.contrast_names_list_lv2; % not yet clear if needed
        validation_output_lv2 = validation_output.validation_output_lv2;
        if ~isempty(validation_output_lv2.contrasts_to_process)
            n_cons = length(validation_output_lv2.contrasts_to_process);
        else
            n_cons = 1;
        end
        for con_idx = 1:n_cons % refers to 1st level contrasts which are further processed on dataset level (only relevant for 'OneSampleTTest', 'TwoSampleTTest', 'MultipleRegression')
            if ~isempty(validation_output_lv2.contrasts_to_process)
                fprintf('\nCreating batch for contrast "%s".\n', validation_output_lv2.contrasts_to_process{con_idx});
            else
                fprintf('\nCreating batch for second level design.\n');
            end
            matlabbatch = define_model_lv2(model_name, nodes, node_idx, validation_output_lv2, con_idx); % definition of the model according to the json file
            % create batch for second level estimation
            matlabbatch = estimate_model_lv2(matlabbatch, nodes, node_idx, software_index_spm{node_idx}); % estimation of the model according to the json file
            % create batch for contrasts
            matlabbatch = define_contrasts_lv2(matlabbatch, nodes, node_idx, software_index_spm{node_idx}, con_idx, dm_col_names_dataset, validation_output_lv2.contrasts_to_process); % definition of contrasts according to the json file
            % save batch
            [pth,~,~] = fileparts(matlabbatch{2}.spm.stats.fmri_est.spmmat);
            if ~exist(pth, 'dir')
                mkdir(pth);
            end
            fid = fopen(fullfile(pth, 'SecondLevelBatch_.m'), 'w'); % existing file will be overwritten
            [txt,~,~] = gencode(matlabbatch);
            fprintf(fid, '%s\n', txt{:});
            fclose(fid);
            % batch execution
            %
            status = execute_SPM_job(matlabbatch);
            %}
        end
    end
end
if logfile_flag % stop logfile
    diary('off');
end

end
