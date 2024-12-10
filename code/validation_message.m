function msg = validation_message(validation)
    if validation.validation_status
        msg = 'Validation OK.\n';
    else
        msg = 'Validation failed.\n';
    end
end