function json_out_ = ui_spm_batch_creator()
    % This function is the main function for the user interface of the SPM batch
    % creator. It calls the function fct_selector, which is the main function
    % for the program sequence. It calls the respective dialog boxes in which 
    % all needed variables are requested from the user. The function also
    % defines the program sequence and the options for the window display.
    % Within different steps the json file is built up according to the chosen 
    % level of analysis, eventually yielding the final json output file. This 
    % file can be used to run the SPM batch creator to generate and execute SPM 
    % batch files.
    %
    % This function assists in creating json files for three different use cases 
    % (chosen from the template selection in the first dialog box):
    % 1. First level analysis
    % 2. Second level analysis
    % 3. First + Second level analysis
    %
    % 1. First level analysis: This modality is used to create a json file for
    % the first level analysis of fMRI data. The user is asked to provide
    % information about the fMRI data, the design of the experiment, the model, 
    % and some general options. Two sub-cases are possible:
    % (a) If the user chooses to define contrasts (in the window 'Model 
    % estimation'), the provided input is checked by analysing the data and 
    % writing the X array and HRF variables to the json file. The user 
    % is then asked to define contrasts in the window 'Contrast definition'.
    % The final json file (containing only a first level node) is written to the 
    % specified output directory. The json file can then be used to run the 
    % SPM_batch_creator to generate and execute SPM batch files by executing:
    % SPM_batch_creator(1);
    % (b) If the user chooses not to define contrasts, the json file is written
    % directly after the 'Save model file' window. This option is quicker since 
    % the data is not analysed yet. Instead, the contrast sections are empty and 
    % the user has to define contrasts manually in the json file. For this 
    % purpose, the user has to execute SPM_batch_creator(1), which will result 
    % in an error message, since the predictor variables are not defined yet. 
    % However, the sections Model.X and Model.HRF.Variables are filled and those 
    % entries can then be used to define contrasts manually in the json file. 
    % Afterwards, the user can execute SPM_batch_creator(1) again to generate 
    % and execute SPM batch files.
    %
    % 2. Second level analysis: This modality is used to create the second 
    % level node of the json file, which will be appended to the nodes 
    % structure of the json file. This option requires a first level json file 
    % (created with the option 'First level analysis') as input. The user is 
    % asked to provide information about the second level analysis, such as the
    % design of the experiment, the model, and some general options. The json
    % file is written to the specified output directory. Two sub-cases are
    % possible:
    % (a) If the user chooses to define contrasts (in the window 'Second level
    % input'), the provided input is checked by analysing the data and writing
    % the X array to the json file. The user is then asked to define contrasts
    % in the window 'Contrast definition'. The final json file (containing a
    % first and second level node) is written to the specified output directory.
    % The json file can be used to run the SPM batch creator to generate and
    % execute SPM batch files by executing:
    % SPM_batch_creator(2);
    % (b) If the user chooses not to define contrasts, the json file is written
    % directly after the 'Estimation Options' window. This option is quicker since
    % the data is not analysed yet. Instead, the contrast sections are empty and
    % the user has to define contrasts manually in the json file. For this
    % purpose, the user has to execute SPM_batch_creator(2), which will result
    % in an error message, since the predictor variables are not defined yet.
    % However, the section Model.X is filled and this entry can then be used to
    % define contrasts manually in the json file. The user can then execute
    % SPM_batch_creator(2) again to generate and execute SPM batch files.
    %
    % 3. First + Second level analysis: This modality is used to create a json
    % file for the first and second level analysis of fMRI data. The user is
    % asked for the same information as in the first level analysis, but is 
    % forced to define contrasts in the window 'Contrast definition'. This is 
    % necessary since the second level analysis is based on the contrasts
    % defined in the first level analysis. The json file is written to the 
    % specified output directory. The second level definition is done in the 
    % next step (see 2). In this case, it is not possible to define contrasts 
    % in the user interface of the second level analysis, since the required 
    % variable Model.X cannot be defined yet (because the contrast files of the 
    % first level analysis are not yet available). The user has to define 
    % contrasts manually in the json file. For this purpose, the user has to 
    % execute SPM_batch_creator(1) to generate and execute SPM first level batch 
    % files and then SPM_batch_creator(2). This results in an error (because 
    % Model.X is not defined), but this variable is at this point generated 
    % allowing the user to define the second level contrasts manually. Finally, 
    % SPM_batch_creator(2) is executed once again to generate and execute SPM 
    % second level batch files.
    %
    % The most convenient way to run this function and SPM_batch_creator, i.e., 
    % manual input in the json file is not necessary, is to use this function 
    % in the following way:
    % i) Run this function with option 'First level analysis' and define 
    % contrasts in the window 'Model estimation' (see 1a).
    % ii) Execute SPM_batch_creator(1) to generate and execute SPM first level 
    % batch files.
    % iii) Run this function with option 'Second level analysis' and choose to 
    % define contrasts in the window 'Second level input' (see 2a).
    % iv) Execute SPM_batch_creator(2) to generate and execute SPM second level
    % batch files.
    % 
    % Daniel Huber, University of Innsbruck, November 2024

    clear;

    % get options for window display
    options = define_options_inputsdlg();
    
    % define program sequence
    progr_sequence.act =  [2;3;4; 5;40;6;41;7;42;43;8; 9;10;11;12;13;14;15;16;17;18;20;22;23;24;25;26;27;45;28;46;47;48;30;49;32;33;34;35;36;37;38];
    progr_sequence.prev = [1;2;3;-1;-1;3; 6;6; 7; 7;7; 8; 1;10;10;10;10;10;10;10;10;-1;12;13;14;15;16;17;17;-1;-1;18;-1;10;30;30;32;33;-1;35;35;35];
    progr_sequence.next = [3;6;6; 6; 6;7; 7;8; 8; 8;9;50;11;30;22;23;30;25;26;45;46;11;30;30;30;30;30;45;30;48;28;30;47;32;32;33;34;50;36;50;50;36];
    %{
    % overview of program sequence: stored in progr_sequence_ struct
    ids = cell(length(progr_sequence.act), 1);
    for j = 1:length(ids)
        ids{j, 1} = ['id', num2str(progr_sequence.act(j))];
        progr_sequence_.(ids{j, 1}) = [progr_sequence.act(j), progr_sequence.prev(j), progr_sequence.next(j)];
    end
    %}
    % initialize variables
    status_id = 1;
    output_ = {};
    json_out = [];
    input_buffer = [];
    repeat_args = [];
    repeat_args.rep_flag = 0;

    % main loop for program sequence
    while status_id < 50 % this value must be changed according to # of states
        if status_id == -1
            return;
        end
        [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(status_id, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
    end

    %create variable which will be encoded to json
    json_out_.BIDSModelVersion = get_default_values('BIDSModelVersion');
    json_out_.Name = json_out.ModelName;
    json_out_.Description = json_out.Description;
    json_out_.Input = struct();
    json_out_.Input.task = json_out.Task;
    json_out_.Edges{1}.Source = '';
    json_out_.Edges{1}.Destination = '';
    json_out_.Edges{1}.Filter = struct(); % unsupported so far
    if json_out.Template == "First level" || json_out.Template == "First + Second level"
        json_out_.Nodes{1}.Level = json_out.Level;
        json_out_.Nodes{1}.Name = get_default_values('NodeNameFirstLevel');
        json_out_.Nodes{1}.GroupBy = []; % not implemented yet
        json_out_.Nodes{1}.Transformations.Transformer = get_default_values('TransformerName');
        json_out_.Nodes{1}.Transformations.Instructions{1}.Name = get_default_values('InstructionNameFirstLevel');
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BIDSflag = json_out.BIDSFlag;
        sub_id_list = cell(1, size(json_out.SubjectFoldersPreproc, 1));
        for i = 1:size(json_out.SubjectFoldersPreproc, 1)
            subfolder_split = strsplit(json_out.SubjectFoldersPreproc{i}, filesep);
            sub_id_list{i} = subfolder_split{end};
        end
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Participant_ID = sub_id_list;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.InputDirectory = fullfile(subfolder_split{1:end-1}); % only main directory without subject_id (taken from last subject directory)
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.InputFilterRegexp = json_out.InputFileRegexp;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.ImageType = json_out.ImageType;
        if isempty(json_out.OutputDirLv1)
            json_out.OutputDirLv1 = get_default_output_dir(json_out.SubjectFoldersPreproc{1});
        end
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.OutputDirectory = strrep(json_out.OutputDirLv1,'\','/');
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.TimingParameters.UnitsForDesign = json_out.UnitsForDesign;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.TimingParameters.InterscanInterval = json_out.InterscanInterval;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.TimingParameters.MicrotimeResolution = json_out.MicrotimeResolution;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.TimingParameters.MicrotimeOnset = json_out.MicrotimeOnset;
        for j = 1:json_out.NumberOfSessions
            if json_out.NumberOfSessions == 1
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Session_id = '';
            elseif json_out.NumberOfSessions > 1
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Session_id = json_out.sess(j).SessionIdentifier;
            else
                error('No session defined.');
            end
            if ~isempty(json_out.sess(j).RunIds)
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Run_ids = strsplit(json_out.sess(j).RunIds, ',');
            else
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Run_ids = [];
            end
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.EventsRegexp = json_out.sess(j).EventsRegex;
            if isempty(json_out.sess(j).NumberOfConditions) || json_out.sess(j).NumberOfConditions == 0
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions = [];
            end
            for k = 1:json_out.sess(j).NumberOfConditions
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.TrialType = json_out.sess(j).cond(k).TrialType;
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.TimeModulation = json_out.sess(j).cond(k).TimeModulation;
                if ~isempty(json_out.sess(j).cond(k).NumberOfParametricModulations) && json_out.sess(j).cond(k).NumberOfParametricModulations > 0
                    for l = 1:json_out.sess(j).cond(k).NumberOfParametricModulations
                        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.ParametricModulations{l}.Name = json_out.sess(j).cond(k).pmod(l).pmodName;
                        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.ParametricModulations{l}.ColName = json_out.sess(j).cond(k).pmod(l).pmodColName;
                        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.ParametricModulations{l}.Poly = json_out.sess(j).cond(k).pmod(l).pmodPolyOrder;
                    end
                else
                    json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.ParametricModulations{1}.Name = '';
                    json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.ParametricModulations{1}.ColName = '';
                    json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.ParametricModulations{1}.Poly = 1;
                end
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.Conditions{k}.OrthogonaliseModulations = json_out.sess(j).cond(k).OrthogonaliseModulations;
            end
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.ConditionsRegexp = json_out.sess(j).MultipleConditionsRegex;
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.RegressorsRegexp = json_out.sess(j).MultipleRegressorsRegex;
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.HighPassFilterSecs = json_out.sess(j).HighPassFilterSecs;
        end
        if json_out.FactDesignFlag
            for j = 1:json_out.FactDesignFactors
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.FactorialDesign{j}.Name = json_out.fact(j).FactorName;
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.FactorialDesign{j}.Levels = json_out.fact(j).FactorLevels;
            end
        else
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.FactorialDesign{1}.Name = '';
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.FactorialDesign{1}.Levels = 0;
        end
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.Type = json_out.BasisFctType;
        if json_out.BasisFctType == "Canonical HRF"
            if json_out.DerivHRF == "no"
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives = 0;
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives = 0;
                json_out_.Nodes{1}.Model.HRF.Model = 'spm';
            elseif json_out.DerivHRF == "time derivative"
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives = 1;
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives = 0;
                json_out_.Nodes{1}.Model.HRF.Model = 'spm + derivative';
            elseif json_out.DerivHRF == "time & dispersion derivative"
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsCanonicalHRF.ModelTimeDerivatives = 1;
                json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsCanonicalHRF.ModelDispersionDerivatives = 1;
                json_out_.Nodes{1}.Model.HRF.Model = 'spm + derivative + dispersion';
            end
        else
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsOtherBasisFunctions.WindowLengthSecs = json_out.BasisWindowLength;
            json_out_.Nodes{1}.Transformations.Instructions{1}.Input.BasisFunctions.OptionsOtherBasisFunctions.NumberBasisFunctions = json_out.NumberOfBasisFct;
        end
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.ModelInteractionsVolterra = json_out.VolterraFlag;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.GlobalNormalisation = json_out.GlobalNorm;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.MaskingThreshold = json_out.MaskThreshold;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.ExplicitMask = strrep(json_out.ExplicitMask,'\','/');
        json_out_.Nodes{1}.Transformations.Instructions{1}.Input.SerialCorrelations = json_out.SerialCorr;
        json_out_.Nodes{1}.Transformations.Instructions{1}.Output = 'SPM.mat';
        json_out_.Nodes{1}.Model.Type = json_out.ModelTypeBIDS;
        json_out_.Nodes{1}.Model.X = [];
        json_out_.Nodes{1}.Model.HRF.Variables = [];
        if isfield(json_out.sess(1), 'HighPassFilterSecs') % delete this due to redundancy???
            all_hp = [json_out.sess.HighPassFilterSecs];
            if all(all_hp == all_hp(1))
                json_out_.Nodes{1}.Model.Options.HighPassFilterCutoffHz = 1 / all_hp(1);
            end
        end
        json_out_.Nodes{1}.Model.Software{1}.SPM.WriteResiduals = json_out.WriteResiduals;
        json_out_.Nodes{1}.Model.Software{1}.SPM.Method.Type = json_out.DesignTypeLv1;
        if json_out.DesignTypeLv1 == "Bayesian 1st-level" % not implemented yet in analysis script SPM_batch_creator.m
            json_out_.Nodes{1}.Model.Software{1}.SPM.Method.OptionsBayesian1 = struct();
        end
        json_out_.Nodes{1}.Model.Software{1}.SPM.DeleteExistingContrasts = json_out.DeleteExistingContrasts;
        json_out_.Nodes{1}.Model.Software{1}.SPM.ReplicateOverSessions = json_out.ReplOverSessions;
        if json_out.DefineContrastsFlag == 0
            % add empty contrasts to json
            json_out_.Nodes{1}.Contrasts = [];
            json_out_.Nodes{1}.DummyContrasts = struct('Test', {''}, 'Contrasts', {[]});
        end
        % fix escape characters in json
        nodes_ = json_out_.Nodes;
        nodes_= fix_escape_characters_json_output(nodes_, 1, 1, 0);
        json_out_ = rmfield(json_out_, 'Nodes');
        json_out_.Nodes = nodes_;
        % write preliminary json file
        if strcmpi(json_out.ModelFileName(end-4:end), '.json')
            json_path_out = fullfile(json_out.ModelOutputDir, json_out.ModelFileName);
        else
            json_path_out = fullfile(json_out.ModelOutputDir, [json_out.ModelFileName, '.json']);
        end
        if json_out.OverwriteModel == 0
            json_path_out = check_path(json_path_out);
        end
        if ~exist(json_out.ModelOutputDir, 'dir')
            mkdir(json_out.ModelOutputDir);
        end
        fid = fopen(json_path_out, 'w+');
        encodedJSON = jsonencode(json_out_, PrettyPrint=true);
        fprintf(fid, encodedJSON);
        fclose(fid);
        if json_out.DefineContrastsFlag == 1
            % check data and write X array and HRF variables to json
            for j = 1:length(json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions)
                if isempty(json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{1}.Conditions) && isempty(json_out_.Nodes{1}.Transformations.Instructions{1}.Input.Sessions{j}.ConditionsRegexp)
                    error('No conditions found. Please define conditions first.');
                end
            end
            SPM_batch_creator(1,0,json_path_out,1);
            updated_json_ = load_json(json_path_out);
            updated_json = updated_json_.json;
            updated_json.Nodes = updated_json_.nodes;
            updated_json.Edges = updated_json_.edges;
            json_out_.Nodes{1}.Model.X = updated_json.Nodes{1}.Model.X;
            json_out_.Nodes{1}.Model.HRF.Variables = updated_json.Nodes{1}.Model.HRF.Variables;
            json_out.X = updated_json.Nodes{1}.Model.X;
            json_out.HRFVariables = updated_json.Nodes{1}.Model.HRF.Variables;
            % repeat while loop for contrasts
            status_id = 35; % Definition of Contrasts
            while status_id < 50 % this value must be changed according to # of states
                if status_id == -1
                    return;
                end
                [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(status_id, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
            end
            % update json file with contrasts
            con_idx = 0;
            if isfield(json_out, 'tContrastNames') && ~isempty(json_out.tContrastNames)
                for j = 1:length(json_out.tContrastNames)
                    con_idx = con_idx + 1;
                    json_out_.Nodes{1}.Contrasts{con_idx}.Name = json_out.tContrastNames{j};
                    actual_weights = json_out.tContrastWeights(j,:);
                    non_zero_idx = find(actual_weights ~= 0);
                    json_out_.Nodes{1}.Contrasts{con_idx}.ConditionList = json_out.X(non_zero_idx);
                    json_out_.Nodes{1}.Contrasts{con_idx}.Weights = actual_weights(non_zero_idx);
                    json_out_.Nodes{1}.Contrasts{con_idx}.Test = 't';
                end
            end
            if isfield(json_out, 'fContrastNames') && ~isempty(json_out.fContrastNames)
                for j = 1:length(json_out.fContrastNames)
                    con_idx = con_idx + 1;
                    json_out_.Nodes{1}.Contrasts{con_idx}.Name = json_out.fContrastNames{j};
                    json_out_.Nodes{1}.Contrasts{con_idx}.ConditionList = json_out.X;
                    json_out_.Nodes{1}.Contrasts{con_idx}.Weights = json_out.fcon(j).Weights;
                    json_out_.Nodes{1}.Contrasts{con_idx}.Test = 'F';
                end
            end
            if isfield(json_out, 'DummyContrastNames') && ~isempty(json_out.DummyContrastNames)
                json_out_.Nodes{1}.DummyContrasts.Test = 't';
                json_out_.Nodes{1}.DummyContrasts.Contrasts = json_out.DummyContrastNames;
            end
            % write json file with finalised first level node
            fid = fopen(json_path_out, 'w+');
            encodedJSON = jsonencode(json_out_, PrettyPrint=true);
            fprintf(fid, encodedJSON);
            fclose(fid);
        end
    end
    if json_out.Template == "Second level" || json_out.Template == "First + Second level"
        if json_out.Template == "Second level"
            firstLv_json = load_json(json_out.JsonPath);
            if isempty(json_out_.Name)
                json_out_.Name = firstLv_json.json.Name; % keep original name if left empty
            end
            if isempty(json_out_.Description)
                json_out_.Description = firstLv_json.json.Description; % keep original description if left empty
            end
            if strcmp(firstLv_json.nodes{end}.Level, 'Dataset') % delete & re-define second level node if already exists
                firstLv_json.nodes(end) = [];
                firstLv_json.edges(end) = [];
            end
            node_idx = length(firstLv_json.nodes) + 1;
        else
            firstLv_json = json_out_;
            firstLv_json.nodes = json_out_.Nodes;
            firstLv_json.edges = json_out_.Edges;
            node_idx = 2;
            % repeat while loop for second level inputs
            status_id = 20; % Second level selection window for main selection 'First + Second level'
            progr_sequence.prev = [1;2;3;-1;-1;3; 6;6; 7; 7;7; 8; 1;20;20;20;20;20;20;20;20;-1;12;13;14;15;16;17;17;-1;-1;18;-1;20;30;30;32;33;-1;35;35;35]; % update program sequence
            while status_id < 50 % this value must be changed according to # of states
                if status_id == -1
                    return;
                end
                [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(status_id, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
            end
        end
        json_out_.Nodes{node_idx}.Level = 'Dataset';
        json_out_.Nodes{node_idx}.Name = get_default_values('NodeNameSecondLevel');
        json_out_.Nodes{node_idx}.GroupBy = []; % not implemented yet
        json_out_.Nodes{node_idx}.Transformations.Transformer = get_default_values('TransformerName');
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Name = get_default_values('InstructionNameSecondLevel');
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.MainProjectFolder = strrep(json_out.MainFolder,'\','/');
        if isempty(json_out.OutputDirLv2)
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.OutputDirectory = get_default_output_dir_lv2(json_out.FirstLvOutputDir);
        else
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.OutputDirectory = strrep(json_out.OutputDirLv2,'\','/');
        end
        if json_out.DesignTypeLv2 == "One sample t-test"
            design_type = 1;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'OneSampleTTest';
            if strcmp(json_out.oneSampleTTest.InputFileType, 'con') || strcmp(json_out.oneSampleTTest.InputFileType, 'other')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess = json_out.oneSampleTTest.ConNamesLv2;
            elseif strcmp(json_out.oneSampleTTest.InputFileType, 'beta')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneSampleTTest.Scans.ContrastsToProcess = json_out.oneSampleTTest.BetasLv2;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneSampleTTest.Scans.InputFileType = json_out.oneSampleTTest.InputFileType;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneSampleTTest.Scans.InputFilterRegexp = json_out.oneSampleTTest.InputFileRegexp;
        elseif json_out.DesignTypeLv2 == "Two sample t-test"
            design_type = 2;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'TwoSampleTTest';
            if strcmp(json_out.twoSampleTTest.InputFileType, 'con') || strcmp(json_out.twoSampleTTest.InputFileType, 'other')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess = json_out.twoSampleTTest.ConNamesLv2;
            elseif strcmp(json_out.twoSampleTTest.InputFileType, 'beta')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.ContrastsToProcess = json_out.twoSampleTTest.BetasLv2;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.InputFileType = json_out.twoSampleTTest.InputFileType;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup1 = json_out.twoSampleTTest.SubID1;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup1 = json_out.twoSampleTTest.InputFileRegexp1;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.SubjectsGroup2 = json_out.twoSampleTTest.SubID2;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Scans.InputFilterRegexpGroup2 = json_out.twoSampleTTest.InputFileRegexp2;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Independence = json_out.twoSampleTTest.IndepFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.Variance = json_out.twoSampleTTest.VarianceFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.GrandMeanScaling = json_out.twoSampleTTest.ScalingFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputTwoSampleTTest.ANCOVA = json_out.twoSampleTTest.ANCOVAFlag;
        elseif json_out.DesignTypeLv2 == "Paired t-test" % only the first array element of scans can be filled with the UI
            design_type = 3;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'PairedTTest';
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.InputFileType1 = json_out.pairedTTest.InputFileType1;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.InputFilterRegexp1 = json_out.pairedTTest.InputFileRegexp1;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.InputFileType2 = json_out.pairedTTest.InputFileType2;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.InputFilterRegexp2 = json_out.pairedTTest.InputFileRegexp2;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.Subjects1 = json_out.pairedTTest.SubID1;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.Subjects2 = json_out.pairedTTest.SubID2;
            if strcmp(json_out.pairedTTest.InputFileType1, 'con') || strcmp(json_out.pairedTTest.InputFileType1, 'other')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.Contrasts1 = json_out.pairedTTest.ConNamesLv2_1;
            elseif strcmp(json_out.pairedTTest.InputFileType1, 'beta')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.Contrasts1 = json_out.pairedTTest.BetasLv2_1;
            end
            if strcmp(json_out.pairedTTest.InputFileType2, 'con') || strcmp(json_out.pairedTTest.InputFileType2, 'other')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.Contrasts2 = json_out.pairedTTest.ConNamesLv2_2;
            elseif strcmp(json_out.pairedTTest.InputFileType2, 'beta')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.Scans{1}.Contrasts2 = json_out.pairedTTest.BetasLv2_2;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.GrandMeanScaling = json_out.pairedTTest.ScalingFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputPairedTTest.ANCOVA = json_out.pairedTTest.ANCOVAFlag;
        elseif json_out.DesignTypeLv2 == "Multiple Regression"
            design_type = 4;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'MultipleRegression';
            if strcmp(json_out.multiReg.InputFileType, 'con') || strcmp(json_out.multiReg.InputFileType, 'other')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess = json_out.multiReg.ConNamesLv2;
            elseif strcmp(json_out.multiReg.InputFileType, 'beta')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Scans.ContrastsToProcess = json_out.multiReg.BetasLv2;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Scans.InputFileType = json_out.multiReg.InputFileType;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Scans.InputFilterRegexp = json_out.multiReg.InputFileRegexp;
            if json_out.multiReg.NumberOfCovariatesMultiReg == 0
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Covariates = [];
            end
            for j = 1:json_out.multiReg.NumberOfCovariatesMultiReg
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Covariates{j}.CovariatesFileRegexp = json_out.multiReg.cov(j).CovMultiRegRegexp;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Covariates{j}.Name = json_out.multiReg.cov(j).CovariateMultiRegName;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Covariates{j}.ColName = json_out.multiReg.cov(j).CovMultiRegCol;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Covariates{j}.Centering = json_out.multiReg.cov(j).CovMultiRegCentering;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputMultipleRegression.Intercept = json_out.multiReg.Intercept;
        elseif json_out.DesignTypeLv2 == "One Way ANOVA"
            design_type = 5;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'OneWayANOVA';
            for j = 1:json_out.ANOVA.NumberOfCells
                if strcmp(json_out.ANOVA.cell(j).InputFileType, 'con') || strcmp(json_out.ANOVA.cell(j).InputFileType, 'other')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Cells{j}.ContrastToProcess = json_out.ANOVA.cell(j).ConNameLv2{1};
                elseif strcmp(json_out.ANOVA.cell(j).InputFileType, 'beta')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Cells{j}.ContrastToProcess = json_out.ANOVA.cell(j).BetaLv2{1};
                end
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Cells{j}.Subject_ID = json_out.ANOVA.cell(j).SubID;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Cells{j}.InputFileTypeGroup = json_out.ANOVA.cell(j).InputFileType;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Cells{j}.InputFilterRegexpGroup = json_out.ANOVA.cell(j).InputFileRegexp;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Independence = json_out.ANOVA.IndepFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.Variance = json_out.ANOVA.VarianceFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.GrandMeanScaling = json_out.ANOVA.ScalingFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVA.ANCOVA = json_out.ANOVA.ANCOVAFlag;
        elseif json_out.DesignTypeLv2 == "One Way ANOVA within subject"
            design_type = 6;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'OneWayANOVA_WithinSubject';
            for j = 1:json_out.subANOVA.NumberOfSubjects
                if strcmp(json_out.subANOVA.subj(j).InputFileType, 'con') || strcmp(json_out.subANOVA.subj(j).InputFileType, 'other')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{j}.ContrastsToProcess = json_out.subANOVA.subj(j).ConNamesLv2(json_out.subANOVA.subj(j).ConAssignment);
                elseif strcmp(json_out.subANOVA.subj(j).InputFileType, 'beta')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{j}.ContrastsToProcess = json_out.subANOVA.subj(j).BetasLv2(json_out.subANOVA.subj(j).ConAssignment);
                end
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{j}.InputFileType = json_out.subANOVA.subj(j).InputFileType;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{j}.InputFilterRegexp = json_out.subANOVA.subj(j).InputFileRegexp;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Subjects{j}.Subject_ID = json_out.subANOVA.subj(j).SubID;
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Independence = json_out.subANOVA.IndepFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.Variance = json_out.subANOVA.VarianceFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.GrandMeanScaling = json_out.subANOVA.ScalingFlag;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputOneWayANOVAWithinSubject.ANCOVA = json_out.subANOVA.ANCOVAFlag;
        elseif json_out.DesignTypeLv2 == "Full Factorial"
            design_type = 7;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'FullFactorial';
            for j = 1:json_out.fullFact.NumberOfFactors
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Factors{j}.Name = json_out.fullFact.fact(j).FactorName;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Factors{j}.Levels = json_out.fullFact.fact(j).FactorLevels;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Factors{j}.Independence = json_out.fullFact.fact(j).IndepFlag;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Factors{j}.Variance = json_out.fullFact.fact(j).VarianceFlag;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Factors{j}.GrandMeanScaling = json_out.fullFact.fact(j).ScalingFlag;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Factors{j}.ANCOVA = json_out.fullFact.fact(j).ANCOVAFlag;
            end
            for j = 1:json_out.fullFact.NumberOfCells
                if strcmp(json_out.fullFact.cell(j).InputFileType, 'con') || strcmp(json_out.fullFact.cell(j).InputFileType, 'other')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.ContrastToProcess = json_out.fullFact.cell(j).ConNameLv2{1};
                elseif strcmp(json_out.fullFact.cell(j).InputFileType, 'beta')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.ContrastToProcess = json_out.fullFact.cell(j).BetaLv2{1};
                end
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.Subject_ID = json_out.fullFact.cell(j).SubID;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.InputFileType = json_out.fullFact.cell(j).InputFileType;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.InputFilterRegexp = json_out.fullFact.cell(j).InputFileRegexp;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.Levels = json_out.fullFact.cell(j).LevelsVector;
                if isempty(json_out.fullFact.cell(j).LevelsVector)
                    warning('No levels vector defined for cell %d. Manual entry in json file required to avoid error.', j);
                elseif size(json_out.fullFact.cell(j).LevelsVector, 1) > 1
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.Levels = json_out.fullFact.cell(j).LevelsVector(1,:);
                    warning('Only the first row of the levels vector is used for the Full Factorial design.');
                else
                    if size(json_out.fullFact.cell(j).LevelsVector, 2) ~= json_out.fullFact.NumberOfFactors
                        warning('Number of levels in cell %d does not match the number of factors. Manual entry in json file required to avoid error.', j);
                    end
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.Cells{j}.Levels = json_out.fullFact.cell(j).LevelsVector;
                end
            end
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFullFactorial.GenerateContrasts = json_out.fullFact.GenerateContrasts;
        elseif json_out.DesignTypeLv2 == "Flexible Factorial"
            design_type = 8;
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.Type = 'FlexibleFactorial';
            for j = 1:json_out.flexFact.NumberOfFactors
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Factors{j}.Name = json_out.flexFact.fact(j).FactorName;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Factors{j}.Independence = json_out.flexFact.fact(j).IndepFlag;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Factors{j}.Variance = json_out.flexFact.fact(j).VarianceFlag;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Factors{j}.GrandMeanScaling = json_out.flexFact.fact(j).ScalingFlag;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Factors{j}.ANCOVA = json_out.flexFact.fact(j).ANCOVAFlag;
            end
            for j = 1:json_out.flexFact.NumberOfSubjects
                if strcmp(json_out.flexFact.subj(j).InputFileType, 'con') || strcmp(json_out.flexFact.subj(j).InputFileType, 'other')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Subjects{j}.ContrastsToProcess = json_out.flexFact.subj(j).ConNamesLv2;
                elseif strcmp(json_out.flexFact.subj(j).InputFileType, 'beta')
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Subjects{j}.ContrastsToProcess = json_out.flexFact.subj(j).BetasLv2;
                end
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Subjects{j}.Subject_ID = json_out.flexFact.subj(j).SubID;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Subjects{j}.InputFileType = json_out.flexFact.subj(j).InputFileType;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Subjects{j}.InputFilterRegexp = json_out.flexFact.subj(j).InputFileRegexp;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.Subjects{j}.Conditions = json_out.flexFact.subj(j).ConAssignment;
                if size(json_out.flexFact.subj(j).ConAssignment, 1) ~= length(json_out.flexFact.subj(j).ConNamesLv2)
                    warning('Number of conditions in subject %d does not match the number of contrasts. Manual entry in json file required to avoid error.', j);
                end
                if size(json_out.flexFact.subj(j).ConAssignment, 2) ~= json_out.flexFact.NumberOfFactors
                    warning('Number of columns in factor assignment of subject %d does not match the number of factors. Manual entry in json file required to avoid error.', j);
                end
            end
            idx_main_eff_interact = 1;
            idx_main_eff = 1;
            for j = 1:json_out.flexFact.NumberOfFactors
                if json_out.flexFact.fact(j).mainEffect == "on"
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{1}.Type = 'MainEffect';
                    json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{1}.FactorNames{idx_main_eff} = json_out.flexFact.fact(j).FactorName;
                    idx_main_eff = idx_main_eff + 1;
                    idx_main_eff_interact = 2;
                end
            end
            for j = 1:json_out.flexFact.NumberOfInteractions
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{idx_main_eff_interact}.Type = 'Interaction';
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{idx_main_eff_interact}.FactorNames{1} = json_out.flexFact.fact(json_out.flexFact.interact(j).InteractionsFactor1).FactorName;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions{idx_main_eff_interact}.FactorNames{2} = json_out.flexFact.fact(json_out.flexFact.interact(j).InteractionsFactor2).FactorName;
                idx_main_eff_interact = idx_main_eff_interact + 1;
            end
        end
        % Covariates
        if isfield(json_out, 'multiCov') && ~isempty(json_out.multiCov)
            for multi_cov_idx = 1:length(json_out.multiCov)
                if ~isequal(length(json_out.multiCov(multi_cov_idx).MultiCovName), length(json_out.multiCov(multi_cov_idx).MultiCovCol))
                    error('Number of covariate names and number of corresponding columns must be equal.');
                end
            end
        end
        if json_out.NumberOfCovariatesSettings == 0
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Covariates = [];
        end
        cov_idx = 0;
        for j = 1:json_out.NumberOfCovariatesSettings
            for k = 1:length(json_out.multiCov(j).MultiCovName)
                cov_idx = cov_idx + 1;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Covariates{cov_idx}.CovariatesFileRegexp = json_out.multiCov(j).MultiCovRegexp;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Covariates{cov_idx}.Name = json_out.multiCov(j).MultiCovName{k};
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Covariates{cov_idx}.ColName = json_out.multiCov(j).MultiCovCol{k};
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Covariates{cov_idx}.Interactions = json_out.multiCov(j).MultiCovInteractions;
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Covariates{cov_idx}.Centering = json_out.multiCov(j).MultiCovCentering;
                %json_out.multiCov(j).CovUserCenteringManual does not seem to have a corresponding variable in the batch file
            end
        end
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Masking.ThresholdMasking.Type = json_out.ThresholdMasking;
        if ~isempty(json_out.ThresholdValueMask)
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Masking.ThresholdMasking.ThresholdValue = json_out.ThresholdValueMask;
        else
            if strcmp(json_out.ThresholdMasking, 'Absolute')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Masking.ThresholdMasking.ThresholdValue = get_default_values('ThresholdValueMaskAbs');
            elseif strcmp(json_out.ThresholdMasking, 'Relative')
                json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Masking.ThresholdMasking.ThresholdValue = get_default_values('ThresholdValueMaskRel');
            end
        end
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Masking.ImplicitMask = json_out.ImplicitMask;
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.Masking.ExplicitMask = strrep(json_out.ExplicitMask,'\','/');
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalCalculation.Type = json_out.GlobalCalculation;
        if strcmp(json_out.GlobalCalculation, 'User') && ~isempty(json_out.GlobalCalculationValues)
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalCalculation.UserSpecifiedValues{1} = json_out.GlobalCalculationValues;
        else
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalCalculation.UserSpecifiedValues{1} = [];
        end
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalNormalisation.OverallGrandMeanScaling = json_out.OverallGrandMeanScaling;
        if ~isempty(json_out.OverallGrandMeanScalingValue)
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalNormalisation.UserSpecifiedValue = json_out.OverallGrandMeanScalingValue;
        else
            json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalNormalisation.UserSpecifiedValue = get_default_values('OverallGrandMeanScalingValue');
        end
        json_out_.Nodes{node_idx}.Transformations.Instructions{1}.Input.GlobalNormalisation.Normalisation = json_out.Normalisation;
        json_out_.Nodes{node_idx}.Model.Type = json_out.ModelTypeBIDSLv2;
        json_out_.Nodes{node_idx}.Model.X = [];
        json_out_.Nodes{node_idx}.Model.Software{1}.SPM.WriteResiduals = json_out.WriteResidualsLv2;
        json_out_.Nodes{node_idx}.Model.Software{1}.SPM.Method.Type = json_out.EstMethodLv2;
        json_out_.Nodes{node_idx}.Model.Software{1}.SPM.DeleteExistingContrasts = json_out.DeleteExistingContrastsLv2;
        json_out_.Nodes{node_idx}.Model.Software{1}.SPM.ReplicateOverSessions = json_out.ReplOverSessionsLv2;
        % create Contrasts section
        if json_out.DefineContrastsFlagLv2 == 0
            % add empty contrasts to json
            json_out_.Nodes{node_idx}.Contrasts = [];
            json_out_.Nodes{node_idx}.DummyContrasts = struct('Test', {''}, 'Contrasts', {[]});
        end
        % create Edges section
        json_out_.Edges{1}.Source = firstLv_json.nodes{node_idx-1}.Name;
        json_out_.Edges{1}.Destination = json_out_.Nodes{node_idx}.Name;
        json_out_.Edges{1}.Filter = struct(); % unsupported so far
        % combine nodes & fix escape characters in json
        nodes_ = firstLv_json.nodes;
        nodes_{node_idx} = json_out_.Nodes{node_idx};
        nodes_ = fix_escape_characters_json_output(nodes_, node_idx-1, 1, node_idx, 1, design_type);
        json_out_.Nodes = nodes_;
        % combine edges
        edge_flag = 0;
        if isfield(firstLv_json, 'edges')
            edges_ = firstLv_json.edges;
            for i = length(edges_):-1:1
                if isempty(edges_{i}.Source) || isempty(edges_{i}.Destination)
                    edges_{i} = json_out_.Edges{1};
                    edge_flag = 1;
                    break;
                end
            end
            if ~edge_flag
                edges_{length(edges_)+1} = json_out_.Edges{1};
            end
        else
            edges_{1} = json_out_.Edges{1};
        end
        json_out_.Edges = edges_;
        % write preliminary json file
        if json_out.Template == "Second level"
            if json_out.WriteOption == 1
                pth = fileparts(json_out.JsonPath);
                if strcmpi(json_out.NewFileName(end-4:end), '.json')
                    json_path_out = fullfile(pth, json_out.NewFileName);
                else
                    json_path_out = fullfile(pth, [json_out.NewFileName '.json']);
                end
            else
                json_path_out = json_out.JsonPath;
            end
        end
        fid = fopen(json_path_out, 'w');
        encodedJSON = jsonencode(json_out_, PrettyPrint=true);
        fprintf(fid,encodedJSON);
        fclose(fid);
        if strcmp(json_out.Template, 'First + Second level')
            fprintf('Second level node written to %s. \n', json_path_out);
            fprintf('Please run the first level analysis using the prompt SPM_batch_creator(1). \n');
            fprintf('Afterwards, run the second level analysis using the prompt SPM_batch_creator(2). \n');
            fprintf('The second level node will be updated with the predictors list, which can be used to define contrasts. \n');
            fprintf('Finally, re-run SPM_batch_creator(2) with the updated .json file. \n');
        end
        % the following part can only be executed if the first level analysis is already performed
        if json_out.Template == "Second level"
            if json_out.DefineContrastsFlagLv2 == 1
                % check data and write X array to json
                SPM_batch_creator(2,0,json_path_out,1);
                updated_json_ = load_json(json_path_out);
                updated_json = updated_json_.json;
                updated_json.Nodes = updated_json_.nodes;
                updated_json.Edges = updated_json_.edges;
                json_out_.Nodes{node_idx}.Model.X = updated_json.Nodes{node_idx}.Model.X;
                json_out.X = updated_json.Nodes{node_idx}.Model.X;
                % repeat while loop for contrasts
                status_id = 35; % Definition of Contrasts
                while status_id < 50 % this value must be changed according to # of states
                    if status_id == -1
                        return;
                    end
                    [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(status_id, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                end
                % update json file with contrasts
                con_idx = 0;
                if isfield(json_out, 'tContrastNames') && ~isempty(json_out.tContrastNames)
                    for j = 1:length(json_out.tContrastNames)
                        con_idx = con_idx + 1;
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.Name = json_out.tContrastNames{j};
                        actual_weights = json_out.tContrastWeights(j,:);
                        non_zero_idx = find(actual_weights ~= 0);
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.ConditionList = json_out.X(non_zero_idx);
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.Weights = actual_weights(non_zero_idx);
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.Test = 't';
                    end
                end
                if isfield(json_out, 'fContrastNames') && ~isempty(json_out.fContrastNames)
                    for j = 1:length(json_out.fContrastNames)
                        con_idx = con_idx + 1;
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.Name = json_out.fContrastNames{j};
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.ConditionList = json_out.X;
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.Weights = json_out.fcon(j).Weights;
                        json_out_.Nodes{node_idx}.Contrasts{con_idx}.Test = 'F';
                    end
                end
                if isfield(json_out, 'DummyContrastNames') && ~isempty(json_out.DummyContrastNames)
                    json_out_.Nodes{node_idx}.DummyContrasts.Test = 't';
                    json_out_.Nodes{node_idx}.DummyContrasts.Contrasts = json_out.DummyContrastNames;
                end
                % write json file with finalised second level node
                fid = fopen(json_path_out, 'w+');
                encodedJSON = jsonencode(json_out_, PrettyPrint=true);
                fprintf(fid, encodedJSON);
                fclose(fid);
            end
        end
    end
end

% Selector function for window-based user input
function [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(status_id, options, output_, json_out, input_buffer, progr_sequence, repeat_args)
    switch status_id
        case 1 % Primary selection window
            window_props.name = 'Choose template';
            window_props.prompt = {'json template selection'; 'Main folder:';'Task:'; 'Model name:'; 'Description:'; 'Select .json model file (required only for option "Second level")'}; %prompt string
            window_props.prompt(:,2) = {'template';'mainFolder';'task';'modelName';'description';'jsonPath'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'choose template'; 'choose main folder of the study';'enter name';'enter (unique) model name';'concise model desription (optional)';sprintf('file must contain first level node \n(with the same structure as defined in the format file)')}; %tooltip string
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'popupmenu';
            window_props.formats(1,1).items  = {'First level','Second level','First + Second level'};
            window_props.formats(1,1).size = [170 20];
            window_props.formats(2,1).type = 'edit';
            window_props.formats(2,1).format = 'dir';
            window_props.formats(2,1).size = [400 20];
            window_props.formats(3,1).type   = 'edit';
            window_props.formats(3,1).format  = 'text';
            window_props.formats(3,1).size = [170 20];
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format  = 'text';
            window_props.formats(4,1).size = [170 20];
            window_props.formats(5,1).type   = 'edit';
            window_props.formats(5,1).format  = 'text';
            window_props.formats(5,1).size = [400 20];
            window_props.formats(6,1).type   = 'edit';
            window_props.formats(6,1).format  = 'file';
            window_props.formats(6,1).size = [400 20];
            window_props.defaultanswers = {1,'','','','',''};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = main_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                if output.template == 2 % "Second level" requires to get info from previously defined first level node
                    % load .json file with first level node
                    if ~isempty(output.jsonPath)
                        json_out.JsonPath = strtrim(output.jsonPath);
                    else
                        error('No .json file selected. Operation cancelled.');
                    end
                    firstLv_json = load_json(json_out.JsonPath);
                    % get relevant information from first level node
                    json_out.FirstLvSubID = firstLv_json.nodes{1}.Transformations.Instructions{1}.Input.Participant_ID;
                    json_out.FirstLvOutputDir = firstLv_json.nodes{1}.Transformations.Instructions{1}.Input.OutputDirectory;
                    json_out.FirstLvBetas = firstLv_json.nodes{1}.Model.X;
                    if isfield(firstLv_json.nodes{1}, 'Contrasts') && ~isempty(firstLv_json.nodes{1}.Contrasts) && ...
                        isfield(firstLv_json.nodes{1}.Contrasts{1}, 'Name') && ~isempty(firstLv_json.nodes{1}.Contrasts{1}.Name)
                        json_out.FirstLvConNames = cellfun(@(x) x.Name, firstLv_json.nodes{1}.Contrasts, 'UniformOutput', false);
                        if size(firstLv_json.nodes{1}.Contrasts, 2) > 1
                            json_out.FirstLvConNames = json_out.FirstLvConNames';
                        end
                    else
                        json_out.FirstLvConNames = {};
                    end
                    if isfield(firstLv_json.nodes{1}, 'DummyContrasts') && ~isempty(firstLv_json.nodes{1}.DummyContrasts) && ...
                        isfield(firstLv_json.nodes{1}.DummyContrasts, 'Contrasts') && ~isempty(firstLv_json.nodes{1}.DummyContrasts.Contrasts)
                        json_out.FirstLvDummyCons = firstLv_json.nodes{1}.DummyContrasts.Contrasts;
                        if size(firstLv_json.nodes{1}.DummyContrasts.Contrasts, 2) > 1
                            json_out.FirstLvDummyCons = json_out.FirstLvDummyCons';
                        end
                    else
                        json_out.FirstLvDummyCons = {};
                    end
                    json_out.FirstLvAllCons = [json_out.FirstLvConNames; json_out.FirstLvDummyCons];
                    if isempty(json_out.FirstLvAllCons)
                        error('No contrasts defined in the first level node. Cannot define second level batch. Operation cancelled.');
                    end
                end
                output_{1} = output;
                json_out.Template = char(window_props.formats(1,1).items(output.template));
                json_out.MainFolder = strtrim(output.mainFolder);
                json_out.Task = strtrim(output.task);
                json_out.ModelName = strtrim(output.modelName);
                json_out.Description = strtrim(output.description);
            end
        case 2 % First level selection window
            idx = 1;
            subjectFoldersPreproc = spm_select(Inf, 'dir', 'Select subject directories (preprocessed folders) [all must be in the same directory]');
            json_out.SubjectFoldersPreproc = cell(size(subjectFoldersPreproc, 1), 1);
            for i = 1:size(subjectFoldersPreproc, 1)
                json_out.SubjectFoldersPreproc{i, 1} = deblank(subjectFoldersPreproc(i,:));
            end
            default_output_dir = get_default_output_dir(json_out.SubjectFoldersPreproc{1},'vis');
            default_output_prompt = ['Default output directory: ', default_output_dir];
            window_props.name = 'First level input';
            window_props.prompt = {'Estimation method:';'Regular expression for input file selection:';'Image type:';'Select output directory (leave empty to use default)';default_output_prompt; 'Level of first level analysis'; 'BIDS-compliant dataset';'go back to main'};
            window_props.prompt(:,2) = {'firstLvDesignType';'inputFileRegExp';'imageType';'outputDirFirstLv';'defaultOutputDir';'level';'BIDSflag';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'Bayesian not supported yet','','','leave empty to use default','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'popupmenu';
            window_props.formats(1,1).items  = {'Classical','Bayesian'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'edit';
            window_props.formats(2,1).format = 'text';
            window_props.formats(2,1).size = [400 20];
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items  = {'3d','4d'}; %,'unknown'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'edit';
            window_props.formats(4,1).format = 'dir';
            window_props.formats(4,1).size = [400 20];
            window_props.formats(5,1).type = 'text';
            window_props.formats(6,1).type   = 'list';
            window_props.formats(6,1).style = 'popupmenu';
            window_props.formats(6,1).items  = {'Run','Session','Subject'};
            window_props.formats(6,1).size = [170 20];
            window_props.formats(7,1).type   = 'list';
            window_props.formats(7,1).style = 'radiobutton';
            window_props.formats(7,1).items  = {'no','yes'};
            window_props.formats(7,1).size = [170 20];
            window_props.formats(8,1).type   = 'check';
            window_props.formats(8,1).format  = 'text';
            window_props.defaultanswers = {1,'^s8w.*nii',1,'',default_output_dir,3,2,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{2} = output;
                json_out.DesignTypeLv1 = char(window_props.formats(1,1).items(output.firstLvDesignType));
                json_out.InputFileRegexp = strtrim(output.inputFileRegExp);
                json_out.ImageType = char(window_props.formats(3,1).items(output.imageType));
                json_out.OutputDirLv1 = strtrim(output.outputDirFirstLv);
                json_out.Level = char(window_props.formats(6,1).items(output.level));
                json_out.BIDSFlag = output.BIDSflag - 1;
            end
        case 3 % Timing parameters and number of sessions
            temp_status_id = status_id;
            idx = 1;
            window_props.name = 'Timing / Sessions';
            window_props.prompt = {'Units for design:';'Interscan interval:';'Microtime resolution:';'Microtime onset:';'Number of sessions:';'go back'};
            window_props.prompt(:,2) = {'designUnits';'interscanInterval';'microtimeResolution';'microtimeOnset';'numberSessions';'goBackInd'}; %struct field names of ANSWER output
            window_props.prompt(:,3) = {'';'s';'ms';'ms';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items  = {'secs','scans'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'float';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'edit';
            window_props.formats(3,1).format  = 'float';
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'edit';
            window_props.formats(4,1).format  = 'float';
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type = 'edit';
            window_props.formats(5,1).format = 'integer';
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {1,'',16,8,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            elseif output.numberSessions < 1
                status_id = -1;
                fprintf('Program terminated. Enter at least 1 session\n');
                return;
            else
                output_{3} = output;
                json_out.UnitsForDesign = char(window_props.formats(1,1).items(output.designUnits));
                json_out.InterscanInterval = output.interscanInterval;
                json_out.MicrotimeResolution = output.microtimeResolution;
                json_out.MicrotimeOnset = output.microtimeOnset;
                json_out.NumberOfSessions = output.numberSessions;
                repeat_args.id4 = output.numberSessions;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    % repeat the Sessions window according to the number of sessions
                    for idx_sess = 1:repeat_args.id4
                        if status_id == -1
                            return;
                        else
                            repeat_args.sess_id = idx_sess;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(4, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                end
            end
        case 4 % Sessions (must be executed several times according to output.numberSessions or json_out.NumberOfSessions)
            idx = repeat_args.sess_id;
            if idx < repeat_args.id4
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            temp_status_id = status_id;
            window_props.name = ['Session ', num2str(idx)];
            window_props.prompt = {'Session identifier:';'High-pass filter:';'Regular expression for \_events.tsv:';'Regular expression for Multiple Conditions Files:';'Number of conditions for manual input:';'Regular expression for Multiple Regressors Files:';'Run ids:';'go back'};
            window_props.prompt(:,2) = {'sessionIdentifier';'highPassFilterSecs';'eventsRegex';'multipleConditionsRegex';'nConditions';'multipleRegressorsRegex';'runIds';'goBackInd'}; %struct field names of ANSWER output
            window_props.prompt(:,3) = {'';'s';'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            if idx < repeat_args.id4
                window_props.prompt(:,4) = {'not needed for single session analyses; is expected to be the rightmost character of the folder name (e.g. 1 or a)','in seconds!','','.mat file','','.tsv OR .mat OR .txt file','enter comma-separated list of run-ids (must be numeric)',['only active on last session (', num2str(repeat_args.id4), ')']};
            else
                window_props.prompt(:,4) = {'not needed for single session analyses; is expected to be the rightmost character of the folder name (e.g. 1 or a)','in seconds!','','.mat file','','.tsv OR .mat OR .txt file','enter comma-separated list of run-ids (must be numeric)','click OK after activation'};
            end
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'float';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'edit';
            window_props.formats(3,1).format  = 'text';
            window_props.formats(3,1).size = [300 20];
            window_props.formats(4,1).type = 'edit';
            window_props.formats(4,1).format  = 'text';
            window_props.formats(4,1).size = [300 20];
            window_props.formats(5,1).type = 'edit';
            window_props.formats(5,1).format  = 'integer';
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type = 'edit';
            window_props.formats(6,1).format  = 'text';
            window_props.formats(6,1).size = [300 20];
            window_props.formats(7,1).type = 'edit';
            window_props.formats(7,1).format = 'text';
            window_props.formats(7,1).size = [300 20];
            window_props.formats(8,1).type   = 'check';
            window_props.formats(8,1).format  = 'text';
            window_props.defaultanswers = {'',128,'events\.tsv$','','','motion\.tsv$','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{4} = output;
                json_out.sess(idx).SessionIdentifier = strtrim(output.sessionIdentifier);
                json_out.sess(idx).HighPassFilterSecs = output.highPassFilterSecs;
                json_out.sess(idx).EventsRegex = strtrim(output.eventsRegex);
                json_out.sess(idx).MultipleConditionsRegex = strtrim(output.multipleConditionsRegex);
                json_out.sess(idx).NumberOfConditions = output.nConditions;
                json_out.sess(idx).MultipleRegressorsRegex = strtrim(output.multipleRegressorsRegex);
                json_out.sess(idx).RunIds = strtrim(output.runIds);
                repeat_args.sess(idx).id5 = output.nConditions;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    % repeat the Conditions window according to the number of conditions
                    for idx_cond = 1:repeat_args.sess(idx).id5
                        if status_id == -1
                            return;
                        else
                            repeat_args.cond_id = idx_cond;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(5, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                end
            end
        case 5 % Conditions (must be executed several times according to output.nConditions or json_out.NumberOfConditions(idx)
            idx_sess = repeat_args.sess_id;
            idx = repeat_args.cond_id;
            if idx < repeat_args.sess(idx_sess).id5
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            window_props.name = ['Condition ', num2str(idx), ' (Session ', num2str(idx_sess), ')'];
            window_props.prompt = {'Entry in trial\_type column:';'Order of time modulation:';'Number of parametric modulations:';'Orthogonalise modulations:'};%;'go back'};
            window_props.prompt(:,2) = {'trialType';'orderTimeMod';'nParametricModulations';'orthMod'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'must be unique','','',''};%,'unavailable in this screen'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'no time modulation','1','2','3','4','5','6'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'edit';
            window_props.formats(3,1).format  = 'integer';
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'no','yes'};
            window_props.formats(4,1).size = [130 20];
            %window_props.formats(5,1).type   = 'check';
            %window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {'',1,0,1};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            %output.goBackInd = 'off';
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{5} = output;
                json_out.sess(idx_sess).cond(idx).TrialType = strtrim(output.trialType);
                json_out.sess(idx_sess).cond(idx).TimeModulation = output.orderTimeMod - 1;
                json_out.sess(idx_sess).cond(idx).NumberOfParametricModulations = output.nParametricModulations;
                json_out.sess(idx_sess).cond(idx).OrthogonaliseModulations = output.orthMod - 1;
                repeat_args.sess(idx_sess).cond(idx).id40 = output.nParametricModulations;
                % repeat the Parametric modulations window according to the number of parametric modulations
                for idx_pmod = 1:repeat_args.sess(idx_sess).cond(idx).id40
                    if status_id == -1
                        return;
                    else
                        repeat_args.pmod_id = idx_pmod;
                        [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(40, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                    end
                end
            end
        case 6 % Masking & Factorial design
            idx = 1;
            temp_status_id = status_id;
            window_props.name = 'Masking / Factorial design';
            window_props.prompt = {'Masking threshold:';'Explicit mask';'Factorial design:';'Number of factors for factorial design';'go back'};
            window_props.prompt(:,2) = {'maskThresh';'explMask';'factDesignFlag';'nFactors';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'float';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'file';
            window_props.formats(2,1).size = [400 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format = 'integer';
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {0.8,'',1,2,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{6} = output;
                json_out.MaskThreshold = output.maskThresh;
                json_out.ExplicitMask = strtrim(output.explMask);
                json_out.FactDesignFlag = output.factDesignFlag - 1;
                json_out.FactDesignFactors = output.nFactors;
                if output.factDesignFlag == 2
                    status_id = 41;
                end
                status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
            end
        case 7 % Additional options & Basis functions
            idx = 1;
            temp_status_id = status_id;
            window_props.name = 'Additional options / Basis functions';
            window_props.prompt = {'Model interactions Volterra:';'Global normalisation';'Serial correlations:';'Basis function type:';'go back'};
            window_props.prompt(:,2) = {'volterraFlag';'globalNorm';'serialCorr';'basisFctType';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','autoregressive','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'no','yes'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'none','scaling'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'popupmenu';
            window_props.formats(3,1).items = {'none','AR(1)','FAST'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'popupmenu';
            window_props.formats(4,1).items = {'Canonical HRF','Fourier set','Fourier set (Hanning)','Gamma functions','Finite impulse response','None'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {1,1,2,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{7} = output;
                json_out.VolterraFlag = output.volterraFlag - 1;
                json_out.GlobalNorm = output.globalNorm - 1;
                json_out.SerialCorr = char(window_props.formats(3,1).items(output.serialCorr));
                json_out.BasisFctType = char(window_props.formats(4,1).items(output.basisFctType));
                if json_out.BasisFctType == "Canonical HRF"
                    status_id = 42; % Options Canonical HRF
                elseif json_out.BasisFctType == "None"
                    ;
                else
                    status_id = 43; % Options other basis functions
                end
                status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
            end
        case 8 % Model estimation
            idx = 1;
            prompt_def_contrasts = sprintf('Check data to define contrasts:\n(this will take some time)');
            if strcmp(json_out.Template, 'First + Second level')
                hint_def_contrasts = 'This option is mandatory for "First + Second level" template';
            else
                hint_def_contrasts = 'if unchecked the contrasts have to be defined directly in the json file';
            end
            window_props.name = 'Model estimation';
            window_props.prompt = {'Model type:';'Write residuals:';'Delete existing contrasts:';'Replicate over sessions:';prompt_def_contrasts;'go back'};
            window_props.prompt(:,2) = {'modelType';'writeRes';'delContrasts';'replSessions';'defContrastsFlag';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'according to BIDS','','','',hint_def_contrasts,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'glm','meta'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'no','yes'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'popupmenu';
            window_props.formats(4,1).items = {'Dont replicate','Replicate','Replicate&Scale','Create per session','Both: Replicate + Create per session','Both: Replicate&Scale + Create per session'};
            window_props.formats(4,1).size = [400 20];
            if strcmp(json_out.Template, 'First + Second level')
                window_props.formats(5,1).type = 'list';
                window_props.formats(5,1).style = 'radiobutton';
                window_props.formats(5,1).items = {'yes'};
                window_props.formats(5,1).size = [130 20];
            else
                window_props.formats(5,1).type = 'list';
                window_props.formats(5,1).style = 'radiobutton';
                window_props.formats(5,1).items = {'no','yes'};
                window_props.formats(5,1).size = [130 20];
            end
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            if strcmp(json_out.Template, 'First + Second level')
                window_props.defaultanswers = {1,1,1,1,1,'off'};
            else
                window_props.defaultanswers = {1,1,1,1,2,'off'};
            end
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{8} = output;
                json_out.ModelTypeBIDS = char(window_props.formats(1,1).items(output.modelType));
                json_out.WriteResiduals = output.writeRes - 1;
                json_out.DeleteExistingContrasts = output.delContrasts - 1;
                json_out.ReplOverSessions = char(window_props.formats(4,1).items(output.replSessions));
                if strcmp(json_out.Template, 'First + Second level')
                    json_out.DefineContrastsFlag = 1;
                else
                    json_out.DefineContrastsFlag = output.defContrastsFlag - 1;
                end
            end
        case 9 % Save model file
            idx = 1;
            default_model_file = [json_out.ModelName, '_smdl.json'];
            default_model_file_prompt = ['Default model file name: ', strrep(default_model_file, '_', '\_')];
            default_model_dir = fullfile(json_out.MainFolder, 'models');
            default_model_dir_prompt = ['Default model output directory: ', strrep(strrep(default_model_dir,'\','/'), '_', '\_')];
            window_props.name = 'Save model file';
            window_props.prompt = {'Select model file name (leave empty to use default):';default_model_file_prompt;'Select model output directory (leave empty to use default):';default_model_dir_prompt;'Overwrite model file:';'go back'};
            window_props.prompt(:,2) = {'modelFileName';'defaultModelFile';'modelOutputDir';'defaultModelDir';'overwriteModel';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','',sprintf('if "no" is chosen, a number is added to the file name \nin case that the file already exists'),'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'text';
            window_props.formats(3,1).type   = 'edit';
            window_props.formats(3,1).format = 'dir';
            window_props.formats(3,1).size = [400 20];
            window_props.formats(4,1).type   = 'text';
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {'',default_model_file,'',default_model_dir,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                if isempty(output.modelFileName)
                    output.modelFileName = [json_out.ModelName, '_smdl.json'];
                end
                if isempty(output.modelOutputDir)
                    output.modelOutputDir = default_model_dir;
                end
                output_{9} = output;
                json_out.ModelFileName = strtrim(output.modelFileName);
                json_out.ModelOutputDir = strtrim(output.modelOutputDir);
                json_out.OverwriteModel = output.overwriteModel - 1;
            end
        case 10 % Second level selection window for main selection 'Second level'
            idx = 1;
            temp_status_id = status_id;
            % get default output directory
            default_output_dir_lv2 = get_default_output_dir_lv2(json_out.FirstLvOutputDir,'vis');
            default_output_prompt_lv2 = ['Default output directory: ', default_output_dir_lv2];
            prompt_def_contrasts = sprintf('Check data to define contrasts:\n(this will take some time)');
            [~,orig_json_file,~] = fileparts(json_out.JsonPath);
            window_props.name = 'Second level input';
            window_props.prompt = {'Design type';'Estimation method';'Select output directory (leave empty to use default)';default_output_prompt_lv2;prompt_def_contrasts;'Write second level node:';'Enter new file name:';'go back to main'};
            window_props.prompt(:,2) = {'secLvDesignType';'estMethodSecondLv';'outputDirSecondLv';'defaultOutputDir';'defContrastsFlag';'writeOption';'newFileName';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'select','','leave empty to use default','','if unchecked the contrasts have to be defined directly in the json file','','ignored if node is appended','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'popupmenu';
            window_props.formats(1,1).items  = {'One sample t-test','Two sample t-test', 'Paired t-test', 'Multiple Regression', 'One Way ANOVA', 'One Way ANOVA within subject','Full Factorial','Flexible Factorial'};
            window_props.formats(1,1).size = [200 20];
            %window_props.formats_second(1,1).labelloc = 'topcenter';
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'popupmenu';
            window_props.formats(2,1).items = {'Classical','Bayesian 2nd-level'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type   = 'edit';
            window_props.formats(3,1).format  = 'dir';
            window_props.formats(3,1).size = [400 20];
            window_props.formats(4,1).type = 'text';
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type = 'list';
            window_props.formats(6,1).style = 'radiobutton';
            window_props.formats(6,1).items = {'append to existing file','write new file'};
            window_props.formats(6,1).size = [130 20];
            window_props.formats(7,1).type   = 'edit';
            window_props.formats(7,1).format = 'text';
            window_props.formats(7,1).size = [300 20];
            window_props.formats(8,1).type   = 'check';
            window_props.formats(8,1).format  = 'text';
            window_props.defaultanswers = {1,1,'',default_output_dir_lv2,2,1,orig_json_file,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{10} = output;
                json_out.DesignTypeLv2 = char(window_props.formats(1,1).items(output.secLvDesignType));
                json_out.EstMethodLv2 = char(window_props.formats(2,1).items(output.estMethodSecondLv));
                json_out.OutputDirLv2 = strtrim(output.outputDirSecondLv);
                if json_out.DesignTypeLv2 == "One sample t-test"
                    status_id = 11;
                elseif json_out.DesignTypeLv2 == "Two sample t-test"
                    status_id = 12;
                elseif json_out.DesignTypeLv2 == "Paired t-test"
                    status_id = 13;
                elseif json_out.DesignTypeLv2 == "Multiple Regression"
                    status_id = 14;
                elseif json_out.DesignTypeLv2 == "One Way ANOVA"
                    status_id = 15;
                elseif json_out.DesignTypeLv2 == "One Way ANOVA within subject"
                    status_id = 16;
                elseif json_out.DesignTypeLv2 == "Full Factorial"
                    status_id = 17;
                elseif json_out.DesignTypeLv2 == "Flexible Factorial"
                    status_id = 18;
                end
                json_out.DefineContrastsFlagLv2 = output.defContrastsFlag - 1;
                json_out.WriteOption = output.writeOption - 1;
                json_out.NewFileName = strtrim(output.newFileName);
                status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
            end
        case 11 % Input One-sample t-test
            idx = 1;
            prompt_file_regexp = sprintf('Regular expression for input file selection: \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select all contrast names for which \nyou want to perform a one-sample t-test: \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select all beta names for which \nyou want to perform a one-sample t-test: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty); \nseparate regular expressions by %s if more than one contrast shall be processed', delimiter_verbose(get_default_values('FileRegexpNamesSeparator')));
            window_props.name = 'Input One-sample t-test';
            window_props.prompt = {'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp;'go back'};
            window_props.prompt(:,2) = {'inputFileType';'conNamesLv2';'betasLv2';'inputFileRegexp';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','press SHIFT or CTRL while clicking to choose more than one entry','press SHIFT or CTRL while clicking to choose more than one entry',hint_file_regexp,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'con','beta','other'};
            window_props.formats(1,1).size = [300 20];
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvAllCons';
            window_props.formats(2,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(2,1).size = [300 200];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvBetas';
            window_props.formats(3,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(3,1).size = [300 200];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format = 'text';
            window_props.formats(4,1).size = [300 20];
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {1,'','','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{11} = output;
                json_out.oneSampleTTest.InputFileType = char(window_props.formats(1,1).items(output.inputFileType));
                json_out.oneSampleTTest.InputFileRegexp = strtrim(strsplit(output.inputFileRegexp, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.oneSampleTTest.InputFileRegexp)
                    json_out.oneSampleTTest.InputFileRegexp = {};
                end
                json_out.oneSampleTTest.ConNamesLv2 = json_out.FirstLvAllCons(output.conNamesLv2);
                json_out.oneSampleTTest.BetasLv2 = json_out.FirstLvBetas(output.betasLv2);
                if (output.inputFileType == 3) && (length(json_out.oneSampleTTest.ConNamesLv2) ~= length(json_out.oneSampleTTest.InputFileRegexp))
                    warning('Number of regular expressions does not match the number of selected contrasts.. Please check the input.');
                end
            end
        case 12 % Input Two-sample t-test
            idx = 1;
            prompt_file_regexp_group1 = sprintf('Regular expression for input file selection (Group 1): \n(only needed if "Input file type" is "other")');
            prompt_file_regexp_group2 = sprintf('Regular expression for input file selection (Group 2): \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select all contrast names for which \nyou want to perform a two-sample t-test: \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select all beta names for which \nyou want to perform a two-sample t-test: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty); \nseparate regular expressions by %s if more than one contrast shall be processed', delimiter_verbose(get_default_values('FileRegexpNamesSeparator')));
            window_props.name = 'Input Two-sample t-test';
            window_props.prompt = {'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp_group1;prompt_file_regexp_group2;'go back'};
            window_props.prompt(:,2) = {'inputFileType';'conNamesLv2';'betasLv2';'inputFileRegexp1';'inputFileRegexp2';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','press SHIFT or CTRL while clicking to choose more than one entry','press SHIFT or CTRL while clicking to choose more than one entry',hint_file_regexp,hint_file_regexp,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'con','beta','other'};
            window_props.formats(1,1).size = [300 20];
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvAllCons';
            window_props.formats(2,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(2,1).size = [300 200];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvBetas';
            window_props.formats(3,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(3,1).size = [300 200];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format = 'text';
            window_props.formats(4,1).size = [300 20];
            window_props.formats(5,1).type   = 'edit';
            window_props.formats(5,1).format = 'text';
            window_props.formats(5,1).size = [300 20];
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {1,'','','','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{12} = output;
                json_out.twoSampleTTest.InputFileType = char(window_props.formats(1,1).items(output.inputFileType));
                json_out.twoSampleTTest.InputFileRegexp1 = strtrim(strsplit(output.inputFileRegexp1, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.twoSampleTTest.InputFileRegexp1)
                    json_out.oneSampleTTest.InputFileRegexp1 = {};
                end
                json_out.twoSampleTTest.InputFileRegexp2 = strtrim(strsplit(output.inputFileRegexp2, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.twoSampleTTest.InputFileRegexp2)
                    json_out.twoSampleTTest.InputFileRegexp2 = {};
                end
                if length(json_out.twoSampleTTest.InputFileRegexp1) ~= length(json_out.twoSampleTTest.InputFileRegexp2)
                    warning('Number of regular expressions for group 1 and group 2 do not match. Please check the input.');
                end
                json_out.twoSampleTTest.ConNamesLv2 = json_out.FirstLvAllCons(output.conNamesLv2);
                json_out.twoSampleTTest.BetasLv2 = json_out.FirstLvBetas(output.betasLv2);
                if ((output.inputFileType == 3) && (length(json_out.oneSampleTTest.ConNamesLv2) ~= length(json_out.oneSampleTTest.InputFileRegexp1))) || ...
                     ((output.inputFileType == 3) && (length(json_out.oneSampleTTest.ConNamesLv2) ~= length(json_out.oneSampleTTest.InputFileRegexp2)))
                    warning('Number of regular expressions does not match the number of selected contrasts. Please check the input.');
                end
            end
        case 13 % Input paired t-test
            idx = 1;
            prompt_file_regexp1 = sprintf('Regular expression for input file selection (first image of pair): \n(only needed if "Input file type" is "other")');
            prompt_file_regexp2 = sprintf('Regular expression for input file selection (second image of pair): \n(only needed if "Input file type" is "other")');
            prompt_con_selection1 = sprintf('Select all contrast names for the first image of a pair, \nfor which you want to perform a paired t-test:  \n(ignored if "Input file type" is "beta")');
            prompt_con_selection2 = sprintf('Select all contrast names for the second image of a pair, \nfor which you want to perform a paired t-test:  \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection1 = sprintf('Select all beta names for the first image of a pair, \nfor which you want to perform a paired t-test: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            prompt_beta_selection2 = sprintf('Select all beta names for the first image of a pair, \nfor which you want to perform a paired t-test: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty); \nseparate regular expressions by %s if more than one contrast shall be processed', delimiter_verbose(get_default_values('FileRegexpNamesSeparator')));
            hint_con_names = 'press SHIFT or CTRL while clicking to choose more than one entry';
            hint_betas = 'press SHIFT or CTRL while clicking to choose more than one entry';
            window_props.name = 'Input paired t-test';
            window_props.prompt = {'Input file type for first image of a pair:';prompt_con_selection1;prompt_beta_selection1;prompt_file_regexp1;'Input file type for second image of a pair:';prompt_con_selection2;prompt_beta_selection2;prompt_file_regexp2;'go back'};
            window_props.prompt(:,2) = {'inputFileType1';'conNamesLv2_1';'betasLv2_1';'inputFileRegexp1';'inputFileType2';'conNamesLv2_2';'betasLv2_2';'inputFileRegexp2';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'',hint_file_regexp,'',hint_file_regexp,hint_con_names,hint_con_names,hint_betas,hint_betas,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'con','beta','other'};
            window_props.formats(1,1).size = [300 20];
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvAllCons';
            window_props.formats(2,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(2,1).size = [300 100];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvBetas';
            window_props.formats(3,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(3,1).size = [300 100];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format = 'text';
            window_props.formats(4,1).size = [300 20];
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'con','beta','other'};
            window_props.formats(5,1).size = [300 20];
            window_props.formats(6,1).type   = 'list';
            window_props.formats(6,1).style = 'listbox';
            window_props.formats(6,1).items = json_out.FirstLvAllCons';
            window_props.formats(6,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(6,1).size = [300 100];
            window_props.formats(6,1).labelloc = 'lefttop';
            window_props.formats(7,1).type   = 'list';
            window_props.formats(7,1).style = 'listbox';
            window_props.formats(7,1).items = json_out.FirstLvBetas';
            window_props.formats(7,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(7,1).size = [300 100];
            window_props.formats(7,1).labelloc = 'lefttop';
            window_props.formats(8,1).type   = 'edit';
            window_props.formats(8,1).format = 'text';
            window_props.formats(8,1).size = [300 20];
            window_props.formats(9,1).type   = 'check';
            window_props.formats(9,1).format  = 'text';
            window_props.defaultanswers = {1,'','','',1,'','','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{13} = output;
                json_out.pairedTTest.InputFileType1 = char(window_props.formats(1,1).items(output.inputFileType1));
                json_out.pairedTTest.InputFileRegexp1 = strtrim(strsplit(output.inputFileRegexp1, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.pairedTTest.InputFileRegexp1)
                    json_out.oneSampleTTest.InputFileRegexp1 = {};
                end
                json_out.pairedTTest.InputFileType2 = char(window_props.formats(5,1).items(output.inputFileType2));
                json_out.pairedTTest.InputFileRegexp2 = strtrim(strsplit(output.inputFileRegexp2, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.pairedTTest.InputFileRegexp2)
                    json_out.pairedTTest.InputFileRegexp2 = {};
                end
                json_out.pairedTTest.ConNamesLv2_1 = json_out.FirstLvAllCons(output.conNamesLv2_1);
                json_out.pairedTTest.ConNamesLv2_2 = json_out.FirstLvAllCons(output.conNamesLv2_2);
                json_out.pairedTTest.BetasLv2_1 = json_out.FirstLvBetas(output.betasLv2_1);
                json_out.pairedTTest.BetasLv2_2 = json_out.FirstLvBetas(output.betasLv2_2);
                if (output.inputFileType1 == 3) && (length(json_out.pairedTTest.ConNamesLv2_1) ~= length(json_out.pairedTTest.InputFileRegexp1))
                    warning('Number of regular expressions does not match the number of selected contrasts for first image of pairs. Please check the input.');
                end
                if (output.inputFileType2 == 3) && (length(json_out.pairedTTest.ConNamesLv2_2) ~= length(json_out.pairedTTest.InputFileRegexp2))
                    warning('Number of regular expressions does not match the number of selected contrasts for second image of pairs. Please check the input.');
                end
            end
        case 14 % Input Multiple regression
            temp_status_id = status_id;
            idx = 1;
            prompt_file_regexp = sprintf('Regular expression for input file selection: \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select all contrast names, which you \nwant to include for the chosen subjects: \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select all beta names, which you \nwant to include for the chosen subjects: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty); \nseparate regular expressions by %s if more than one contrast shall be processed', delimiter_verbose(get_default_values('FileRegexpNamesSeparator')));
            window_props.name = 'Input Multiple Regression';
            window_props.prompt = {'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp;'Number of covariates:';'Intercept:';'go back'};
            window_props.prompt(:,2) = {'inputFileType';'conNamesLv2';'betasLv2';'inputFileRegexp';'nCovariatesMultiReg';'intercept';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','press SHIFT or CTRL while clicking to choose more than one entry','press SHIFT or CTRL while clicking to choose more than one entry',hint_file_regexp,'','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'con','beta','other'};
            window_props.formats(1,1).size = [300 20];
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvAllCons';
            window_props.formats(2,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(2,1).size = [300 200];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvBetas';
            window_props.formats(3,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(3,1).size = [300 200];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format = 'text';
            window_props.formats(4,1).size = [300 20];
            window_props.formats(5,1).type   = 'edit';
            window_props.formats(5,1).format = 'integer';
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type = 'list';
            window_props.formats(6,1).style = 'radiobutton';
            window_props.formats(6,1).items = {'no','yes'};
            window_props.formats(6,1).size = [130 20];
            window_props.formats(7,1).type   = 'check';
            window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {1,'','','',0,2,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{14} = output;
                json_out.multiReg.InputFileType = char(window_props.formats(1,1).items(output.inputFileType));
                json_out.multiReg.InputFileRegexp = strtrim(strsplit(output.inputFileRegexp, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.multiReg.InputFileRegexp)
                    json_out.multiReg.InputFileRegexp = {};
                end
                json_out.multiReg.ConNamesLv2 = json_out.FirstLvAllCons(output.conNamesLv2);
                json_out.multiReg.BetasLv2 = json_out.FirstLvBetas(output.betasLv2);
                if (output.inputFileType == 3) && (length(json_out.multiReg.ConNamesLv2) ~= length(json_out.multiReg.InputFileRegexp))
                    warning('Number of regular expressions does not match the number of selected contrasts. Please check the input.');
                end
                json_out.multiReg.NumberOfCovariatesMultiReg = output.nCovariatesMultiReg;
                json_out.multiReg.Intercept = output.intercept - 1;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    repeat_args.id24 = output.nCovariatesMultiReg;
                    for idx_covMR = 1:repeat_args.id24
                        if status_id == -1
                            return;
                        else
                            repeat_args.CovMultiReg_id = idx_covMR;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(24, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                end
            end
        case 15 % Options One way ANOVA
            temp_status_id = status_id;
            idx = 1;
            window_props.name = 'Options One way ANOVA';
            window_props.prompt = {'Number of cells:';'Independence:';'Variance:';'Grand mean scaling:';'ANCOVA:';'go back'};
            window_props.prompt(:,2) = {'nCells';'indepFlag';'varFlag';'scalingFlag';'ancovaFlag';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'integer';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'no','yes'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'equal','unequal'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'no','yes'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {'',2,1,1,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{15} = output;
                json_out.ANOVA.NumberOfCells = output.nCells;
                json_out.ANOVA.IndepFlag = output.indepFlag - 1;
                json_out.ANOVA.VarianceFlag = char(window_props.formats(3,1).items(output.varFlag));
                json_out.ANOVA.ScalingFlag = output.scalingFlag - 1;
                json_out.ANOVA.ANCOVAFlag = output.ancovaFlag - 1;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    repeat_args.id25 = output.nCells;
                    for idx_cellANOVA = 1:repeat_args.id25
                        if status_id == -1
                            return;
                        else
                            repeat_args.cellANOVA_id = idx_cellANOVA;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(25, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                end
            end
        case 16 % Options One way ANOVA within subject
            temp_status_id = status_id;
            idx = 1;
            prompt_nsubjects = sprintf('Number of subject settings: \n(subjects with same settings (i.e., conditions) can be grouped together)');
            window_props.name = 'Options One way ANOVA within subject';
            window_props.prompt = {prompt_nsubjects;'Independence:';'Variance:';'Grand mean scaling:';'ANCOVA:';'go back'};
            window_props.prompt(:,2) = {'nSubjects';'indepFlag';'varFlag';'scalingFlag';'ancovaFlag';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'integer';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'no','yes'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'equal','unequal'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'no','yes'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {1,2,1,1,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{16} = output;
                json_out.subANOVA.NumberOfSubjects = output.nSubjects;
                json_out.subANOVA.IndepFlag = output.indepFlag - 1;
                json_out.subANOVA.VarianceFlag = char(window_props.formats(3,1).items(output.varFlag));
                json_out.subANOVA.ScalingFlag = output.scalingFlag - 1;
                json_out.subANOVA.ANCOVAFlag = output.ancovaFlag - 1;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    repeat_args.id26 = output.nSubjects;
                    for idx_subjectsANOVA = 1:repeat_args.id26
                        if status_id == -1
                            return;
                        else
                            repeat_args.subjectANOVA_id = idx_subjectsANOVA;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(26, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                end
            end
        case 17 % Options Full Factorial
            temp_status_id = status_id;
            idx = 1;
            window_props.name = 'Options Full Factorial';
            window_props.prompt = {'Number of factors:';'Number of cells:';'Generate contrasts:';'go back'};
            window_props.prompt(:,2) = {'nFactors';'nCells';'generateCons';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'integer';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'edit';
            window_props.formats(2,1).format = 'integer';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type   = 'check';
            window_props.formats(4,1).format  = 'text';
            window_props.defaultanswers = {2,'',1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{17} = output;
                json_out.fullFact.NumberOfFactors = output.nFactors;
                json_out.fullFact.NumberOfCells = output.nCells;
                json_out.fullFact.GenerateContrasts = output.generateCons - 1;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    repeat_args.id27 = output.nFactors;
                    repeat_args.id45 = output.nCells;
                    for idx_fact = 1:repeat_args.id27
                        if status_id == -1
                            return;
                        else
                            repeat_args.factFullFact_id = idx_fact;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(27, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                    for idx_cell = 1:repeat_args.id45
                        if status_id == -1
                            return;
                        else
                            repeat_args.cellFullFact_id = idx_cell;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(45, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                    %status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                end
            end
        case 18 % Options Flexible Factorial
            temp_status_id = status_id;
            idx = 1;
            prompt_nsubjects = sprintf('Number of subject settings: \n(subjects with same settings (i.e., factor assignment) can be grouped together)');
            window_props.name = 'Options Flexible Factorial';
            window_props.prompt = {'Number of factors:';prompt_nsubjects;'Number of interactions:';'go back'};
            window_props.prompt(:,2) = {'nFactors';'nSubjects';'nInteractions';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'integer';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'edit';
            window_props.formats(2,1).format = 'integer';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'edit';
            window_props.formats(3,1).format = 'integer';
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type   = 'check';
            window_props.formats(4,1).format  = 'text';
            window_props.defaultanswers = {2,1,0,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{18} = output;
                json_out.flexFact.NumberOfFactors = output.nFactors;
                json_out.flexFact.NumberOfSubjects = output.nSubjects;
                json_out.flexFact.NumberOfInteractions = output.nInteractions;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    repeat_args.id28 = output.nFactors;
                    repeat_args.id46 = output.nSubjects;
                    repeat_args.id48 = output.nInteractions;
                    for idx_fact = 1:repeat_args.id28
                        if status_id == -1
                            return;
                        else
                            repeat_args.factFF_id = idx_fact;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(28, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                    for idx_subj = 1:repeat_args.id46
                        if status_id == -1
                            return;
                        else
                            repeat_args.subjFF_id = idx_subj;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(46, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                    for idx_interact = 1:repeat_args.id48
                        if status_id == -1
                            return;
                        else
                            repeat_args.interactFF_id = idx_interact;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(48, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                    if idx_fact > 0
                        status_id = 47;
                    end
                    %status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                end
            end
        case 20 % Second level selection window for main selection 'First + Second level'
            idx = 1;
            % get parameters from first level node
            if strcmp(json_out.Template, 'First + Second level') % "First + Second level" requires to get info from previously defined first level node
                sub_id_list = cell(1, size(json_out.SubjectFoldersPreproc, 1));
                for i = 1:size(json_out.SubjectFoldersPreproc, 1)
                    subfolder_split = strsplit(json_out.SubjectFoldersPreproc{i}, filesep);
                    sub_id_list{i} = subfolder_split{end};
                end
                json_out.FirstLvSubID = sub_id_list.';
                json_out.FirstLvOutputDir = json_out.OutputDirLv1;
                json_out.FirstLvBetas = json_out.X;
                json_out.FirstLvAllCons = [json_out.tContrastNames.'; json_out.fContrastNames.'; json_out.DummyContrastNames];
            end
            % get default output directory
            default_output_dir_lv2 = get_default_output_dir_lv2(json_out.FirstLvOutputDir,'vis');
            default_output_prompt_lv2 = ['Default output directory: ', default_output_dir_lv2];
            prompt_con_definition = 'Contrasts have to be defined directly in the .json model file';
            window_props.name = 'Second level input';
            window_props.prompt = {'Design type';'Estimation method';'Select output directory (leave empty to use default)';default_output_prompt_lv2;prompt_con_definition};
            window_props.prompt(:,2) = {'secLvDesignType';'estMethodSecondLv';'outputDirSecondLv';'defaultOutputDir';'conDefinition'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'select','','leave empty to use default','',''};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'popupmenu';
            window_props.formats(1,1).items  = {'One sample t-test','Two sample t-test', 'Paired t-test', 'Multiple Regression', 'One Way ANOVA', 'One Way ANOVA within subject','Full Factorial','Flexible Factorial'};
            window_props.formats(1,1).size = [200 20];
            %window_props.formats_second(1,1).labelloc = 'topcenter';
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'popupmenu';
            window_props.formats(2,1).items = {'Classical','Bayesian 2nd-level'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type   = 'edit';
            window_props.formats(3,1).format  = 'dir';
            window_props.formats(3,1).size = [400 20];
            window_props.formats(4,1).type = 'text';
            window_props.formats(5,1).type = 'text';
            window_props.defaultanswers = {1,1,'',default_output_dir_lv2,''};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{10} = output;
                json_out.DesignTypeLv2 = char(window_props.formats(1,1).items(output.secLvDesignType));
                json_out.EstMethodLv2 = char(window_props.formats(2,1).items(output.estMethodSecondLv));
                json_out.OutputDirLv2 = strtrim(output.outputDirSecondLv);
                if json_out.DesignTypeLv2 == "One sample t-test"
                    status_id = 11;
                elseif json_out.DesignTypeLv2 == "Two sample t-test"
                    status_id = 12;
                elseif json_out.DesignTypeLv2 == "Paired t-test"
                    status_id = 13;
                elseif json_out.DesignTypeLv2 == "Multiple Regression"
                    status_id = 14;
                elseif json_out.DesignTypeLv2 == "One Way ANOVA"
                    status_id = 15;
                elseif json_out.DesignTypeLv2 == "One Way ANOVA within subject"
                    status_id = 16;
                elseif json_out.DesignTypeLv2 == "Full Factorial"
                    status_id = 17;
                elseif json_out.DesignTypeLv2 == "Flexible Factorial"
                    status_id = 18;
                end
                json_out.DefineContrastsFlagLv2 = 0; % Contrasts have to be defined directly in the .json model file
            end
        case 22 % Options Two-sample t-test
            idx = 1;
            window_props.name = 'Options Two-sample t-test';
            window_props.prompt = {'Subjects Group 1:';'Subjects Group 2:';'Independence:';'Variance:';'Grand mean scaling:';'ANCOVA:';'go back'};
            window_props.prompt(:,2) = {'subID1';'subID2';'indepFlag';'varFlag';'scalingFlag';'ancovaFlag';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'''';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'listbox';
            window_props.formats(1,1).items = json_out.FirstLvSubID';
            window_props.formats(1,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(1,1).size = [300 200];
            window_props.formats(1,1).labelloc = 'lefttop';
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvSubID';
            window_props.formats(2,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(2,1).size = [300 200];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'equal','unequal'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type = 'list';
            window_props.formats(6,1).style = 'radiobutton';
            window_props.formats(6,1).items = {'no','yes'};
            window_props.formats(6,1).size = [130 20];
            window_props.formats(7,1).type   = 'check';
            window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {'','',2,1,1,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{22} = output;
                json_out.twoSampleTTest.SubID1 = json_out.FirstLvSubID(output.subID1);
                json_out.twoSampleTTest.SubID2 = json_out.FirstLvSubID(output.subID2);
                json_out.twoSampleTTest.IndepFlag = output.indepFlag - 1;
                json_out.twoSampleTTest.VarianceFlag = char(window_props.formats(4,1).items(output.varFlag));
                json_out.twoSampleTTest.ScalingFlag = output.scalingFlag - 1;
                json_out.twoSampleTTest.ANCOVAFlag = output.ancovaFlag - 1;
            end
        case 23 % Options Paired t-test
            idx = 1;
            window_props.name = 'Options Paired t-test';
            window_props.prompt = {'Select subjects for first image of a pair:';'Select subjects for second image of a pair:';'Grand mean scaling:';'ANCOVA:';'go back'};
            window_props.prompt(:,2) = {'subID1';'subID2';'scalingFlag';'ancovaFlag';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'listbox';
            window_props.formats(1,1).items = json_out.FirstLvSubID';
            window_props.formats(1,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(1,1).size = [300 200];
            window_props.formats(1,1).labelloc = 'lefttop';
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvSubID';
            window_props.formats(2,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(2,1).size = [300 200];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'no','yes'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {'','',1,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{23} = output;
                json_out.pairedTTest.ScalingFlag = output.scalingFlag - 1;
                json_out.pairedTTest.ANCOVAFlag = output.ancovaFlag - 1;
                json_out.pairedTTest.SubID1 = json_out.FirstLvSubID(output.subID1);
                json_out.pairedTTest.SubID2 = json_out.FirstLvSubID(output.subID2);
            end
        case 24 % Covariates - Multiple regression (must be executed several times according to output.nCovariatesMultiReg or json_out.NumberOfCovariatesMultiReg)
            idx = repeat_args.CovMultiReg_id;
            if idx < repeat_args.id24
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            window_props.name = ['Covariate ', num2str(idx)];
            window_props.prompt = {'Covariate name:';'Regular expression to find file containing covariate:';'Corresponding column in file:';'Centering:';'go back'};
            window_props.prompt(:,2) = {'covariateName';'covariateRegexp';'covariateCol';'covariateCentering';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            if idx < repeat_args.id24
                window_props.prompt(:,4) = {'must be unique','','can be left empty if same as "Covariate name"','',['only active on last covariate (', num2str(repeat_args.id24), ')']};
            else
                window_props.prompt(:,4) = {'must be unique','','can be left empty if same as "Covariate name"','','click OK after activation'};
            end
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'text';
            window_props.formats(2,1).size = [300 20];
            window_props.formats(3,1).type   = 'edit';
            window_props.formats(3,1).format  = 'text';
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type   = 'list';
            window_props.formats(4,1).style = 'popupmenu';
            window_props.formats(4,1).items = {'No centering','Overall mean'};
            window_props.formats(4,1).size = [130 20]; 
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {'','^participants\.tsv$','',2,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{24} = output;
                json_out.multiReg.cov(idx).CovariateMultiRegName = strtrim(output.covariateName);
                json_out.multiReg.cov(idx).CovMultiRegRegexp = strtrim(output.covariateRegexp);
                json_out.multiReg.cov(idx).CovMultiRegCol = strtrim(output.covariateCol);
                if isempty(json_out.multiReg.cov(idx).CovMultiRegCol)
                    json_out.multiReg.cov(idx).CovMultiRegCol = json_out.multiReg.cov(idx).CovariateMultiRegName;
                end
                json_out.multiReg.cov(idx).CovMultiRegCentering = char(window_props.formats(4,1).items(output.covariateCentering));
            end
        case 25 % Input One way ANOVA (must be executed several times according to output.nCells or json_out.NumberOfCells)
            idx = repeat_args.cellANOVA_id;
            if idx < repeat_args.id25
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            prompt_file_regexp = sprintf('Regular expression for input file selection: \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select contrast name: \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select beta name: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty)');
            window_props.name = ['Input One way ANOVA: Cell ', num2str(idx)];
            window_props.prompt = {'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp;'Select subjects:';'go back'};
            window_props.prompt(:,2) = {'inputFileType';'conNameLv2';'betaLv2';'inputFileRegexp';'subID';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            if idx < repeat_args.id25
                window_props.prompt(:,4) = {'','','',hint_file_regexp,'',['only active on last cell (', num2str(repeat_args.id25), ')']};
            else
                window_props.prompt(:,4) = {'','','',hint_file_regexp,'','click OK after activation'};
            end
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'con','beta','other'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'list';
            window_props.formats(2,1).style = 'listbox';
            window_props.formats(2,1).items = json_out.FirstLvAllCons';
            window_props.formats(2,1).limits = [0 1];
            window_props.formats(2,1).size = [300 60];
            window_props.formats(2,1).labelloc = 'lefttop';
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvBetas';
            window_props.formats(3,1).limits = [0 1];
            window_props.formats(3,1).size = [300 60];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'edit';
            window_props.formats(4,1).format = 'text';
            window_props.formats(4,1).size = [300 20];
            window_props.formats(5,1).type   = 'list';
            window_props.formats(5,1).style = 'listbox';
            window_props.formats(5,1).items = json_out.FirstLvSubID';
            window_props.formats(5,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(5,1).size = [300 200];
            window_props.formats(5,1).labelloc = 'lefttop';
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {1,'','','','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{25} = output;
                json_out.ANOVA.cell(idx).InputFileType = char(window_props.formats(1,1).items(output.inputFileType));
                json_out.ANOVA.cell(idx).InputFileRegexp = strtrim(output.inputFileRegexp);
                if isempty(json_out.ANOVA.cell(idx).InputFileRegexp)
                    json_out.ANOVA.cell(idx).InputFileRegexp = '';
                end
                json_out.ANOVA.cell(idx).ConNameLv2 = json_out.FirstLvAllCons(output.conNameLv2);
                json_out.ANOVA.cell(idx).BetaLv2 = json_out.FirstLvBetas(output.betaLv2);
                if (output.inputFileType == 3) && isempty(json_out.ANOVA.cell(idx).InputFileRegexp)
                    warning('Regular expression for input file selection is empty for cell %d. Please provide a regular expression or change the input file type.', idx);
                end
                json_out.ANOVA.cell(idx).SubID = json_out.FirstLvSubID(output.subID);
            end
        case 26 % Input One way ANOVA - within subject (must be executed several times according to output.nSubjects or json_out.NumberOfSubjects)
            idx = repeat_args.subjectANOVA_id;
            if idx < repeat_args.id26
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            prompt_file_regexp = sprintf('Regular expression for input file selection: \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select all contrast names, which you \nwant to include for the chosen subjects: \n(Unless otherwise specified (see below), \nthe first contrast will be assigned to Condition 1, \nthe second contrast to Condition 2, etc.; \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select all beta names, which you \nwant to include for the chosen subjects: \n(Unless otherwise specified (see below), \nthe first beta will be assigned to Condition 1, \nthe second beta to Condition 2, etc.; \nonly needed if "Input file type" is "beta", \notherwise ignored)');
            prompt_con_assignment = sprintf('Assignment of contrasts to conditions: \nvector must contain numbers 1,...,number of chosen contrasts \n(leave empty to use default: 1, 2, 3,...)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty); \nseparate regular expressions by %s if more than one contrast shall be processed', delimiter_verbose(get_default_values('FileRegexpNamesSeparator')));
            window_props.name = sprintf('Input One way ANOVA within subject (setting %d)', idx);
            window_props.prompt = {'Select subjects:';'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp;prompt_con_assignment;'go back'};
            window_props.prompt(:,2) = {'subID';'inputFileType';'conNamesLv2';'betasLv2';'inputFileRegexp';'conAssignment';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            if idx < repeat_args.id26
                window_props.prompt(:,4) = {'press SHIFT or CTRL while clicking to choose more than one entry','','press SHIFT or CTRL while clicking to choose more than one entry','press SHIFT or CTRL while clicking to choose more than one entry',hint_file_regexp,'separate numbers by space, comma, semi-colon or enter',['only active on last subject (', num2str(repeat_args.id26), ')']};
            else
                window_props.prompt(:,4) = {'press SHIFT or CTRL while clicking to choose more than one entry','','press SHIFT or CTRL while clicking to choose more than one entry','press SHIFT or CTRL while clicking to choose more than one entry',hint_file_regexp,'separate numbers by space, comma, semi-colon or enter','click OK after activation'};
            end
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'listbox';
            window_props.formats(1,1).items = json_out.FirstLvSubID';
            window_props.formats(1,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(1,1).size = [300 180];
            window_props.formats(1,1).labelloc = 'lefttop';
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'con','beta','other'};
            window_props.formats(2,1).size = [300 20];
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvAllCons';
            window_props.formats(3,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(3,1).size = [300 100];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'list';
            window_props.formats(4,1).style = 'listbox';
            window_props.formats(4,1).items = json_out.FirstLvBetas';
            window_props.formats(4,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(4,1).size = [300 100];
            window_props.formats(4,1).labelloc = 'lefttop';
            window_props.formats(5,1).type   = 'edit';
            window_props.formats(5,1).format = 'text';
            window_props.formats(5,1).size = [300 20];
            window_props.formats(6,1).type   = 'edit';
            window_props.formats(6,1).format = 'vector';
            window_props.formats(6,1).size = [300 60];
            window_props.formats(7,1).type   = 'check';
            window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {'',1,'','','','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{26} = output;
                json_out.subANOVA.subj(idx).SubID = json_out.FirstLvSubID(output.subID);
                json_out.subANOVA.subj(idx).InputFileType = char(window_props.formats(2,1).items(output.inputFileType));
                json_out.subANOVA.subj(idx).InputFileRegexp = strtrim(strsplit(output.inputFileRegexp, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.subANOVA.subj(idx).InputFileRegexp)
                    json_out.subANOVA.subj(idx).InputFileRegexp = {};
                end
                json_out.subANOVA.subj(idx).ConNamesLv2 = json_out.FirstLvAllCons(output.conNamesLv2);
                json_out.subANOVA.subj(idx).BetasLv2 = json_out.FirstLvBetas(output.betasLv2);
                if (output.inputFileType == 3) && (length(json_out.subANOVA.subj(idx).ConNamesLv2) ~= length(json_out.subANOVA.subj(idx).InputFileRegexp))
                    warning('Number of regular expressions does not match the number of selected contrasts for subject setting %d. Please check the input.', idx);
                end
                if ~isempty(output.conAssignment) % check if dimension of conAssignment is in agreement with chosen contrasts
                    if size(output.conAssignment, 1) > 1
                        json_out.subANOVA.subj(idx).ConAssignment = output.conAssignment';
                    else
                        json_out.subANOVA.subj(idx).ConAssignment = output.conAssignment;
                    end
                    if output.inputFileType == 1 % type con
                        if length(output.conNamesLv2) < length(output.conAssignment)
                            warning('Number of selected contrasts is smaller than the number of assigned conditions. Go back from next step and correct the input. Otherwise additional numbers will be ignored.');
                            json_out.subANOVA.subj(idx).ConAssignment = json_out.subANOVA.subj(idx).ConAssignment(1:length(output.conNamesLv2));
                        elseif length(output.conNamesLv2) > length(output.conAssignment)
                            warning('Number of selected contrasts is larger than the number of assigned conditions. Go back from next step and correct the input. Otherwise additional contrasts will be assigned automatically.');
                            for i = length(output.conAssignment)+1:length(output.conNamesLv2)
                                json_out.subANOVA.subj(idx).ConAssignment(i) = max(output.conAssignment) + i-length(output.conAssignment);
                            end
                        end
                    elseif output.inputFileType == 2 % type beta
                        if length(output.betasLv2) < length(output.conAssignment)
                            warning('Number of selected betas is smaller than the number of assigned conditions. Go back from next step and correct the input. Otherwise additional numbers will be ignored.');
                            json_out.subANOVA.subj(idx).ConAssignment = json_out.subANOVA.subj(idx).ConAssignment(1:length(output.betasLv2));
                        elseif length(output.betasLv2) > length(output.conAssignment)
                            warning('Number of selected betas is larger than the number of assigned conditions. Go back from next step and correct the input. Otherwise additional betas will be assigned automatically.');
                            for i = length(output.conAssignment)+1:length(output.betasLv2)
                                json_out.subANOVA.subj(idx).ConAssignment(i) = max(output.conAssignment) + i-length(output.conAssignment);
                            end
                        end
                    elseif output.inputFileType == 3 % type other
                        if length(json_out.subANOVA.subj(idx).InputFileRegexp) < length(output.conAssignment)
                            warning('Number of selected regular expressions is smaller than the number of assigned conditions. Go back from next step and correct the input. Otherwise additional numbers will be ignored.');
                            json_out.subANOVA.subj(idx).ConAssignment = json_out.subANOVA.subj(idx).ConAssignment(1:length(json_out.subANOVA.subj(idx).InputFileRegexp));
                        elseif length(json_out.subANOVA.subj(idx).InputFileRegexp) > length(output.conAssignment)
                            warning('Number of selected regular expressions is larger than the number of assigned conditions. Go back from next step and correct the input. Otherwise additional regular expressions will be assigned automatically.');
                            for i = length(output.conAssignment)+1:length(json_out.subANOVA.subj(idx).InputFileRegexp)
                                json_out.subANOVA.subj(idx).ConAssignment(i) = max(output.conAssignment) + i-length(output.conAssignment);
                            end
                        end
                    end
                else
                    if output.inputFileType == 1 % type con
                        json_out.subANOVA.subj(idx).ConAssignment = 1:length(output.conNamesLv2);
                    elseif output.inputFileType == 2 % type beta
                        json_out.subANOVA.subj(idx).ConAssignment = 1:length(output.betasLv2);
                    elseif output.inputFileType == 3 % type other
                        json_out.subANOVA.subj(idx).ConAssignment = 1:length(json_out.subANOVA.subj(idx).InputFileRegexp);
                    end
                end
            end
        case 27 % Factors Full Factorial (must be executed several times according to output.nFactors or json_out.NumberOfFactors)
            idx = repeat_args.factFullFact_id;
            if idx < repeat_args.id27
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            window_props.name = ['Factors Full Factorial: factor ', num2str(idx)];
            window_props.prompt = {['Name (factor ', num2str(idx), '):'];['Levels (factor ', num2str(idx), ')'];'Independence:';'Variance:';'Grand mean scaling:';'ANCOVA:'};%;'go back'};
            window_props.prompt(:,2) = {'factorName';'factorLevels';'indepFlag';'varFlag';'scalingFlag';'ancovaFlag'};%,'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','','',''};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format = 'integer';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'equal','unequal'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type = 'list';
            window_props.formats(6,1).style = 'radiobutton';
            window_props.formats(6,1).items = {'no','yes'};
            window_props.formats(6,1).size = [130 20];
            %window_props.formats(7,1).type   = 'check';
            %window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {'',2,2,1,1,1};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{27} = output;
                json_out.fullFact.fact(idx).FactorName = strtrim(output.factorName);
                json_out.fullFact.fact(idx).FactorLevels = output.factorLevels;
                json_out.fullFact.fact(idx).IndepFlag = output.indepFlag - 1;
                json_out.fullFact.fact(idx).VarianceFlag = char(window_props.formats(4,1).items(output.varFlag));
                json_out.fullFact.fact(idx).ScalingFlag = output.scalingFlag - 1;
                json_out.fullFact.fact(idx).ANCOVAFlag = output.ancovaFlag - 1;
            end
        case 28 % Factors Flexible Factorial (must be executed several times according to output.nFactors or json_out.NumberOfFactors)
            idx = repeat_args.factFF_id;
            if idx < repeat_args.id28
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            window_props.name = 'Factors Flexible Factorial';
            window_props.prompt = {['Name (factor ', num2str(idx), '):'];'Independence:';'Variance:';'Grand mean scaling:';'ANCOVA:'};%;'go back'};
            window_props.prompt(:,2) = {'factorName';'indepFlag';'varFlag';'scalingFlag';'ancovaFlag'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','',''};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'no','yes'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'equal','unequal'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'radiobutton';
            window_props.formats(4,1).items = {'no','yes'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'no','yes'};
            window_props.formats(5,1).size = [130 20];
            %window_props.formats(6,1).type   = 'check';
            %window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {'',2,1,1,1};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{28} = output;
                json_out.flexFact.fact(idx).FactorName = strtrim(output.factorName);
                json_out.flexFact.fact(idx).IndepFlag = output.indepFlag - 1;
                json_out.flexFact.fact(idx).VarianceFlag = char(window_props.formats(3,1).items(output.varFlag));
                json_out.flexFact.fact(idx).ScalingFlag = output.scalingFlag - 1;
                json_out.flexFact.fact(idx).ANCOVAFlag = output.ancovaFlag - 1;
            end
        case 30 % Covariates
            temp_status_id = status_id;
            idx = 1;
            prompt_cov_settings = sprintf(['How many different settings for covariates do you want to specify? \n', ...
            'Settings include source files (e.g. participants.tsv) and the SPM options "Interactions" and "Centering".\n', ...
            'If all covariates are specified in the same file and settings for "Interactions" and "Centering" \n', ...
            'are the same, you only need to specify one setting.']);
            window_props.name = 'Covariates';
            window_props.prompt = {prompt_cov_settings;'go back to second level main selection'};
            window_props.prompt(:,2) = {'nCovariatesSettings';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'specify files and settings in the next step','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'integer';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'check';
            window_props.formats(2,1).format  = 'text';
            window_props.defaultanswers = {0,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{30} = output;
                json_out.NumberOfCovariatesSettings = output.nCovariatesSettings;
                if output.goBackInd == "on"
                    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                else
                    repeat_args.id49 = output.nCovariatesSettings;
                    for idx_multi_cov = 1:repeat_args.id49
                        if status_id == -1
                            return;
                        else
                            repeat_args.multi_cov_id = idx_multi_cov;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(49, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                end
            end
        case 32 % Masking
            idx = 1;
            window_props.name = 'Masking';
            window_props.prompt = {'Threshold masking:';'Threshold value:';'Implicit mask:';'Explicit mask';'go back'};
            window_props.prompt(:,2) = {'thresholdMasking';'thresholdValue';'implicitMask';'explicitMask';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','for option "Absolute" enter 0..x; for option "Relative" enter 0..1','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'None','Absolute','Relative'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'edit';
            window_props.formats(2,1).format = 'integer';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'edit';
            window_props.formats(4,1).format = 'file';
            window_props.formats(4,1).size = [400 20];
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {1,'',1,'','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{32} = output;
                json_out.ThresholdMasking = char(window_props.formats(1,1).items(output.thresholdMasking));
                json_out.ThresholdValueMask = output.thresholdValue;
                json_out.ImplicitMask = output.implicitMask - 1;
                json_out.ExplicitMask = strtrim(output.explicitMask);
            end
        case 33 % General options (second level)
            idx = 1;
            prompt_global_calc_values = sprintf('only needed if the respective option is chosen; \nnumber of elements has to match the cumulated number of images; \ncan also be copied to json file later');
            window_props.name = 'General Options';
            window_props.prompt = {'Global calculation:';'User specified values:';'Overall grand mean scaling:';'User specified value';'Normalisation:';'go back'};
            window_props.prompt(:,2) = {'globalCalculation';'globalCalcValues';'overallGrandMeanScaling';'overallGrandMeanScalingValue';'normalisation';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'',prompt_global_calc_values,'','only needed if grand mean scaling is activated (default: 50)','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'Omit','User','Mean'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'edit';
            window_props.formats(2,1).format = 'vector';
            window_props.formats(2,1).size = [250 20];
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'edit';
            window_props.formats(4,1).format = 'float';
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type   = 'list';
            window_props.formats(5,1).style = 'radiobutton';
            window_props.formats(5,1).items = {'None','Proportional','ANCOVA'};
            window_props.formats(5,1).size = [130 20];
            window_props.formats(6,1).type   = 'check';
            window_props.formats(6,1).format  = 'text';
            window_props.defaultanswers = {1,'',1,'',1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{33} = output;
                json_out.GlobalCalculation = char(window_props.formats(1,1).items(output.globalCalculation));
                json_out.GlobalCalculationValues = output.globalCalcValues;
                json_out.OverallGrandMeanScaling = output.overallGrandMeanScaling - 1;
                json_out.OverallGrandMeanScalingValue = output.overallGrandMeanScalingValue;
                json_out.Normalisation = char(window_props.formats(5,1).items(output.normalisation));
            end
        case 34 % Estimation options (second level)
            idx = 1;
            window_props.name = 'Estimation Options';
            window_props.prompt = {'Model type:';'Write residuals:';'Delete existing contrasts:';'Replicate over sessions:';'go back'};
            window_props.prompt(:,2) = {'modelType';'writeRes';'delContrasts';'replSessions';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'according to BIDS','','','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'glm','meta'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'no','yes'};
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            window_props.formats(4,1).type = 'list';
            window_props.formats(4,1).style = 'popupmenu';
            window_props.formats(4,1).items = {'Dont replicate','Replicate','Replicate&Scale','Create per session','Both: Replicate + Create per session','Both: Replicate&Scale + Create per session'};
            window_props.formats(4,1).size = [400 20];
            window_props.formats(5,1).type   = 'check';
            window_props.formats(5,1).format  = 'text';
            window_props.defaultanswers = {1,1,1,1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{34} = output;
                json_out.ModelTypeBIDSLv2 = char(window_props.formats(1,1).items(output.modelType));
                json_out.WriteResidualsLv2 = output.writeRes - 1;
                json_out.DeleteExistingContrastsLv2 = output.delContrasts - 1;
                json_out.ReplOverSessionsLv2 = char(window_props.formats(4,1).items(output.replSessions));
            end
        case 35 % Definition of Contrasts
            %temp_status_id = status_id; %probably not needed here
            idx = 1;
            prompt_tcon = sprintf('Enter contrast names for t-contrasts (separate names by %s):', delimiter_verbose(get_default_values('ContrastNamesSeparator')));
            prompt_fcon = sprintf('Enter contrast names for F-contrasts (separate names by %s):', delimiter_verbose(get_default_values('ContrastNamesSeparator')));
            window_props.name = 'Definition of Contrasts';
            window_props.prompt = {prompt_tcon;prompt_fcon;'Define "dummy contrasts":'};%;'go back'};
            window_props.prompt(:,2) = {'tContrasts';'fContrasts';'dummyContrastFlag'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','',''};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [1000 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format = 'text';
            window_props.formats(2,1).size = [1000 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'no','yes'};
            window_props.formats(3,1).size = [130 20];
            %window_props.formats(4,1).type   = 'check';
            %window_props.formats(4,1).format  = 'text';
            window_props.defaultanswers = {'','',1};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{35} = output;
                json_out.tContrastNames = strtrim(strsplit(output.tContrasts, get_default_values('ContrastNamesSeparator')));
                if isempty(json_out.tContrastNames{1})
                    json_out.tContrastNames = {};
                end
                json_out.fContrastNames = strtrim(strsplit(output.fContrasts, get_default_values('ContrastNamesSeparator')));
                if isempty(json_out.fContrastNames{1})
                    json_out.fContrastNames = {};
                end
                json_out.DummyContrastFlag = output.dummyContrastFlag - 1;
                %if output.goBackInd == "on" %probably not needed here
                %    status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                %else
                    repeat_args.id37 = length(json_out.fContrastNames);
                    if output.dummyContrastFlag == 2
                        status_id = 38;
                    else
                        json_out.DummyContrastNames = {};
                    end
                %end
            end
        case 36 % Definition of t-contrasts
            temp_status_id = status_id;
            idx = 1;
            if ~isempty(json_out.tContrastNames)
                prompt_tcon = 'Enter weights for the following contrasts: \n';
                for idx_tcon = 1:length(json_out.tContrastNames)
                    prompt_tcon = [prompt_tcon, num2str(idx_tcon),'. ', json_out.tContrastNames{idx_tcon}, '\n'];
                end
                window_props.name = 'Definition of t-contrast weights';
                window_props.prompt = {sprintf(prompt_tcon);'go back'};
                n_tcontrasts = length(json_out.tContrastNames);
                window_props.prompt(:,2) = {'tWeights';'goBackInd'}; %struct field names of ANSWER output
                %window_props.prompt(:,3) = {'';''}; %units (i.e., post-fix labels to the right of controls)
                window_props.prompt(:,4) = {'','click OK after activation'};
                window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
                window_props.formats(1,1).type   = 'table';
                window_props.formats(1,1).items = json_out.X';
                window_props.formats(1,1).size = [1000 400];
                window_props.formats(2,1).type   = 'check';
                window_props.formats(2,1).format  = 'text';
                window_props.defaultanswers = {zeros(n_tcontrasts, length(json_out.X)), 'off'};
                [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
                if (cancel_flag == 1)
                    status_id = -1;
                    fprintf('Operation cancelled\n');
                    return;
                else
                    output_{36} = output;
                    json_out.tContrastWeights = output.tWeights;
                    if output.goBackInd == "on"
                        status_id = query_goBack(output.goBackInd, temp_status_id, progr_sequence, status_id);
                    else
                        for idx_fcon = 1:repeat_args.id37
                            repeat_args.fcon_id = idx_fcon;
                            [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(37, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                        end
                    end
                    % collect all contrasts in a cell array
                    if isfield(json_out, 'fContrastNames') && isfield(json_out, 'DummyContrastNames')
                        json_out.FirstLvAllCons = [json_out.tContrastNames';json_out.fContrastNames';json_out.DummyContrastNames];
                    elseif isfield(json_out, 'DummyContrastNames')
                        json_out.FirstLvAllCons = [json_out.tContrastNames';json_out.DummyContrastNames];
                    elseif isfield(json_out, 'fContrastNames')
                        json_out.FirstLvAllCons = [json_out.tContrastNames';json_out.fContrastNames'];
                    else
                        json_out.FirstLvAllCons = json_out.tContrastNames';
                    end
                end
            else
                status_id = 50; % quit the loop in case there are no f-contrasts (i.e., repeat_args.id37 = 0)
                for idx_fcon = 1:repeat_args.id37
                    if status_id == -1
                        return;
                    else
                        repeat_args.fcon_id = idx_fcon;
                        [status_id, output_, json_out, input_buffer, progr_sequence, repeat_args] = fct_selector(37, options, output_, json_out, input_buffer, progr_sequence, repeat_args);
                    end
                end
                % collect all contrasts in a cell array
                if isfield(json_out, 'fContrastNames') && isfield(json_out, 'DummyContrastNames')
                    json_out.FirstLvAllCons = [json_out.fContrastNames';json_out.DummyContrastNames];
                elseif isfield(json_out, 'DummyContrastNames')
                    json_out.FirstLvAllCons = json_out.DummyContrastNames;
                elseif isfield(json_out, 'fContrastNames')
                    json_out.FirstLvAllCons = json_out.fContrastNames';
                else
                    json_out.FirstLvAllCons = {};
                end
            end
        case 37 % Definition of F-contrasts (must be executed several times according to length(json_out.fContrastNames))
            idx = repeat_args.fcon_id;
            if idx < repeat_args.id37
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            conditions_list_X = json_out.X;
            window_props.name = ['Definition of weights for f-contrast', num2str(idx)];
            window_props.prompt = {['Contrast name (f-contrast ', num2str(idx), '): ', json_out.fContrastNames{idx}];'Weights:';'go back'};
            window_props.prompt(:,2) = {'fContrastName';'fWeights';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';''}; %units (i.e., post-fix labels to the right of controls)
            if idx < repeat_args.id37
                window_props.prompt(:,4) = {'','',['only active on last contrast (', num2str(repeat_args.id37), ')']};
            else
                window_props.prompt(:,4) = {'','','click OK after activation'};
            end
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'text';
            window_props.formats(2,1).type = 'table';
            window_props.formats(2,1).items = conditions_list_X';
            window_props.formats(2,1).size = [1000 400];
            window_props.formats(3,1).type   = 'check';
            window_props.formats(3,1).format  = 'text';
            %window_props.formats(3,1).items = {'go back'};
            window_props.defaultanswers = {'',zeros(length(conditions_list_X)),'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{37} = output;
                % remove rows with all zeros
                output.fWeights = output.fWeights(any(output.fWeights, 2), :);
                json_out.fcon(idx).Weights = output.fWeights;
            end
        case 38 % Definition of dummy contrasts
            idx = 1;
            window_props.name = 'Definition of dummy contrasts';
            window_props.prompt = {sprintf('Choose all design matrix columns for which \nyou want to create a "dummy contrast": ');'go back'};
            window_props.prompt(:,2) = {'dummyContrasts';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'press SHIFT or CTRL while clicking to choose more than one entry','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'listbox';
            window_props.formats(1,1).items = json_out.X';
            window_props.formats(1,1).limits = [0 length(json_out.X)];
            window_props.formats(1,1).size = [300 300];
            window_props.formats(1,1).labelloc = 'lefttop';
            window_props.formats(2,1).type   = 'check';
            window_props.formats(2,1).format  = 'text';
            window_props.defaultanswers = {'','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{38} = output;
                json_out.DummyContrastNames = json_out.X(output.dummyContrasts);
            end
        case 40 % Parametric modulations (must be executed several times according to output.nParametricModulations or json_out.NumberOfParametricModulations)
            idx_sess = repeat_args.sess_id;
            idx_cond = repeat_args.cond_id;
            idx = repeat_args.pmod_id;
            if idx < repeat_args.sess(idx_sess).cond(idx_cond).id40
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            window_props.name = ['Parametric modulation ', num2str(idx), ' (sess ', num2str(idx_sess), ', cond ', num2str(idx_cond), ')'];
            window_props.prompt = {'Name:';'Column name in \_events.tsv:';'Order of polynomial expansion:'};%;'go back'};
            window_props.prompt(:,2) = {'pmodName';'pmodColName';'orderPolyExp'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'must be unique','can be left empty if same as Name',''};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'text';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type = 'list';
            window_props.formats(3,1).style = 'radiobutton';
            window_props.formats(3,1).items = {'1','2','3','4','5','6'};
            window_props.formats(3,1).size = [130 20];
            %window_props.formats(4,1).type   = 'check';
            %window_props.formats(4,1).format  = 'text';
            window_props.defaultanswers = {'','',1};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{40} = output;
                json_out.sess(idx_sess).cond(idx_cond).pmod(idx).pmodName = strtrim(output.pmodName);
                json_out.sess(idx_sess).cond(idx_cond).pmod(idx).pmodColName = strtrim(output.pmodColName);
                if isempty(json_out.sess(idx_sess).cond(idx_cond).pmod(idx).pmodColName)
                    json_out.sess(idx_sess).cond(idx_cond).pmod(idx).pmodColName = json_out.sess(idx_sess).cond(idx_cond).pmod(idx).pmodName;
                end
                json_out.sess(idx_sess).cond(idx_cond).pmod(idx).pmodPolyOrder = output.orderPolyExp;
            end
        case 41 % Factorial design (design must be extended according to output.nFactors or json_out.FactDesignFactors)
            idx = 1;
            window_props.name = 'Factorial design'; % integrate counter if possible
            window_props.prompt = {};
            window_props.prompt(:,1) = cell(2*json_out.FactDesignFactors+1, 1);
            window_props.prompt(:,2) = cell(2*json_out.FactDesignFactors+1, 1);
            window_props.prompt(:,3) = cell(2*json_out.FactDesignFactors+1, 1);
            window_props.prompt(:,4) = cell(2*json_out.FactDesignFactors+1, 1);
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.defaultanswers = cell(1, 2*json_out.FactDesignFactors+1);
            for k = 1:json_out.FactDesignFactors
                window_props.prompt(2*(k-1)+1:2*k,1) = {['Name of factor ', num2str(k)];['Number of levels for factor ', num2str(k)]};
                window_props.prompt(2*(k-1)+1:2*k,2) = {['factorName', num2str(k)];['nLevels', num2str(k)]}; %struct field names of ANSWER output
                %window_props.prompt(2*(k-1)+1:2*k,3) = {'';''}; %units (i.e., post-fix labels to the right of controls)
                window_props.prompt(2*(k-1)+1:2*k,4) = {'must be unique',''};
                window_props.formats(2*(k-1)+1, 1).type   = 'edit';
                window_props.formats(2*(k-1)+1, 1).format = 'text';
                window_props.formats(2*(k-1)+1, 1).size = [130 20];
                window_props.formats(2*k, 1).type   = 'edit';
                window_props.formats(2*k, 1).format  = 'integer';
                window_props.formats(2*k, 1).size = [130 20];
                window_props.defaultanswers(1, 2*(k-1)+1:2*k) = {'',''};
            end
            window_props.formats(2*json_out.FactDesignFactors+1, 1).type   = 'check';
            window_props.formats(2*json_out.FactDesignFactors+1, 1).format  = 'text';
            window_props.prompt(2*json_out.FactDesignFactors+1,1) = {'go back'};
            window_props.prompt(2*json_out.FactDesignFactors+1,2) = {'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(2*json_out.FactDesignFactors+1,3) = {''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(2*json_out.FactDesignFactors+1,4) = {'click OK after activation'};
            window_props.defaultanswers(1, 2*json_out.FactDesignFactors+1) = {'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{41} = output;
                for k = 1:json_out.FactDesignFactors
                    json_out.fact(k).FactorName = strtrim(output.(['factorName', num2str(k)]));
                    json_out.fact(k).FactorLevels = output.(['nLevels', num2str(k)]);
                end
            end
        case 42 % Options Canonical HRF
            idx = 1;
            window_props.name = 'Options Canonical HRF';
            window_props.prompt = {'Model derivatives:';'go back'};
            window_props.prompt(:,2) = {'derivHRF';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'radiobutton';
            window_props.formats(1,1).items = {'no','time derivative','time & dispersion derivative'};
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'check';
            window_props.formats(2,1).format  = 'text';
            window_props.defaultanswers = {1,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{42} = output;
                json_out.DerivHRF = char(window_props.formats(1,1).items(output.derivHRF));
            end
        case 43 % Options other basis functions
            idx = 1;
            window_props.name = 'Options basis function';
            window_props.prompt = {'Window length:';'Number of basis functions';'go back'};
            window_props.prompt(:,2) = {'windowLength';'nBasisFct';'goBackInd'}; %struct field names of ANSWER output
            window_props.prompt(:,3) = {'s';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format  = 'float';
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'integer';
            window_props.formats(2,1).size = [130 20];
            window_props.formats(3,1).type   = 'check';
            window_props.formats(3,1).format  = 'text';
            window_props.defaultanswers = {'','','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{43} = output;
                json_out.BasisWindowLength = output.windowLength;
                json_out.NumberOfBasisFct = output.nBasisFct;
            end
        case 45 % Input Full Factorial (must be executed several times according to output.nCells or json_out.NumberOfCells)
            idx = repeat_args.cellFullFact_id;
            if idx < repeat_args.id45
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            prompt_levels_vector = sprintf(['Levels vector for cell %d:', ...
            'vector must contain numbers indicating the level for each factor \n', ...
            'first entry assigned to factor 1, second entry to factor 2, etc. \n', ...
            '%d factors defined -> %d level values needed'], idx);
            prompt_file_regexp = sprintf('Regular expression for input file selection: \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select contrast name: \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select beta name: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty)');
            window_props.name = ['Input Full Factorial: Cell ', num2str(idx)];
            window_props.prompt = {prompt_levels_vector;'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp;'Select subjects:'};%;'go back'};
            window_props.prompt(:,2) = {'levelsVector';'inputFileType';'conNameLv2';'betaLv2';'inputFileRegexp';'subID'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'separate numbers by space, comma, semi-colon or enter','','','',hint_file_regexp,''};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'vector';
            window_props.formats(1,1).size = [300 60];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'con','beta','other'};
            window_props.formats(2,1).size = [300 20];
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvAllCons';
            window_props.formats(3,1).limits = [0 1];
            window_props.formats(3,1).size = [300 60];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'list';
            window_props.formats(4,1).style = 'listbox';
            window_props.formats(4,1).items = json_out.FirstLvBetas';
            window_props.formats(4,1).limits = [0 1];
            window_props.formats(4,1).size = [300 60];
            window_props.formats(4,1).labelloc = 'lefttop';
            window_props.formats(5,1).type   = 'edit';
            window_props.formats(5,1).format = 'text';
            window_props.formats(5,1).size = [300 20];
            window_props.formats(6,1).type   = 'list';
            window_props.formats(6,1).style = 'listbox';
            window_props.formats(6,1).items = json_out.FirstLvSubID';
            window_props.formats(6,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(6,1).size = [300 220];
            window_props.formats(6,1).labelloc = 'lefttop';
            %window_props.formats(7,1).type   = 'check';
            %window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {'',1,'','','',''};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{45} = output;
                if size(output.levelsVector, 1) > 1
                    json_out.fullFact.cell(idx).LevelsVector = output.levelsVector';
                else
                    json_out.fullFact.cell(idx).LevelsVector = output.levelsVector;
                end
                json_out.fullFact.cell(idx).InputFileType = char(window_props.formats(2,1).items(output.inputFileType));
                json_out.fullFact.cell(idx).InputFileRegexp = strtrim(output.inputFileRegexp);
                if isempty(json_out.fullFact.cell(idx).InputFileRegexp)
                    json_out.fullFact.cell(idx).InputFileRegexp = '';
                end
                json_out.fullFact.cell(idx).ConNameLv2 = json_out.FirstLvAllCons(output.conNameLv2);
                json_out.fullFact.cell(idx).BetaLv2 = json_out.FirstLvBetas(output.betaLv2);
                if (output.inputFileType == 3) && isempty(json_out.fullFact.cell(idx).InputFileRegexp)
                    warning('Regular expression for input file selection is empty for cell %d. Please provide a regular expression or change the input file type.', idx);
                end
                json_out.fullFact.cell(idx).SubID = json_out.FirstLvSubID(output.subID);
            end
        case 46 % Input Flexible Factorial (must be executed several times according to output.nSubjects or json_out.NumberOfSubjects)
            idx = repeat_args.subjFF_id;
            if idx < repeat_args.id46
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            prompt_file_regexp = sprintf('Regular expression for input file selection: \n(only needed if "Input file type" is "other")');
            prompt_con_selection = sprintf('Select all contrast names, which you \nwant to include for the chosen subjects: \n(ignored if "Input file type" is "beta")');
            prompt_beta_selection = sprintf('Select all beta names, which you \nwant to include for the chosen subjects: \n(only needed if "Input file type" is "beta", \notherwise ignored)');
            prompt_con_assignment = sprintf(['Assignment of contrasts to conditions: \n' ...
            'matrix must contain numbers indicating the level for each factor \n', ...
            'first entry assigned to factor 1, second entry to factor 2, etc. \n', ...
            'first row assigned to first contrast, second row to second contrast, etc. \n', ...
            '%d factors defined -> %d columns needed'], json_out.flexFact.NumberOfFactors, json_out.flexFact.NumberOfFactors);
            hint_file_regexp = sprintf('only needed if file type is "other" (otherwise leave empty); \nseparate regular expressions by %s if more than one contrast shall be processed', delimiter_verbose(get_default_values('FileRegexpNamesSeparator')));
            window_props.name = sprintf('Input Flexible Factorial (subjects setting %d)', idx);
            window_props.prompt = {'Select subjects:';'Input file type:';prompt_con_selection;prompt_beta_selection;prompt_file_regexp;prompt_con_assignment;};%;'go back'};
            window_props.prompt(:,2) = {'subID';'inputFileType';'conNamesLv2';'betasLv2';'inputFileRegexp';'conAssignment'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'press SHIFT or CTRL while clicking to choose more than one entry','','press SHIFT or CTRL while clicking to choose more than one entry','press SHIFT or CTRL while clicking to choose more than one entry',hint_file_regexp,'separate columns by space or comma, separate rows by semi-colon or enter'};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'listbox';
            window_props.formats(1,1).items = json_out.FirstLvSubID';
            window_props.formats(1,1).limits = [0 length(json_out.FirstLvSubID)];
            window_props.formats(1,1).size = [300 120];
            window_props.formats(1,1).labelloc = 'lefttop';
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'radiobutton';
            window_props.formats(2,1).items = {'con','beta','other'};
            window_props.formats(2,1).size = [300 20];
            window_props.formats(3,1).type   = 'list';
            window_props.formats(3,1).style = 'listbox';
            window_props.formats(3,1).items = json_out.FirstLvAllCons';
            window_props.formats(3,1).limits = [0 length(json_out.FirstLvAllCons)];
            window_props.formats(3,1).size = [300 100];
            window_props.formats(3,1).labelloc = 'lefttop';
            window_props.formats(4,1).type   = 'list';
            window_props.formats(4,1).style = 'listbox';
            window_props.formats(4,1).items = json_out.FirstLvBetas';
            window_props.formats(4,1).limits = [0 length(json_out.FirstLvBetas)];
            window_props.formats(4,1).size = [300 100];
            window_props.formats(4,1).labelloc = 'lefttop';
            window_props.formats(5,1).type   = 'edit';
            window_props.formats(5,1).format = 'text';
            window_props.formats(5,1).size = [300 20];
            window_props.formats(6,1).type   = 'edit';
            window_props.formats(6,1).format = 'vector';
            window_props.formats(6,1).size = [300 80];
            %window_props.formats(7,1).type   = 'check';
            %window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {'',1,'','','',''};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{46} = output;
                json_out.flexFact.subj(idx).SubID = json_out.FirstLvSubID(output.subID);
                json_out.flexFact.subj(idx).InputFileType = char(window_props.formats(2,1).items(output.inputFileType));
                json_out.flexFact.subj(idx).InputFileRegexp = strtrim(strsplit(output.inputFileRegexp, get_default_values('FileRegexpNamesSeparator')));
                if isempty(json_out.flexFact.subj(idx).InputFileRegexp)
                    json_out.flexFact.subj(idx).InputFileRegexp = {};
                end
                json_out.flexFact.subj(idx).ConNamesLv2 = json_out.FirstLvAllCons(output.conNamesLv2);
                json_out.flexFact.subj(idx).BetasLv2 = json_out.FirstLvBetas(output.betasLv2);
                if (output.inputFileType == 3) && (length(json_out.flexFact.subj(idx).ConNamesLv2) ~= length(json_out.flexFact.subj(idx).InputFileRegexp))
                    warning('Number of regular expressions does not match the number of selected contrasts for subject setting %d. Please check the input.', idx);
                end
                if ~isempty(output.conAssignment)
                    if (output.inputFileType == 1) && ...
                        (size(output.conAssignment, 2) ~= json_out.flexFact.NumberOfFactors) && ...
                        (numel(output.conAssignment) == json_out.flexFact.NumberOfFactors * size(json_out.flexFact.subj(idx).ConNamesLv2, 1))
                        output.conAssignment = reshape(output.conAssignment, json_out.flexFact.NumberOfFactors, size(json_out.flexFact.subj(idx).ConNamesLv2, 1)).';
                    elseif (output.inputFileType == 2) && ...
                        (size(output.conAssignment, 2) ~= json_out.flexFact.NumberOfFactors) && ...
                        (numel(output.conAssignment) == json_out.flexFact.NumberOfFactors * size(json_out.flexFact.subj(idx).BetasLv2, 1))
                        output.conAssignment = reshape(output.conAssignment, json_out.flexFact.NumberOfFactors, size(json_out.flexFact.subj(idx).BetasLv2, 1)).';
                    elseif (output.inputFileType == 3) && ...
                        (size(output.conAssignment, 2) ~= json_out.flexFact.NumberOfFactors) && ...
                        (numel(output.conAssignment) == json_out.flexFact.NumberOfFactors * size(json_out.flexFact.subj(idx).InputFileRegexp, 2))
                        output.conAssignment = reshape(output.conAssignment, json_out.flexFact.NumberOfFactors, size(json_out.flexFact.subj(idx).InputFileRegexp, 2)).';
                    end
                    if size(output.conAssignment, 2) ~= json_out.flexFact.NumberOfFactors
                        warning('Number of columns in contrast assignment does not match the number of factors. Please check the input.');
                    end
                    if (output.inputFileType == 1) && (size(output.conAssignment, 1) ~= size(json_out.flexFact.subj(idx).ConNamesLv2, 1))
                        warning('Number of rows in contrast assignment does not match the number of chosen contrasts. Please check the input.');
                    elseif (output.inputFileType == 2) && (size(output.conAssignment, 1) ~= size(json_out.flexFact.subj(idx).BetasLv2, 1))
                        warning('Number of rows in contrast assignment does not match the number of chosen betas. Please check the input.');
                    elseif (output.inputFileType == 3) && (size(output.conAssignment, 1) ~= size(json_out.flexFact.subj(idx).InputFileRegexp, 2))
                        warning('Number of rows in contrast assignment does not match the number of chosen regular expressions. Please check the input.');
                    end
                else
                    output.conAssignment = [];
                    warning('No contrast assignment defined. Please check the input.');
                end
                json_out.flexFact.subj(idx).ConAssignment = output.conAssignment;
            end
        case 47 % Main Effects Flexible Factorial
            idx = 1;
            window_props.name = 'Main Effects: choose factors';
            window_props.prompt = {};
            window_props.prompt(:,1) = cell(json_out.flexFact.NumberOfFactors+1, 1);
            window_props.prompt(:,2) = cell(json_out.flexFact.NumberOfFactors+1, 1);
            window_props.prompt(:,3) = cell(json_out.flexFact.NumberOfFactors+1, 1);
            window_props.prompt(:,4) = cell(json_out.flexFact.NumberOfFactors+1, 1);
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.defaultanswers = cell(1, json_out.flexFact.NumberOfFactors+1);
            for k = 1:json_out.flexFact.NumberOfFactors
                window_props.prompt(k,1) = {['Main effect for ', json_out.flexFact.fact(k).FactorName]};
                window_props.prompt(k,2) = {['mainEffectFactor', num2str(k)]}; %struct field names of ANSWER output
                %window_props.prompt(k,3) = {''}; %units (i.e., post-fix labels to the right of controls)
                window_props.prompt(k,4) = {'check box to include main effect for this factor'};
                window_props.formats(k,1).type   = 'check';
                window_props.formats(k,1).format = 'text';
                window_props.formats(k,1).size = [130 20];
                window_props.defaultanswers(1,k) = {'on'};
            end
            window_props.formats(json_out.flexFact.NumberOfFactors+1, 1).type   = 'check';
            window_props.formats(json_out.flexFact.NumberOfFactors+1, 1).format  = 'text';
            window_props.prompt(json_out.flexFact.NumberOfFactors+1,1) = {'go back'};
            window_props.prompt(json_out.flexFact.NumberOfFactors+1,2) = {'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(json_out.flexFact.NumberOfFactors+1,3) = {''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(json_out.flexFact.NumberOfFactors+1,4) = {'click OK after activation'};
            window_props.defaultanswers(1,json_out.flexFact.NumberOfFactors+1) = {'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{47} = output;
                for k = 1:json_out.flexFact.NumberOfFactors
                    json_out.flexFact.fact(k).mainEffect = output.(['mainEffectFactor', num2str(k)]);
                end
            end
        case 48 % Interactions Flexible Factorial (must be executed several times according to output.nInteractions or json_out.NumberOfInteractions)
            idx = repeat_args.interactFF_id;
            if idx < repeat_args.id48
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            factorNames = cell(1, json_out.flexFact.NumberOfFactors);
            for l = 1:json_out.flexFact.NumberOfFactors
                factorNames{1, l} = json_out.flexFact.fact(l).FactorName;
            end
            window_props.name = ['Interaction', num2str(idx)];
            window_props.prompt = {'Choose factor name 1:';'Choose factor name 2:'};%;'go back'};
            window_props.prompt(:,2) = {'interactionFactor1';'interactionFactor2'};%;'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'',''};%,'click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'list';
            window_props.formats(1,1).style = 'popupmenu';
            window_props.formats(1,1).items = factorNames; % input from case28: Factors Flexible Factorial
            window_props.formats(1,1).size = [130 20];
            window_props.formats(2,1).type = 'list';
            window_props.formats(2,1).style = 'popupmenu';
            window_props.formats(2,1).items = factorNames; % input from case28: Factors Flexible Factorial
            window_props.formats(2,1).size = [130 20];
            %window_props.formats(3,1).type   = 'check';
            %window_props.formats(3,1).format  = 'text';
            window_props.defaultanswers = {1,2};%,'off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{48} = output;
                json_out.flexFact.interact(idx).InteractionsFactor1 = output.interactionFactor1;
                json_out.flexFact.interact(idx).InteractionsFactor2 = output.interactionFactor2;
            end
        case 49 % Multiple Covariates - readout from file (must be executed several times according to output.nCovariatesSettings or json_out.NumberOfCovariatesSettings)
            idx = repeat_args.multi_cov_id;
            if idx < repeat_args.id49
                repeat_args.rep_flag = 1;
            else
                repeat_args.rep_flag = 0;
            end
            prompt_cov_name = sprintf('Covariate name(s) (separate names by %s):', delimiter_verbose(get_default_values('CovariateNamesSeparator')));
            prompt_col_name = sprintf('Corresponding column(s) in file (separate names by %s):', delimiter_verbose(get_default_values('CovColNamesSeparator')));
            window_props.name = ['Definition of covariates: Setting ', num2str(idx)]; % integrate counter if possible
            window_props.prompt = {'Regular expression to find file containing covariate(s):';prompt_cov_name;prompt_col_name;'Interactions:';'Centering:'};%'User specified centering value:';'go back'};
            window_props.prompt(:,2) = {'covariateRegexp';'covariateName';'covariateCol';'multiCovInteractions';'multiCovCentering';};%'multiCovUserSpecifiedCentering';'goBackInd'}; %struct field names of ANSWER output
            %window_props.prompt(:,3) = {'';'';'';'';'';'';''}; %units (i.e., post-fix labels to the right of controls)
            window_props.prompt(:,4) = {'','','','must have same number of elements than "Covariate names(s)"',''};%,'only needed if the respective option is chosen','click OK after activation'};
            window_props.formats = struct('type', {}, 'style', {}, 'items', {}, 'format', {}, 'limits', {}, 'size', {});
            window_props.formats(1,1).type   = 'edit';
            window_props.formats(1,1).format = 'text';
            window_props.formats(1,1).size = [300 20];
            window_props.formats(2,1).type   = 'edit';
            window_props.formats(2,1).format  = 'text';
            window_props.formats(2,1).size = [1000 20];
            window_props.formats(3,1).type   = 'edit';
            window_props.formats(3,1).format  = 'text';
            window_props.formats(3,1).size = [1000 20];
            window_props.formats(4,1).type   = 'list';
            window_props.formats(4,1).style = 'popupmenu';
            window_props.formats(4,1).items = {'None','with factor 1','with factor 2','with factor 3'};
            window_props.formats(4,1).size = [130 20];
            window_props.formats(5,1).type   = 'list';
            window_props.formats(5,1).style = 'popupmenu';
            window_props.formats(5,1).items = {'Overall mean','factor 1 mean','factor 2 mean','factor 3 mean','No centering','as implied by ANCOVA','GM'};%,'User specified value'}; % not clear how a user specified value should be implemented in the batch
            window_props.formats(5,1).size = [130 20];
            %window_props.formats(6,1).type   = 'edit';
            %window_props.formats(6,1).format  = 'float';
            %window_props.formats(6,1).size = [130 20];
            %window_props.formats(7,1).type   = 'check';
            %window_props.formats(7,1).format  = 'text';
            window_props.defaultanswers = {'^participants\.tsv$','','',1,1};%,'','off'};
            [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx);
            if (cancel_flag == 1)
                status_id = -1;
                fprintf('Operation cancelled\n');
                return;
            else
                output_{49} = output;
                cov_names = strtrim(strsplit(output.covariateName, get_default_values('CovariateNamesSeparator')));
                cov_cols = strtrim(strsplit(output.covariateCol, get_default_values('CovColNamesSeparator')));
                if length(cov_names) ~= length(cov_cols)
                    warning('Number of covariate names and columns must be equal. Go back from next step ("Masking") and correct the input.');
                end
                json_out.multiCov(idx).MultiCovRegexp = strtrim(output.covariateRegexp);
                json_out.multiCov(idx).MultiCovName = cov_names;
                json_out.multiCov(idx).MultiCovCol = cov_cols;
                json_out.multiCov(idx).MultiCovInteractions = char(window_props.formats(4,1).items(output.multiCovInteractions));
                json_out.multiCov(idx).MultiCovCentering = char(window_props.formats(5,1).items(output.multiCovCentering));
                %json_out.multiCov(idx).MultiCovUserCentering = output.multiCovUserSpecifiedCentering;
            end
        otherwise
            fprintf('Undefined state. Operation cancelled\n');
            status_id = -1;
    end
end

% Primary selection window
function [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = main_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args)
    if window_props.name == "Choose template"
        if ~isempty(input_buffer) && isfield(input_buffer, 'main') %'template')
            window_props.defaultanswers = {input_buffer.main.template;input_buffer.main.mainFolder;input_buffer.main.task;input_buffer.main.modelName;input_buffer.main.description;input_buffer.main.jsonPath};
        end
        [output, cancel_flag] = inputsdlg(window_props.prompt, window_props.name, window_props.formats, window_props.defaultanswers, options);
        input_buffer.main = output;
        if output.template == 1
            status_id = 2; % enter initial status_id for first level tree
        elseif output.template == 2
            status_id = 10; % enter initial status_id for second level tree
        elseif output.template == 3
            status_id = 2; % enter initial status_id for first + second level tree
        else
            status_id = -1;
        end
    end
end

% this function manages the ui window sequence and the input buffer
function [output, cancel_flag, status_id, input_buffer, progr_sequence, repeat_args] = window_selector(status_id, options, window_props, input_buffer, progr_sequence, repeat_args, idx)
    wid = ['id', num2str(status_id)];
    default_ans_temp = [];
    if ~isempty(input_buffer) && isfield(input_buffer, wid)
        if idx > 1 && size(input_buffer.(wid), 2) >= idx
            default_ans_temp = input_buffer.(wid)(idx);
            window_props.defaultanswers = struct2cell(default_ans_temp);
            % alternative if struct2cell doesn't work properly:
            %def_ans_fields = fieldnames(default_ans_temp);
            %for field_id = 1:size(def_ans_fields, 1)
            %    window_props.defaultanswers{field_id, 1} = default_ans_temp.(def_ans_fields{field_id});
            %end
        elseif idx == 1 && size(input_buffer.(wid), 2) >= idx
            default_ans_temp = input_buffer.(wid)(idx);
            window_props.defaultanswers = struct2cell(default_ans_temp);
            if status_id == 36 && ~isempty(input_buffer.('id35').tContrasts)
                tCons = strtrim(strsplit(input_buffer.('id35').tContrasts, get_default_values('ContrastNamesSeparator')));
                if isfield(input_buffer.(wid), 'tWeights') && size(input_buffer.(wid).tWeights, 1) < length(tCons)
                    for i = size(window_props.defaultanswers{1, 1}, 1)+1:length(tCons)
                        window_props.defaultanswers{1, 1}(i, :) = 0;
                    end
                end
            elseif status_id == 41 && (size(window_props.prompt, 1) ~= size(window_props.defaultanswers, 1)) % handle the case that nFactors is changed in the previous step
                for i = 1:input_buffer.('id6').nFactors
                    if ~isfield(input_buffer.(wid), ['factorName', num2str(i)])
                        input_buffer_new.(['factorName', num2str(i)]) = '';
                        window_props.defaultanswers{2*i-1, 1} = '';
                        input_buffer_new.(['nLevels', num2str(i)]) = [];
                        window_props.defaultanswers{2*i, 1} = '';
                    else
                        window_props.defaultanswers{2*i-1, 1} = input_buffer.(wid).(['factorName', num2str(i)]);
                        input_buffer_new.(['factorName', num2str(i)]) = input_buffer.(wid).(['factorName', num2str(i)]);
                        window_props.defaultanswers{2*i, 1} = input_buffer.(wid).(['nLevels', num2str(i)]);
                        input_buffer_new.(['nLevels', num2str(i)]) = input_buffer.(wid).(['nLevels', num2str(i)]);
                    end
                end
                window_props.defaultanswers{2*i+1, 1} = input_buffer.(wid).('goBackInd');
                input_buffer_new.('goBackInd') = input_buffer.(wid).('goBackInd');
                window_props.defaultanswers(2*i+2:end) = [];
                input_buffer.(wid) = input_buffer_new;
                clear input_buffer_new;
            elseif status_id == 47 && (size(window_props.prompt, 1) ~= size(window_props.defaultanswers, 1)) % handle the case that nFactors is changed in the previous step
                for i = 1:input_buffer.('id18').nFactors
                    if ~isfield(input_buffer.(wid), ['mainEffectFactor', num2str(i)])
                        input_buffer_new.(['mainEffectFactor', num2str(i)]) = 'on';
                        window_props.defaultanswers{i, 1} = 'on';
                    else
                        window_props.defaultanswers{i, 1} = input_buffer.(wid).(['mainEffectFactor', num2str(i)]);
                        input_buffer_new.(['mainEffectFactor', num2str(i)]) = input_buffer.(wid).(['mainEffectFactor', num2str(i)]);
                    end
                end
                window_props.defaultanswers{i+1, 1} = input_buffer.(wid).('goBackInd');
                input_buffer_new.('goBackInd') = input_buffer.(wid).('goBackInd');
                window_props.defaultanswers(i+2:end) = [];
                input_buffer.(wid) = input_buffer_new;
                clear input_buffer_new;
            end
        else
            ;
        end
        if ~ismember(status_id, [5,27,28,35,40,45,46,48,49]) %add 24,25,26 here??
            window_props.defaultanswers{end} = 'off';
        end
        for i = 1:size(window_props.defaultanswers, 1)
            if isnumeric(window_props.defaultanswers{i, 1}) && (size(window_props.defaultanswers{i, 1}, 1) > size(window_props.defaultanswers{i, 1}, 2))
                window_props.defaultanswers{i, 1} = window_props.defaultanswers{i, 1}';
            end
        end
    end
    [output, cancel_flag] = inputsdlg(window_props.prompt, window_props.name, window_props.formats, window_props.defaultanswers, options);
    input_buffer.(wid)(idx) = output;
    status_id_idx = find(progr_sequence.act == status_id);
    if ~isfield(output, 'goBackInd')
        output.goBackInd = 'off';
    end
    if output.goBackInd == "on"
        prev_status_id_idx = progr_sequence.prev(status_id_idx);
        status_id = prev_status_id_idx;
    else
        if repeat_args.rep_flag == 1
            ;
        else
            next_status_id_idx = progr_sequence.next(status_id_idx);
            status_id = next_status_id_idx;
        end
    end
end

function status_id = query_goBack(goBackInd, temp_status_id, progr_sequence, assigned_status_id)
    if goBackInd == "on"
        status_id_idx = find(progr_sequence.act == temp_status_id);
        status_id = progr_sequence.prev(status_id_idx);
    else
        status_id = assigned_status_id;
    end
end

