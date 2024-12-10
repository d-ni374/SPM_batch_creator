function verbose = delimiter_verbose(delimiter)
    % This functions converts the delimiter to a verbose string.
    % The verbose string is used in the GUI output.
    % The delimiter is a string that is used to separate text input into 
    % multiple entries.
    %
    % Daniel Huber, University of Innsbruck, November 2024

    if strcmp(delimiter, '\n')
        verbose = 'newline';
    elseif strcmp(delimiter, '\t')
        verbose = 'tab';
    elseif strcmp(delimiter, ' ')
        verbose = 'space';
    elseif strcmp(delimiter, ',')
        verbose = 'comma';
    elseif strcmp(delimiter, ';')
        verbose = 'semicolon';
    elseif strcmp(delimiter, ':')
        verbose = 'colon';
    elseif strcmp(delimiter, '|')
        verbose = 'pipe';
    else
        verbose = delimiter;
    end