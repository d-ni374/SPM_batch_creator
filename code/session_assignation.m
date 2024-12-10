function properties = session_assignation(properties, i, ses_val, sess, file_parts, files)
    % This function handles the assignation of session_id to files;
    % called from find_files_in_subfolders.m
    %
    % INPUTS
    % properties: struct; properties of the files
    % i: int; index of the file
    % ses_val: logical array; session_id values
    % sess: cell array; session ids
    % file_parts: cell array; parts of the file path
    % files: cell array; list of files
    %
    % OUTPUTS
    % properties: struct; properties of the files
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % import function library
    fct_lib = specs_namespace();

    if sum(ses_val) == 1
        properties(i).ses = sess{ses_val}{1};
    elseif sum(ses_val) > 1
        run_idx_match = cellfun(@(x) regexpi(x, 'run[-_]*(\d+)', 'tokens'), file_parts(1:end-1), 'UniformOutput', false);
        run_idx = find(~cellfun(@isempty, run_idx_match));
        if length(run_idx) > 1
            warning('Ambiguous folder naming. Cannot assign the file %s to a single run.', files{i});
        else
            if run_idx
                properties(i).run = run_idx_match{run_idx}{1}{1};
                stop_idx = run_idx + 1;
            else
                stop_idx = 0;
            end
            exec_cnt = 0;
            warn_cnt = 0;
            for j = 1:length(ses_val)
                if j == stop_idx
                    break;
                end
                if ses_val(j)
                    exec_cnt = exec_cnt + 1;
                    files_ = fct_lib.recursdir(fullfile(file_parts{1:j}), file_parts{end});
                    if length(files_) == 1
                        if run_idx
                            sess_idx_opt = find(ses_val);
                            run_idx_ = find(sess_idx_opt == run_idx);
                            sess_idx = sess_idx_opt(run_idx_ - 1);
                            properties(i).ses = sess{sess_idx}{1};
                        else
                            properties(i).ses = sess{j}{1};
                        end
                    else
                        warn_cnt = warn_cnt + 1;
                    end
                end
            end
            if warn_cnt == exec_cnt
                warning('Ambiguous folder naming. Cannot assign the file %s to a single session.', files{i});
            end
        end
    else
        warning('No session_id found in the file %s.', files{i});
    end