function flag_values = is_field_present(database, fields)
% This function checks if specified fields are present in a given database (struct).
% It verifies the presence of each field listed in the `fields` input and returns
% a flag (1 or 0) for each field indicating whether it exists in the `database`.
%
% Inputs:
%   - database (struct): The structure in which fields will be checked.
%   - fields (cell array of strings or string array): A list of field names to check 
%     within the `database`. The function supports both string arrays and character arrays 
%     and converts them to a cell array for uniform processing.
%
% Outputs:
%   - flag_values (array): An array of flags (1 or 0) corresponding to each field:
%       - 1 indicates the field is present in the `database`.
%       - 0 indicates the field is not present.
%
% Example:
%   fields = {'Latitude', 'Longitude', 'Depth'};
%   flag_values = is_field_present(Mergedbase(1), fields);
%
% In this example, the function checks whether the 'Latitude', 'Longitude', 
% and 'Depth' fields are present in the first element of `Mergedbase` and 
% returns an array of flags indicating their presence.
%
% Notes:
% - The function supports both single field input as a string and multiple 
%   fields as a cell array of strings.

    % Ensure 'fields' is a cell array of strings for uniform processing
    if ischar(fields) || isstring(fields)
        % Convert strings or character arrays to cell array
        fields = cellstr(fields);  
    end
        
    flag_values = zeros(length(fields),1);
    
    for i = 1:length(fields)
        
        flag_values(i) = isfield(database, fields(i));

    end
end

