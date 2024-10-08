function non_empty_stations = extract_tot_information(database, instrument_name)

    %get non-empty stations
    non_empty_stations = [];
    for i = 1:size(database,2)
        if size(database(i).(instrument_name),2) > 0
            non_empty_stations = [non_empty_stations, i];
        end
        
    end



    




end