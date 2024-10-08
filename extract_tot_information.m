function non_empty_stations = extract_tot_information(database, instrument_name)
% This function identifies and extracts the indices of non-empty stations
% from a given dataset for a specific instrument. It checks each station in
% the provided `database` to see if there is data available for the specified
% `instrument_name` and returns the list of indices corresponding to stations
% that contain data for the specified instrument.
%
% Inputs:
%   - database (struct): A structured array where each element corresponds to
%     a station, and fields represent different instruments with their respective data.
%   - instrument_name (string): The name of the instrument to check for non-empty data 
%     at each station in the `database`.
%
% Outputs:
%   - non_empty_stations (array): A list of indices corresponding to stations 
%     that have non-empty data for the specified instrument.
%
% Example:
%   non_empty_stations = extract_tot_information(Mergedbase, 'FlowcamNiskin');
%
% In this example, the function checks the `Mergedbase` dataset for stations
% with non-empty data for the 'FlowcamNiskin' instrument and returns a list of
% those stations' indices.

    non_empty_stations = [];
    for i = 1:size(database,2)
        if size(database(i).(instrument_name),2) > 0
            non_empty_stations = [non_empty_stations, i];
        end
        
    end

end