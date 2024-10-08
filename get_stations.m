function [non_empty_stations, station_number] = get_stations(database, instrument_name)

    %get non-empty stations
    non_empty_stations = {};
    station_number = [];
    for i = 1:size(database,2)
        if size(database(i).(instrument_name),2) > 0
            non_empty_stations{end + 1} = database(i).(instrument_name);
            
            if isfield(database(i),'station')
                station_number(end + 1) = database(i).station;
            else
                station_number(end + 1) = i;
            end

        end   
    end
    
end