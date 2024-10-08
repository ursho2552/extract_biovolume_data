function [non_empty_stations, station_number] = get_stations(database, instrument_name)
% This function retrieves data for non-empty stations associated with a specific
% instrument from the `database`. It checks each station for the presence of data
% related to the given `instrument_name` and returns two outputs: the data for
% stations with entries for the specified instrument and their corresponding station numbers.
% If the `station` field is missing, the function uses the index of the station in the `database`.
%
% Inputs:
%   - database (struct): A structured array where each element corresponds to
%     a station, and fields represent different instruments with their respective data.
%   - instrument_name (string): The name of the instrument to check for non-empty data 
%     at each station in the `database`.
%
% Outputs:
%   - non_empty_stations (cell array): A list of data entries from stations that have non-empty
%     data for the specified instrument. Each cell contains the data for one station.
%   - station_number (array): A list of station numbers corresponding to the non-empty stations.
%     If the `station` field is available in the `database`, it is used; otherwise, the index 
%     of the station is used.
%
% Example:
%   [non_empty_stations, station_number] = get_stations(Mergedbase, 'UVP');
%
% In this example, the function retrieves all non-empty entries for the 'UVP' instrument
% from the `Mergedbase` dataset and returns the data and their associated station numbers.

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