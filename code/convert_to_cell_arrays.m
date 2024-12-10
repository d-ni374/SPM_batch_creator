function nodes = convert_to_cell_arrays(nodes)
    % this function converts variables, which were imported from a json file 
    % with jsondecode, to cell arrays (necessary due to inconsistent 
    % translations of jsondecode/jsonencode, which lead to type mismatch errors);
    % called from load_json.m;
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % load function library
    fct_lib = specs_namespace();

    for i = 1:length(nodes)
        if ~isempty(nodes{i}.Transformations.Instructions) && fct_lib.find_key(nodes{i}.Transformations.Instructions, 'Name')
            nodes{i}.Transformations.Instructions = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions);
            for j = 1:length(nodes{i}.Transformations.Instructions)
                if nodes{i}.Transformations.Instructions{j}.Name == "fmri_model_specification" % NAME CAN BE CHANGED
                    if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Sessions) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Sessions, 'Session_id')
                        nodes{i}.Transformations.Instructions{j}.Input.Sessions = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Sessions);
                        for m = 1:length(nodes{i}.Transformations.Instructions{j}.Input.Sessions)
                            if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions, 'TrialType')
                                nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions);
                                for k = 1:length(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions)
                                    if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions{k}.ParametricModulations) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions{k}.ParametricModulations, 'Name')
                                        nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions{k}.ParametricModulations = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Sessions{m}.Conditions{k}.ParametricModulations);
                                    end
                                end
                            end
                        end
                    end
                    if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.FactorialDesign) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.FactorialDesign, 'Name')
                        nodes{i}.Transformations.Instructions{j}.Input.FactorialDesign = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.FactorialDesign);
                    end
                elseif nodes{i}.Transformations.Instructions{j}.Name == "factorial_design_specification" % NAME CAN BE CHANGED
                    if isfield(nodes{i}.Transformations.Instructions{j}.Input.Design, 'InputPairedTTest')
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputPairedTTest.Scans) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputPairedTTest.Scans, 'Contrasts1')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputPairedTTest.Scans = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputPairedTTest.Scans);
                        end
                    elseif isfield(nodes{i}.Transformations.Instructions{j}.Input.Design, 'InputMultipleRegression')
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputMultipleRegression.Covariates) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputMultipleRegression.Covariates, 'Name')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputMultipleRegression.Covariates = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputMultipleRegression.Covariates);
                        end
                    elseif isfield(nodes{i}.Transformations.Instructions{j}.Input.Design, 'InputOneWayANOVA')
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVA.Cells) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVA.Cells, 'Subject_ID')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVA.Cells = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVA.Cells);
                        end
                    elseif isfield(nodes{i}.Transformations.Instructions{j}.Input.Design, 'InputOneWayANOVAWithinSubject')
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVAWithinSubject.Subjects) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVAWithinSubject.Subjects, 'Subject_ID')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVAWithinSubject.Subjects = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputOneWayANOVAWithinSubject.Subjects);
                        end
                    elseif isfield(nodes{i}.Transformations.Instructions{j}.Input.Design, 'InputFullFactorial')
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Factors) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Factors, 'Name')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Factors = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Factors);
                        end
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Cells) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Cells, 'Subject_ID')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Cells = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFullFactorial.Cells);
                        end
                    elseif isfield(nodes{i}.Transformations.Instructions{j}.Input.Design, 'InputFlexibleFactorial')
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Factors) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Factors, 'Name')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Factors = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Factors);
                        end
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Subjects) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Subjects, 'Subject_ID')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Subjects = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.Subjects);
                        end
                        if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions, 'Type')
                            nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Design.InputFlexibleFactorial.MainEffectsAndInteractions);
                        end
                    end
                    if ~isempty(nodes{i}.Transformations.Instructions{j}.Input.Covariates) && fct_lib.find_key(nodes{i}.Transformations.Instructions{j}.Input.Covariates, 'Name')
                        nodes{i}.Transformations.Instructions{j}.Input.Covariates = fct_lib.convert_to_cell_array(nodes{i}.Transformations.Instructions{j}.Input.Covariates);
                    end
                end
            
                % add validation standards for additional Instructions here...
            end
        end
        if isfield(nodes{i}.Model, 'Software') && ~isempty(nodes{i}.Model.Software) %&& fct_lib.find_key(nodes{i}.Model.Software, 'SPM')
            nodes{i}.Model.Software = fct_lib.convert_to_cell_array(nodes{i}.Model.Software);
        end
        if isfield(nodes{i}, 'Contrasts') && ~isempty(nodes{i}.Contrasts) && fct_lib.find_key(nodes{i}.Contrasts, 'Name')
            nodes{i}.Contrasts = fct_lib.convert_to_cell_array(nodes{i}.Contrasts);
        end
    end

end