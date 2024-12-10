function regex_output = insert_escape_character(regex_input)
    % The function inserts an escape character (\) in the input regular 
    % expression before each \ to yield a .json compliant output.
    % NOTE: if just one double backslash is present, the regular expression 
    %   is assumed to be json compliant and is left unchanged.
    %
    % Daniel Huber, University of Innsbruck, November 2024
    
    if any(contains(regex_input, '\\')) % check if escape character is already present
        regex_output = regex_input;
    else
        regex_output = strrep(regex_input, '\', '\\');
    end
