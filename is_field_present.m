function flag_values = is_field_present(database, fields)

    % Ensure 'fields' is a cell array of strings for uniform processing
    if ischar(fields) || isstring(fields)
        fields = cellstr(fields);  % Convert strings or character arrays to cell array
    end
        
    flag_values = zeros(length(fields),1);
    
    for i = 1:length(fields)
        
        flag_values(i) = isfield(database, fields(i));

    end
end

