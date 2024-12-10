function output = convert_categories_to_double(input, predefined_categories)
    % This function converts a cell array of strings to a double array by 
    % assigning a unique number to each unique string;
    % called from read_events_file, read_participants_file.m
    % INPUTS
    % input: cell array; array of strings
    %
    % OUTPUTS
    % output: double array; array of encoded categories (unique numbers)
    %
    % EXAMPLE
    % output = convert_categories_to_double({'a', 'b', 'a', 'c', 'b', 'a'})
    %
    % Daniel Huber, University of Innsbruck, November 2024

    % get unique categories
    categories = unique(input)';
    if nargin > 1
        if ~isequal(categories, predefined_categories)
            categories = [predefined_categories, setdiff(categories, predefined_categories)];
        end
    end
    % assign a unique number to each category
    output.data = zeros(size(input));
    for i = 1:length(categories)
        output.data(strcmp(input, categories{i})) = i;
        fprintf('Category "%s" is encoded as %d\n', categories{i}, i);
    end
    output.categories = categories;
end