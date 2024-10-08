function [all_tot_values, all_tot_group] = get_tot_values(database, database_carbon, instrument_name)
    
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


            