function output = replace_invalid_characters(input)
    % replaces invalid characters in a char array with a specified character;
    % intended to be used for file or folder names;
    % called from define_model_lv2.m
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % replace invalid characters: change replacements as appropriate
    output = strrep(input, '#', 'No');
    output = strrep(output, '<', 'LessThan');
    output = strrep(output, '>', 'GreaterThan');
    output = strrep(output, '!', '_');
    output = strrep(output, '`', '_');
    output = strrep(output, '&', 'And');
    output = strrep(output, '*', '-');
    output = strrep(output, '}', '_');
    output = strrep(output, '{', '_');
    output = strrep(output, '?', '_');
    output = strrep(output, '"', '_');
    output = strrep(output, '=', 'Equal');
    output = strrep(output, '@', 'At');
    output = strrep(output, ':', '_');
    output = strrep(output, '|', 'Pipe');
    output = strrep(output, ' ', '_');

end