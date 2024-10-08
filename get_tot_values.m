function [all_tot_values, all_tot_group] = get_tot_values(database, database_carbon, instrument_name)
% This function extracts total abundance (Ab), biovolume (Bv), and carbon-related 
% biovolume values from two databases for a specific instrument. It retrieves data 
% from stations associated with the specified `instrument_name`, and for each station, 
% it collects relevant information such as latitude, longitude, depth, and event details.
% The extracted data is structured into arrays for further analysis, with separate arrays 
% for total values and groups.
%
% Inputs:
%   - database (struct): The primary dataset, where the total abundance and biovolume (Ab, Bv) 
%     data are stored for each station and instrument.
%   - database_carbon (struct): A dataset similar to `database`, but with carbon-converted biovolume values.
%   - instrument_name (string): The name of the instrument for which the data is being extracted.
%
% Outputs:
%   - all_tot_values (matrix): A matrix containing extracted values for each station and sample, 
%     with columns representing:
%       - Station number
%       - Latitude
%       - Longitude
%       - Year, Month, Day of the event
%       - Depth, Zmax, Zmin (depth information)
%       - Sample volume, Net mesh, Net surface area
%       - Abundance (Ab)
%       - Biovolume (Bv)
%       - Carbon biovolume (Bv_carbon)
%   - all_tot_group (string array): An array containing metadata for each entry, including:
%       - Zoo group name
%       - Event date (formatted as a string)
%       - Instrument name
%       - Sample ID
%
% Example:
%   [all_tot_values, all_tot_group] = get_tot_values(Mergedbase, MergedbaseC, 'UVP');
%
% In this example, the function extracts the total abundance, biovolume, and carbon 
% biovolume values for stations using the 'UVP' instrument from the `Mergedbase` and 
% `MergedbaseC` datasets. It returns the values and associated group information.
%
% Notes:
% - The function handles different instruments by switching the method of extracting `tot_values`.
% - If `Ab` or `Bv` values are not available for a sample, the function skips those entries.
% - Metadata such as `SampleID`, latitude, longitude, and event date is extracted using 
%   the `get_sample_information` function.

    FIELDS = {'Ab'; 'Bv'}; 
    [data_stations, stations] = get_stations(database, instrument_name);
    [data_stations_carbon, ~] = get_stations(database_carbon, instrument_name);
    
    all_tot_values = [];
    all_tot_group = string([]);
    
    for i = 1:size(data_stations,2)
        
        inner_struct = data_stations{i};
        inner_struct_carbon = data_stations_carbon{i};
        
        current_station = stations(i);

        for j = 1:size(inner_struct,2)
            
            struct_information = get_sample_information(inner_struct(j));

            % Get tot values Ab and Bv with the Zoo group
            % Extract the lat, lon, depth, time, station, and ID if
            % available
            switch instrument_name
                
                case 'flowcyto'
                    inner_struct(j);
                    tot_values = inner_struct(j).tot.tot;
                    tot_values_carbon = inner_struct_carbon(j).tot.tot;
                
                otherwise
                    inner_struct(j);
                    tot_values = inner_struct(j).tot;
                    tot_values_carbon = inner_struct_carbon(j).tot;
                    
                    
            end
            

            flag_fields = is_field_present(tot_values, FIELDS);
            
            for k = 1:max(size(tot_values.Zoo_groups))
                %test if values exist
                
                if flag_fields(1)
                    Ab = tot_values.Ab(k);
                end
                
                
                if flag_fields(2)
                    Bv = tot_values.Bv(k);
                    Bv_carbon = tot_values_carbon.Bv(k);
                end
                
                
                sampleID = struct_information.SampleID;
                year = struct_information.year;
                month = struct_information.month;
                day = struct_information.day;
                hour = struct_information.hour;
                minutes = struct_information.minutes;
                seconds = struct_information.seconds;
                latitude = struct_information.latitude;
                longitude = struct_information.longitude;
                depth = struct_information.depth;
                Zmax = struct_information.Zmax;
                Zmin = struct_information.Zmin;
                volume = struct_information.volume;
                Netmesh = struct_information.Netmesh;
                Netsurf = struct_information.Netsurf;
                
                event_date = struct_information.event_date;
                
                all_tot_values = [all_tot_values; [current_station, latitude, longitude, year, month, day, depth, Zmax, Zmin, volume, Netmesh, Netsurf, Ab, Bv, Bv_carbon]];
                
                all_tot_group(end + 1,:) = [tot_values.Zoo_groups{k}, string(event_date), string(instrument_name), string(sampleID)];
                
         

            end
        end
    end
end


            