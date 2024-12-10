Description of the contained files:

"model-teststructure_desc-formatInfo_smdl.json": This file reproduces the structure of the object, but the values 
are replaced by the required input format and an explanatory text for the respective fields. It can be further 
seen, if a field is required or optional and if there is a default value (usually taken from SPM12). Additional 
fields with name-prefixes “non-field_INFO_” contain additional information for the mentioned field, but are not 
part of the json object itself.

"model-teststructure_desc-validationRequirements_smdl.json": Similar to the first file, but less verbose and more 
focused on instructions on how the user input is validated by the program.

"model-teststructure_desc-emptyTemplate_smdl.json": This file contains all required and optional fields and can be 
used to manually fill the object. Most fields are empty or 0 (in case of numbers), some contain default values or 
exemplary input. If completed, this file can be directly used as the input for SPM_batch_creator.

"model-teststructure_desc-emptyTemplateFirstLv_smdl.json": Similar to the previous file, but only containing the 
first level node.
